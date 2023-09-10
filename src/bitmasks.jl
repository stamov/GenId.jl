
# const C32_1::UInt8  = 0x0001
# const C32_1::UInt16 = 0x0001
# const C32_1::UInt32 = 0x00000001
# const C64_1::UInt64 = 0x0000000000000001

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


"""
    bit_mask_uint64(from, to)

Creates a 64 bit unsigned integer mask, with ones between bits in postitions between `from` and `to` and zeroes for other bits. Counting of bits starts at 1.

# Examples
```julia-repl
julia> bit_mask_uint64(0,0)
0x0000000000000000000000000000000000000000000000000000000000000001
julia> bit_mask_uint64(63,63)
0x1000000000000000000000000000000000000000000000000000000000000000
julia> bit_mask_uint64(12,21)
0x0000000000000000000000000000000000000000001111111111000000000000
```
"""
function bit_mask_uint(type::Type{<:Integer}, from, to)
    size = word_size(type)
    #@show size, from, to
    #@argcheck ispow2(size) DomainError
    #@argcheck 8 <= size <= 128 DomainError
    @argcheck 0 <= from < size DomainError
    @argcheck 0 <= to < size DomainError
    @argcheck from <= to DomainError
    
    return (-0x0000000000000001 >> (size - to - 1)) & ~(0x0000000000000001 << from - 1)
end

#bit_mask_int(from, to) = convert(Int64, bit_mask_uint(from, to))

function bit_mask_int(type, v, from, to)
    mask = bit_mask_uint(type, from, to)
    r = convert(type, v & mask)
    
    return r
end
