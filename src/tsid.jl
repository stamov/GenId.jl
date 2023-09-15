
# Simplest wrapper. 
# Instead of having a comprehensive TsIdDefinition, we could have 2 ints - the one is the value and the other is the bits definitions packed in a single Int64, while calculations are derived from it.
struct TSID{T<:Integer}
    value::T
end



struct TsIdDefinition
    type::DataType
    name::Symbol
    bits_ignore_start::Int64
    bits_time::Int64
    bits_group_1::Int64
    bits_group_2::Int64
    bits_tail::Int64
    tail_algorithm::Symbol
    tail_rand_crypto::Bool
    text_algorithm::Symbol
    text_with_checksum::Bool
    text_full_width::Bool
    group_1::Int64
    group_2::Int64
    tail_mod::Int64
    shift_bits_time::Int64
    shift_bits_group_1::Int64
    shift_bits_group_2::Int64
    epoch_start_dt::DateTime
    epoch_end_dt::DateTime
    epoch_start_ms::Int64
    epoch_end_ms::Int64
    rand_max::Int128

    function TsIdDefinition(
        type::Type{<:Integer};
        name::Symbol=:TsIdDefinition,
        bits_ignore_start::Int64=0,
        bits_time::Int64, 
        bits_group_1::Int, 
        bits_group_2::Int=0, 
        bits_tail::Int, 
        tail_algorithm::Symbol=:machine_increment,
        tail_rand_crypto::Bool=false,
        text_algorithm::Symbol=:crockford_base_32,
        text_with_checksum::Bool=false,
        text_full_width::Bool=false,
        group_1::Int, 
        group_2::Int = 0, 
        epoch_start_dt::DateTime, 
        epoch_end_dt::DateTime
    )
        ws = word_size(type)
        @argcheck 1 <= bits_time <= ws AssertionError
        @argcheck 0 <= bits_group_1 <= ws AssertionError
        @argcheck 0 <= bits_group_2 <= ws AssertionError
        @argcheck 1 <= bits_tail <= ws AssertionError
        @argcheck bits_ignore_start + bits_time + bits_group_1 + bits_group_2 + bits_tail + 1 == ws AssertionError
        @argcheck epoch_start_dt < epoch_end_dt AssertionError
        @argcheck in(tail_algorithm, Set([:machine_increment, :random])) AssertionError
        
        return new(
            type,
            name,
            bits_ignore_start,
            bits_time, 
            bits_group_1, 
            bits_group_2, 
            bits_tail,
            tail_algorithm,
            tail_rand_crypto,
            text_algorithm,
            text_with_checksum,
            text_full_width,
            group_1, 
            group_2,
            convert(Int64, 1 << bits_tail),
            ws - bits_time - 1, 
            bits_tail, 
            0,
            epoch_start_dt, 
            epoch_end_dt,
            Dates.value(epoch_start_dt), 
            Dates.value(epoch_end_dt),
            (1 << bits_tail) - 1
        )
    end
end

function epoch_end_dt_from_epoch_start(epoch_start_dt::DateTime, bits_time::Int64)
    return DateTime(Dates.UTM(Dates.value(epoch_start_dt) + convert(Int64, (1 << bits_time) - 1)))
end

def_group_1(def::TsIdDefinition) = def.group_1
def_group_2(def::TsIdDefinition) = def.group_2
def_bits_time(def::TsIdDefinition) = def.bits_time
def_bits_group_1(def::TsIdDefinition) = def.bits_group_1
def_bits_group_2(def::TsIdDefinition) = def.bits_group_2
def_bits_tail(def::TsIdDefinition) = def.bits_tail

function _make_bits_timestamp(dt::DateTime, epoch_start_ms::Int, shift_bits_time::Int)
    #@arcgcheck (SOME_EPOCH_START_2020 <= dt <= SOME_EPOCH_END_2070) "Timestamp must be in the supported epoch."
    t_offset = (Dates.value(dt) - epoch_start_ms) << shift_bits_time
    
    return t_offset
end
_make_bits_timestamp(def::TsIdDefinition, dt::DateTime) =  _make_bits_timestamp(dt, def.epoch_start_ms, def.shift_bits_time)
_make_bits_timestamp(def::TsIdDefinition) = _make_bits_timestamp(def, Dates.now())

_make_bits_group_1(mid::Int64, shift_bits_group_1::Int64) = mid << shift_bits_group_1
_make_bits_group_1(def::TsIdDefinition) = _make_bits_group_1(def.group_1, def.shift_bits_group_1)


tsid_timestamp(tsid::TT, epoch_start_ms::Int, shift_bits_time::Int) where {TT<:Integer} = DateTime(Dates.UTM((tsid >> shift_bits_time) + epoch_start_ms))
"""
    tsid_timestamp(def::TsIdDefinition, tsid::TT) where {TT<:Integer}

Extracts the timestamp from an existing `tsid`.

# Examples
```julia-repl
julia> tsid_timestamp(iddef, 489485826766409729)
2023-09-12T17:21:55.308
```
"""
tsid_timestamp(def::TsIdDefinition, tsid::TT) where {TT<:Integer} = tsid_timestamp(tsid, def.epoch_start_ms, def.shift_bits_time)
tsid_timestamp(def::TsIdDefinition, tsid::TSID) = tsid_timestamp(def, tsid.value)

"""
    tsid_group_1(def::TsIdDefinition, tsid::TT) where {TT<:Integer}

Extracts the first custom number from an existing `tsid` (e.g. a machine id).

# Examples
```julia-repl
julia> tsid_group_1(iddef, 489485826766409729)
1
```
"""
tsid_group_1(def::TsIdDefinition, tsid::TT) where {TT<:Integer} = bit_mask_int(def.type, tsid, def.bits_tail, def.bits_tail + def.bits_group_1 - 1) >> def.bits_tail
tsid_group_1(def::TsIdDefinition, tsid::TSID) = tsid_group_1(def, tsid.value)

tsid_group_2(def::TsIdDefinition, tsid::TT) where {TT<:Integer} = 0
tsid_group_2(def::TsIdDefinition, tsid::TSID) = tsid_group_2(def, tsid.value)

"""
    tsid_tail(def::TsIdDefinition, tsid::TT) where {TT<:Integer}

Extracts the tail (an increment or a random number) from an existing `tsid`.

# Examples
```julia-repl
julia> tsid_machine_tail(iddef, 489485826766409729)
1
```
"""
tsid_tail(def::TsIdDefinition, tsid::TT) where {TT<:Integer} = bit_mask_int(def.type, tsid, 0, def.bits_tail - 1)
tsid_tail(def::TsIdDefinition, tsid::TSID) = tsid_tail(def, tsid.value)

const TSID_MACHINE_INCR = Base.Threads.Atomic{Int64}(0)
reset_globabl_machine_id_increment() = Threads.atomic_xchg!(TSID_MACHINE_INCR, 0)
reset_globabl_machine_id_increment(n) = Threads.atomic_xchg!(TSID_MACHINE_INCR, n)

function _make_bits_increment(new_value::TT, tail_mod::Int) where {TT<:Integer}
    new_value = mod(new_value, tail_mod)
    TSID_MACHINE_INCR[] = new_value
    
    return new_value
end

function _make_bits_increment(def::TsIdDefinition)
    old = Threads.atomic_xchg!(TSID_MACHINE_INCR, mod(TSID_MACHINE_INCR[] + 1, def.tail_mod))
    
    return mod(old + 1, def.tail_mod)
end

function _make_bits_random(def::TsIdDefinition)
    return rand(0:def.rand_max)
end

function _make_bits_tail(def::TsIdDefinition)
    if def.tail_algorithm == :machine_increment
        return _make_bits_increment(def)
    else
        return _make_bits_random(def)
    end
end

"""
    tsid_to_string(def::TsIdDefinition, tsid::T) where T <: Integer

Creates a new UUID from a textual representation in `s` based on `text_*` flags in `def``.

# Examples
```julia-repl
julia> tsid_to_string(iddef, 489485826766409729)
"DJR0RGDG0401"
```
"""
function tsid_to_string(def::TsIdDefinition, tsid::T) where T <: Integer
    if def.text_algorithm == :crockford_base_32
        if def.type == Int64
            crockford32_encode_int64(tsid; started_init=def.text_full_width, with_checksum=def.text_with_checksum)
        elseif def.type == Int128
            crockford32_encode_int128(tsid; started_init=def.text_full_width, with_checksum=def.text_with_checksum)
        elseif def.type == UInt64
            crockford32_encode_uint64(tsid; started_init=def.text_full_width, with_checksum=def.text_with_checksum)
        elseif def.type == UInt128
            crockford32_encode_uint128(tsid; started_init=def.text_full_width, with_checksum=def.text_with_checksum)
        else
            throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm) and $(iddef.type)."))
        end
    elseif def.text_algorithm == :base_64
        if def.type == Int128
            base64encode_int128(tsid; started_init=def.text_full_width)
        else
            throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm) and $iddef.type)."))    
        end
    else
        throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm)."))
    end
end

"""
    tsid_int_from_string(def::TsIdDefinition, s::AbstractString)

Creates a new UUID from a textual representation in `s` based on `text_*` flags in `def``.

# Examples
```julia-repl
julia> tsid_from_string(iddef, "DJR0RGDG0401")
489485826766409729
```
"""
function tsid_int_from_string(def::TsIdDefinition, tsid::String)
    if def.text_algorithm == :crockford_base_32
        if def.type == Int64
            crockford32_decode_int64(tsid; with_checksum=def.text_with_checksum)
        elseif def.type == Int128
            crockford32_decode_int128(tsid; with_checksum=def.text_with_checksum)
        elseif def.type == UInt64
            crockford32_decode_uint64(tsid; with_checksum=def.text_with_checksum)
        elseif def.type == UInt128
            crockford32_decode_uint128(tsid; with_checksum=def.text_with_checksum)
        else
            throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm) and $(iddef.type)."))
        end
    elseif def.text_algorithm == :base_64
        if def.type == Int128
            base64decode_int128(tsid)
        else
            throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm) and $iddef.type)."))
        end
    else
        throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm)."))
    end
end


function tsid_generate(::Type{Val{:TsIdDefinition}}, def::TsIdDefinition)
    return _make_bits_timestamp(def) | _make_bits_group_1(def) | _make_bits_tail(def)
end


"""
    tsid_generate(def::TsIdDefinition)

Creates a new UUID based on `def`.

# Examples
```julia-repl
julia> iddef = TsIdDefinition(
    # Data type used for storage of the ID
    Int64; 
    # Number of bits used for the timestamp section.
    bits_time=41, 
    # Number of bits used for the machine section.
    bits_machine=10, 
    # Number of bits for the tail section.
    # Can be a random number or a local machine/thread specific sequence.
    bits_tail=12, 
    machine_id=1, 
    # Start of the epoch for this UUID scheme.
    # Time before that can't be represented.
    epoch_start_dt=DateTime(2020, 1, 1, 0, 0, 0, 0), 
    # Start of the epoch for this UUID scheme.
    # Time after that can't be represented.
    epoch_end_dt=DateTime(2070, 12, 31, 23, 59, 59, 999)
)
...

julia> tsid_generate(iddef)
489485826766409729
```
"""
function tsid_generate(def::TsIdDefinition)
    return tsid_generate(Val{def.name}, def)
end

"""
    tsid_generate_string(def::TsIdDefinition)

Creates a new UUID based on `def`.

# Examples
```julia-repl
julia> tsid_generate_string(iddef)
"DJR0RGDG0401"
```
"""
function tsid_generate_string(def::TsIdDefinition)
    return tsid_to_string(def, tsid_generate(def))
end
