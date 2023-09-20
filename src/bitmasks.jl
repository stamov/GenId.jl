# TODO switch to 1-based indexing in bit_mask_*

#@inline word_size(::Type{Int8}) = 8
@inline word_size(::Type{Int16}) = 16
@inline word_size(::Type{Int32}) = 32
@inline word_size(::Type{Int64}) = 64
@inline word_size(::Type{Int128}) = 128
#@inline word_size(::Type{UInt8}) = 8
@inline word_size(::Type{UInt16}) = 16
@inline word_size(::Type{UInt32}) = 32
@inline word_size(::Type{UInt64}) = 64
@inline word_size(::Type{UInt128}) = 128

@inline mask1(type) = one(type)

@inline unsigned_int_for_signed(::Type{Int16}) = UInt16
@inline unsigned_int_for_signed(::Type{Int32}) = UInt32
@inline unsigned_int_for_signed(::Type{Int64}) = UInt64
@inline unsigned_int_for_signed(::Type{Int128}) = UInt128
@inline unsigned_int_for_signed(::Type{UInt16}) = UInt16
@inline unsigned_int_for_signed(::Type{UInt32}) = UInt32
@inline unsigned_int_for_signed(::Type{UInt64}) = UInt64
@inline unsigned_int_for_signed(::Type{UInt128}) = UInt128

"""
    bit_mask_uint(from, to)

Creates a 64 bit unsigned integer mask, with ones between bits in postitions between `from` and `to` and zeroes for other bits. 

Counting of bits starts at 0.

# Examples
```julia-repl
julia> bit_mask_uint(0,0)
0x0000000000000000000000000000000000000000000000000000000000000001
julia> bit_mask_uint(63,63)
0x1000000000000000000000000000000000000000000000000000000000000000
julia> bit_mask_uint(12,21)
0x0000000000000000000000000000000000000000001111111111000000000000
```
"""
function bit_mask_uint(type::Type{<:Unsigned}, from, to)
    size = word_size(type)
    #@argcheck 0 <= from < size AssertionError
    #@argcheck 0 <= to < size AssertionError
    @argcheck from <= to AssertionError

    return (-mask1(type) >> (size - to - 1)) & ~(mask1(type) << from - 1)
end

"""
    bit_mask_uint(type, v, from, to)

Masks a 64 bit unsigned integer `v` with ones between bits in postitions between `from` and `to` and zeroes for other bits. 

Counting of bits starts at 0.

# Examples
```julia-repl
julia> bit_mask_uint(UInt64, typemax(UInt64), 0,0)
0x0000000000000001
julia> bit_mask_uint(UInt64, typemax(UInt64), 12, 21)
0x00000000003ff000
```
"""
function bit_mask_uint(type, v, from, to)
    mask = bit_mask_uint(type, from, to)
    return v & mask
end

"""
    bit_mask_int(type, v, from, to)

Applies a 64 bit signed integer mask to a value `v`, with ones between bits in postitions between `from` and `to` and zeroes for other bits. 

Counting of bits starts at 0.

`v` can't be a negative integer.

# Examples
```julia-repl
julia> bit_mask_int(Int64, typemax(Int64), 0,0)
1
julia> bit_mask_int(Int64, typemax(Int64), 0,1)
3
```
"""
function bit_mask_int(type, v, from, to)
    @argcheck v >= 0 AssertionError
    mask = bit_mask_uint(unsigned_int_for_signed(type), from, to)
    r = convert(type, v & mask)
    
    return r
end


abstract type AbstractField end

struct GeneratedField <: AbstractField
    type::DataType
    name::Symbol
    bits_offset::Int64 # starting at 0
    bits_length::Int64
end

abstract type AbstractGeneratedField <: AbstractField end

struct TimestampField{T} <: AbstractGeneratedField
    type::DataType
    name::Symbol
    bits_offset::Int64 # starting at 0
    bits_length::Int64
    epoch_start_dt::DateTime
    epoch_start_ms::Int64

    function TimestampField(type, bits_offset, bits_length, epoch_start_dt)
        epoch_start_ms = Dates.value(epoch_start_dt)
        new{type}(type, :timestamp, bits_offset, bits_length, epoch_start_dt, epoch_start_ms)
    end
end
generate_field_value(field::TimestampField{T} where {T}) = Dates.value(Dates.now()) - field.epoch_start_ms

struct RandomField{T} <: AbstractGeneratedField
    type::DataType
    name::Symbol
    bits_offset::Int64 # starting at 0
    bits_length::Int64

    RandomField(type, bits_offset, bits_length) = new{type}(type, :random, bits_offset, bits_length)
end
generate_field_value(field::RandomField{T} where {T}) = rand(0:one(field.type) << field.bits_length)


const TSID_MACHINE_INCR = Base.Threads.Atomic{Int64}(0)
reset_globabl_machine_id_increment() = Threads.atomic_xchg!(TSID_MACHINE_INCR, 0)
reset_globabl_machine_id_increment(n) = Threads.atomic_xchg!(TSID_MACHINE_INCR, n)

struct MachineSequenceField{T} <: AbstractGeneratedField
    type::DataType
    name::Symbol
    bits_offset::Int64 # starting at 0
    bits_length::Int64

    MachineSequenceField(type, bits_offset, bits_length) = new{type}(type, :machine_sequence, bits_offset, bits_length)
end

function _make_bits_increment(field::MachineSequenceField{T} where {T})
    # TODO reset on each new millisecond
    mod_divisor = one(field.type) << field.bits_length
    # TODO check if this is fully atomic, as TSID_MACHINE_INCR[] reads before xchg
    old = Threads.atomic_xchg!(TSID_MACHINE_INCR, mod(TSID_MACHINE_INCR[] + 1, mod_divisor))
    return mod(old + 1, mod_divisor)
end

function generate_field_value(field::MachineSequenceField{T} where {T})
    return _make_bits_increment(field)
end

struct ConstantField{T} <: AbstractField
    type::DataType
    name::Symbol
    bits_offset::Int64 # starting at 0
    bits_length::Int64
    value::T

    ConstantField(type, name, bits_offset, bits_length, value) = new{type}(type, name, bits_offset, bits_length, value)
end
generate_field_value(field::ConstantField{T} where {T}) = field.value


function ProcessIdField(type::DataType, bits_offset::Int64, bits_length::Int64)
    pid = bit_mask_uint(UInt16, getpid(), 0, 15)
    ConstantField(type, :process_id, bits_offset, bits_length, pid)
end

function extract_value_from_bits(field, ctype::DataType, v::TT where {TT<:Integer})
    #@show bitstring(v), typeof(v)
    umask = bit_mask_uint(unsigned_int_for_signed(ctype), field.bits_offset, field.bits_offset + field.bits_length - 1)
    #@show bitstring(umask), typeof(umask)
    masked = v & umask
    #@show bitstring(masked), typeof(masked)
    shifted = masked >> field.bits_offset
    #@show bitstring(shifted), typeof(shifted)
    converted = convert(field.type, shifted)
    #@show bitstring(converted), typeof(converted)
    return converted
end

function implant_value_into_int(container::TC, field::AbstractField, new_value::TV) where {TV<:Integer,TC<:Integer}
    #@show "implant_value_into_int", new_value
    #@show bitstring(container), typeof(container)
    #@show bitstring(new_value), typeof(new_value)
    #@show field.bits_offset
    shifted = convert(TC, new_value) << field.bits_offset
    #@show bitstring(shifted), typeof(shifted)
    new_container = container | shifted
    #@show bitstring(new_container), typeof(new_container)
    #converted = convert(TC, new_container)
    converted = new_container
    #@show bitstring(converted), typeof(converted)
    return converted
end

abstract type TSIDAbstractContainer end

struct TSIDGenericContainer <: TSIDAbstractContainer
    type::DataType
    name::Symbol
    fields::Vector{AbstractField}
    text_coder::TextCoder
    #text_algorithm::Symbol
    #text_with_checksum::Bool
    #text_full_width::Bool
    #text_max_length::Int

    function TSIDGenericContainer(
        type, 
        name, 
        fields,
        text_coder 
    )
        new(type, name, fields, text_coder) #, text_algorithm, text_with_checksum, text_full_width, text_max_length)
    end
end

# TODO convert to a macro per UUID type
function tsid_generate(def::TSIDGenericContainer)
    #@show "tsid_generate"
    ctr = zero(def.type)
    #@show bitstring(ctr), typeof(ctr)
    for field in def.fields
        #@show "generating", field
        fv = generate_field_value(field)
        #@show bitstring(fv), typeof(fv), fv
        ctr = implant_value_into_int(ctr, field, fv)
        #@show bitstring(ctr), typeof(ctr), ctr
    end
    return ctr
end

# TODO make a macro pointing to the exact field without iteration
function tsid_getfield_value(definition::TSIDGenericContainer, name, external_value)
    for field in definition.fields
        if field.name == name
            return extract_value_from_bits(field, definition.type, external_value)
        end
    end
    throw(AssertionError("Field $name doesn't exist in definition $definition."))
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
function tsid_to_string(def::TSIDGenericContainer, tsid::T) where {T<:Integer}
    r = ""
    tc = def.text_coder
    if tc.algorithm == :crockford_base_32
        if def.type == Int64
            r = crockford32_encode_int64(tsid; started_init=tc.use_full_width, with_checksum=tc.has_checksum)
        elseif def.type == Int128
            r = crockford32_encode_int128(tsid; started_init=tc.use_full_width, with_checksum=tc.has_checksum)
        elseif def.type == UInt64
            r = crockford32_encode_uint64(tsid; started_init=tc.use_full_width, with_checksum=tc.has_checksum)
        elseif def.type == UInt128
            r = crockford32_encode_uint128(tsid; started_init=tc.use_full_width, with_checksum=tc.has_checksum)
        else
            throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm) and $(iddef.type)."))
        end
    elseif tc.algorithm == :base_64
        if def.type == Int128
            r = base64encode_int128(tsid; started_init=tc.use_full_width)
        else
            throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm) and $iddef.type)."))
        end
    elseif tc.algorithm == :base_32
        if def.type == Int128
            r = base32encode_int128(tsid; started_init=tc.use_full_width)
        else
            throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm) and $iddef.type)."))
        end
    elseif tc.algorithm == :base_32_hex
        if def.type == Int128
            r = base32hexencode_int128(tsid; started_init=tc.use_full_width)
        else
            throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm) and $iddef.type)."))
        end
    else
        throw(AssertionError("No tsid_to_string implementation for $(iddef.text_algorithm)."))
    end
    if length(r) > tc.max_string_length
        r = last(r, tc.max_string_length)
    end
    return r
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
function tsid_int_from_string(def::TSIDGenericContainer, tsid::String)
    tc = def.text_coder
    if tc.algorithm == :crockford_base_32
        if def.type == Int64
            crockford32_decode_int64(tsid; with_checksum=tc.has_checksum)
        elseif def.type == Int128
            crockford32_decode_int128(tsid; with_checksum=tc.has_checksum)
        elseif def.type == UInt64
            crockford32_decode_uint64(tsid; with_checksum=tc.has_checksum)
        elseif def.type == UInt128
            crockford32_decode_uint128(tsid; with_checksum=tc.has_checksum)
        else
            throw(AssertionError("No tsid_to_string implementation for $(tc.algorithm) and $(iddef.type)."))
        end
    elseif tc.algorithm == :base_64
        if def.type == Int128
            base64decode_int128(tsid)
        else
            throw(AssertionError("No tsid_to_string implementation for $(tc.algorithm) and $iddef.type)."))
        end
    else
        throw(AssertionError("No tsid_to_string implementation for $(tc.algorithm)."))
    end
end

function tsid_generate_string(def::TSIDGenericContainer)
    return tsid_to_string(def, tsid_generate(def))
end

