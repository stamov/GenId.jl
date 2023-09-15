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
    @argcheck 0 <= from < size AssertionError
    @argcheck 0 <= to < size AssertionError
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
end
generate_field_value(field::TimestampField{T} where {T}) = Dates.value(Dates.now())

struct RandomField{T} <: AbstractGeneratedField
    type::DataType
    name::Symbol
    bits_offset::Int64 # starting at 0
    bits_length::Int64
end
generate_field_value(field::RandomField{T} where {T}) = rand(0:one(field.type) << field.bits_length)

struct ConstantField{T} <: AbstractField
    type::DataType
    name::Symbol
    bits_offset::Int64 # starting at 0
    bits_length::Int64
    value::T
end
generate_field_value(field::ConstantField{T} where {T}) = field.value


function extract_value_from_bits(field::AbstractField, v::TT) where {TT<:Integer}
    #@show bitstring(v), typeof(v)
    umask = bit_mask_uint(unsigned_int_for_signed(field.type), field.bits_offset, field.bits_offset + field.bits_length - 1)
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
end

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
