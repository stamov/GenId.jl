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

@inline mask1_uint(::Type{UInt16}) = 0x0001
@inline mask1_uint(::Type{UInt32}) = 0x00000001
@inline mask1_uint(::Type{UInt64}) = 0x0000000000000001
@inline mask1_uint(::Type{UInt128}) = 0x00000000000000000000000000000001

@inline unsigned_int_for_signed(::Type{Int16}) = UInt16
@inline unsigned_int_for_signed(::Type{Int32}) = UInt32
@inline unsigned_int_for_signed(::Type{Int64}) = UInt64
@inline unsigned_int_for_signed(::Type{Int128}) = UInt128

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
    @argcheck 0 <= from < size DomainError
    @argcheck 0 <= to < size DomainError
    @argcheck from <= to DomainError

    return (-mask1_uint(type) >> (size - to - 1)) & ~(mask1_uint(type) << from - 1)
end

"""
    bit_mask_uint(type, v, from, to)

Masks a 64 bit unsigned integer `v` with ones between bits in postitions between `from` and `to` and zeroes for other bits. 

Counting of bits starts at 0.

# Examples
```julia-repl
julia> GenId.bit_mask_uint(UInt64, typemax(UInt64), 0,0)
0x0000000000000001
julia> GenId.bit_mask_uint(UInt64, typemax(UInt64), 12, 21)
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
    @argcheck v >= 0 DomainError
    mask = bit_mask_uint(unsigned_int_for_signed(type), from, to)
    r = convert(type, v & mask)
    
    return r
end
