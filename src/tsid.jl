
# Simplest wrapper. 
# Instead of having a comprehensive TsIdDefinition, we could have 2 ints - the one is the value and the other is the bits definitions packed in a single Int64, while calculations are derived from it.
struct TSID{T<:Integer}
    value::T
end



struct TsIdDefinition
    type::DataType
    bits_time::Int64
    bits_machine::Int64
    bits_tail::Int64
    machine_id::Int64
    tail_mod::Int64
    shift_bits_time::Int64
    shift_bits_machine::Int64
    epoch_start_dt::DateTime
    epoch_end_dt::DateTime
    epoch_start_ms::Int64
    epoch_end_ms::Int64

    function TsIdDefinition(type::Type{<:Integer}; bits_time::Int, bits_machine::Int, bits_tail::Int, machine_id::Int, epoch_start_dt::DateTime, epoch_end_dt::DateTime)
        ws = word_size(type)
        @argcheck 1 <= bits_time <= ws DomainError
        @argcheck 1 <= bits_machine <= ws DomainError
        @argcheck 1 <= bits_tail <= ws DomainError
        #@argcheck 1 <= bits_time + bits_machine + bits_tail <= ws DomainError
        @argcheck bits_time + bits_machine + bits_tail + 1 == ws DomainError
        @argcheck epoch_start_dt < epoch_end_dt DomainError
        
        return new(
            type,
            bits_time, bits_machine, bits_tail,
            machine_id, 1 << bits_tail,
            ws - bits_time - 1, bits_tail,
            epoch_start_dt, epoch_end_dt,
            Dates.value(epoch_start_dt), Dates.value(epoch_end_dt))
    end
end

def_machine_id(def::TsIdDefinition) = def.machine_id
def_thread_id(def::TsIdDefinition) = 0
def_bits_time(def::TsIdDefinition) = def.bits_time
def_bits_machine(def::TsIdDefinition) = def.bits_machine
def_bits_tail(def::TsIdDefinition) = def.bits_tail

function _make_bits_timestamp(dt::DateTime, epoch_start_ms::Int, shift_bits_time::Int)
    #@arcgcheck (SOME_EPOCH_START_2020 <= dt <= SOME_EPOCH_END_2070) "Timestamp must be in the supported epoch."
    t_offset = (Dates.value(dt) - epoch_start_ms) << shift_bits_time
    
    return t_offset
end
_make_bits_timestamp(def::TsIdDefinition, dt::DateTime) =  _make_bits_timestamp(dt, def.epoch_start_ms, def.shift_bits_time)
_make_bits_timestamp(def::TsIdDefinition) = _make_bits_timestamp(def, Dates.now())

_make_bits_machine_id(mid::Int64, shift_bits_machine::Int64) = mid << shift_bits_machine
_make_bits_machine_id(def::TsIdDefinition) = _make_bits_machine_id(def.machine_id, def.shift_bits_machine)


tsid_timestamp(tsid::TT, epoch_start_ms::Int, shift_bits_time::Int) where {TT<:Integer} = DateTime(Dates.UTM((tsid >> shift_bits_time) + epoch_start_ms))
tsid_timestamp(def::TsIdDefinition, tsid::TT) where {TT<:Integer} = tsid_timestamp(tsid, def.epoch_start_ms, def.shift_bits_time)
tsid_timestamp(def::TsIdDefinition, tsid::TSID) = tsid_timestamp(def, tsid.value)

tsid_machine_id(def::TsIdDefinition, tsid::TT) where {TT<:Integer} = bit_mask_int(def.type, tsid, def.bits_tail, def.bits_tail + def.bits_machine - 1) >> def.bits_tail
tsid_machine_id(def::TsIdDefinition, tsid::TSID) = tsid_machine_id(def, tsid.value)

tsid_thread_id(def::TsIdDefinition, tsid::TT) where {TT<:Integer} = 0
tsid_thread_id(def::TsIdDefinition, tsid::TSID) = tsid_thread_id(def, tsid.value)

tsid_machine_tail(def::TsIdDefinition, tsid::TT) where {TT<:Integer} = bit_mask_int(def.type, tsid, 0, def.bits_tail - 1)
tsid_machine_tail(def::TsIdDefinition, tsid::TSID) = tsid_machine_tail(def, tsid.value)

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

"""
    tsid_generate(def)

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
TsIdDefinition(Int64, 41, 10, 12, 1, 4096, 22, 12, Dates.DateTime("2020-01-01T00:00:00"), Dates.DateTime("2070-12-31T23:59:59.999"), 63713520000000, 65322979199999)

julia> tsid_generate(iddef)
489485826766409729
```
"""
function tsid_generate(def::TsIdDefinition)
    return _make_bits_timestamp(def) | _make_bits_machine_id(def) | _make_bits_increment(def)
end

tsid_to_string(tsid::Int64) = crockford32_encode_int64(tsid)
tsid_to_string(tsid::UInt64) = crockford32_encode_uint64(tsid)
tsid_to_string(tsid::Int128) = crockford32_encode_int128(tsid)
tsid_to_string(tsid::UInt128) = crockford32_encode_int128(convert(Int128, tsid))
# function tsid_to_string(def::TsIdDefinition)
#     return crockford32_encode_int64(tsid_generate(def))
# end

function tsid_from_string(s::String)
    return crockford32_decode_int64(s)
end
