
# Code for the bit fiddlings is written in almost SSA style for easier debugging.

const CF32_UPPERCASE_ENCODING_CHECKSUM = Vector{Char}(raw"0123456789ABCDEFGHJKMNPQRSTVWXYZ*~$=U")

"""
    crockford32_encode_uint64(n::UInt64; started_init::Bool=false, with_checksum::Bool=false)

Encodes an UInt64 `n` using Crockford Base 32.

If `with_checksum` is set to `true`, adds a modulo 37 checksum character at the end.

If `started_init` is set to `true`, pads the string to the left to 13(14 when a checksum is generated) characters.

# Examples
```julia-repl
julia> crockford32_encode_uint64(0x000000000000001f)
"Z"

julia> crockford32_encode_uint64(0x000000000000001f; with_checksum=true)
"ZZ"

julia> crockford32_encode_uint64(0x000000000000001f; with_checksum=true, started_init=true)
"000000000000ZZ"
```
"""
function crockford32_encode_uint64(n::UInt64; started_init::Bool=false, with_checksum::Bool=false)
    started = started_init
    buf = with_checksum ? fill('.', 14) : fill('.', 13)
    p = with_checksum ? 14 : 13
    if n == 0x0000000000000000 && !started
        if with_checksum
            return "00"
        else
            return "0"
        end
    else
        mask = 0xf000000000000000
        mn = n & mask
        mni = mn >> 60 + 1
        if mn != 0x000000000000000 || started
            c = CF32_UPPERCASE_ENCODING_CHECKSUM[mni]
            buf[p] = c
            p = p - 1
            started = true
        end

        mask_init = 0x000000000000001f
        for i in 11:-1:0
            mask = mask_init << (i * 5)
            mn = n & mask
            mni = mn >> (i * 5) + 1
            if mn != 0x000000000000000 || started
                c = CF32_UPPERCASE_ENCODING_CHECKSUM[mni]
                buf[p] = c
                p = p - 1
                started = true
            end
        end
    end

    if with_checksum
        c = CF32_UPPERCASE_ENCODING_CHECKSUM[mod(n, 37)+1]
        buf[p] = c
        p = p - 1
    end

    res = reverse(String(buf[p+1:end]))
    
    return res
end

"""
    crockford32_encode_int64(n::UInt64; started_init::Bool=false, with_checksum::Bool=false)

Encodes an Int64 `n` using Crockford Base 32.

If `with_checksum` is set to `true`, adds a modulo 37 checksum character at the end.

If `started_init` is set to `true`, pads the string to the left to 13(14 when a checksum is generated) characters.

# Examples
```julia-repl
julia> crockford32_encode_int64(31)
"Z"

julia> crockford32_encode_int64(31; with_checksum=true)
"ZZ"

julia> crockford32_encode_int64(31; with_checksum=true, started_init=true)
"000000000000ZZ"
```
"""
function crockford32_encode_int64(n::Int64; started_init::Bool=false, with_checksum::Bool=false)
    @assert n >= 0 "Can't have negative numbers for Int64 conversion in crockford32_encode_int64."
    buf = with_checksum ? fill('.', 14) : fill('.', 13)
    p = with_checksum ? 14 : 13
    started = started_init
    if n == 0 && !started
        if with_checksum
            return "00"
        else
            return "0"
        end
    else
        mask = reinterpret(Int64, 0x7000000000000000)
        mn = n & mask
        mni = mn >> 60 + 1
        if mn != 0 || started
            c = CF32_UPPERCASE_ENCODING_CHECKSUM[mni]
            buf[p] = c
            p = p - 1
            started = true
        end

        mask_init = reinterpret(Int64, 0x000000000000001f)
        for i in 11:-1:0
            mask = mask_init << (i * 5)
            mn = n & mask
            mni = mn >> (i * 5) + 1
            if mn != 0 || started
                c = CF32_UPPERCASE_ENCODING_CHECKSUM[mni]
                buf[p] = c
                p = p - 1
                started = true
            end
        end
    end

    if with_checksum
        c = CF32_UPPERCASE_ENCODING_CHECKSUM[mod(n, 37)+1]
        buf[p] = c
        p = p - 1
    end

    res = reverse(String(buf[p+1:end]))
    
    return res
end


function crockford32_encode_int128(n::Int128; started_init::Bool=false, with_checksum::Bool=false)
    @assert n >= 0 "Can't have negative numbers for Int64 conversion in crockford32_encode_int64."
    buf = with_checksum ? fill('.', 27) : fill('.', 26)
    p = with_checksum ? 27 : 26
    started = started_init
    if n == 0 && !started
        if with_checksum
            return "00"
        else
            return "0"
        end
    else
        mask = reinterpret(Int128, 0x70000000000000000000000000000000)
        mn = n & mask
        mni = mn >> 125 + 1
        if mn != 0 || started
            c = CF32_UPPERCASE_ENCODING_CHECKSUM[mni]
            buf[p] = c
            p = p - 1
            started = true
        end

        mask_init = reinterpret(Int128, 0x0000000000000000000000000000001f)
        for i in 24:-1:0
            mask = mask_init << (i * 5)
            mn = n & mask
            mni = mn >> (i * 5) + 1
            if mn != 0 || started
                c = CF32_UPPERCASE_ENCODING_CHECKSUM[mni]
                buf[p] = c
                p = p - 1
                started = true
            end
        end
    end

    if with_checksum
        c = CF32_UPPERCASE_ENCODING_CHECKSUM[mod(n, 37)+1]
        buf[p] = c
        p = p - 1
    end

    res = reverse(String(buf[p+1:end]))

    return res
end

# function crockford32_encode_int128(high::Int64, low::UInt64)
#     if high == 0
#         return crockford32_encode_uint64(low, started_init=false)
#     else
#         return crockford32_encode_int64(high, started_init=false) * crockford32_encode_uint64(low, started_init=true)
#     end
# end

# function crockford32_encode_int128(n::Int128)
#     #@show n
#     high = convert(Int64, (n & 0x7fffffffffffffff0000000000000000) >> 64)
#     #@show high, typeof(high), bitstring(high)
#     low = convert(UInt64, n & 0x0000000000000000ffffffffffffffff)
#     #@show low, typeof(low), bitstring(low)
#     return crockford32_encode_int128(high, low)
# end

const CF32_UPPERCASE_ENCODING_STR = String(CF32_UPPERCASE_ENCODING_CHECKSUM)
const CF32_REVERSE_DICT = IdDict{Char,UInt64}()

for c in '0':'z'
    p = findfirst(c, CF32_UPPERCASE_ENCODING_STR)
    if p != nothing
        push!(CF32_REVERSE_DICT, c => p - 1)
    else
        p = findfirst(uppercase(c), CF32_UPPERCASE_ENCODING_STR)
        if p != nothing
            push!(CF32_REVERSE_DICT, c => p - 1)
        end
    end
end

push!(CF32_REVERSE_DICT, 'i' => findfirst('1', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, 'I' => findfirst('1', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, 'l' => findfirst('1', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, 'L' => findfirst('1', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, 'o' => findfirst('0', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, 'O' => findfirst('0', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, '*' => findfirst('*', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, '~' => findfirst('~', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, '$' => findfirst('$', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, '=' => findfirst('=', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, 'u' => findfirst('U', CF32_UPPERCASE_ENCODING_STR) - 1)
push!(CF32_REVERSE_DICT, 'U' => findfirst('U', CF32_UPPERCASE_ENCODING_STR) - 1)

# for k in sort(collect(keys(CF32_REVERSE_DICT)))
#     println(k, " => ", CF32_REVERSE_DICT[k])
# end

# skip_dashes_13_0(s::String) = replace.(s, ['-'] => "")

skip_dashes_1(s::String) = filter.(c -> c != '-', s)

# function skip_dashes_13_2(s::String)
#     s13m = Vector{Char}(undef, 13)
#     tp = 0
#     @inbounds for c in s
#         if c != '-'
#             tp = tp + 1
#             s13m[tp] = c
#         end
#     end
    
#     return @view s13m[1:tp] # returning a @view skips the whole machinery for copying/loops of a tiny vector slice
# end

# function skip_dashes_13_3(s::String)
#     scs = codeunits(s)
#     s13m = Vector{UInt8}(undef, 13)
#     tp = 0
#     @inbounds for cu in scs
#         if cu != 0x2d # '-'
#             tp = tp + 1
#             s13m[tp] = cu
#         end
#     end
    
#     return String(s13m)[1:tp]
# end

#skip_dashes_13(s::String) = skip_dashes_13_3(s)
skip_dashes(s::String) = skip_dashes_1(s)

"""
    crockford32_decode_uint64(s_input::String; skip_fn=skip_dashes_13_1, with_checksum=false)

Decodes a Crockford Base 32 encoded text into an UInt64.

If `with_checksum` is set to `true`, parses the last character from the text as a modulo 37 checksum.

# Examples
```julia-repl
julia> crockford32_decode_uint64("Z")
0x000000000000001f

julia> crockford32_decode_uint64("ZZ"; with_checksum=true)
0x000000000000001f

julia> crockford32_decode_uint64("Z-Z"; with_checksum=true)
0x000000000000001f
```
"""
function crockford32_decode_uint64(s_input::String; skip_fn=skip_dashes_1, with_checksum=false)
    res = 0x0000000000000000
    s13m = skip_fn(s_input)
    ls = length(s13m)
    checksum_char = with_checksum ? s13m[ls] : '.'
    if with_checksum
        ls = ls - 1
    end
    if ls == 13
        c = s13m[1]
        ni = CF32_REVERSE_DICT[c]
        n = ni << 60
        res = res | n
    end
    si = ls == 13 ? 2 : 1
    for i in si:ls
        c = s13m[i]
        ni = CF32_REVERSE_DICT[c]
        shift = (ls - i) * 5
        n = ni << shift
        res = res | n
    end
    if with_checksum
        checksum_char_idx = CF32_REVERSE_DICT[checksum_char]
        modulo = mod(res, 37)
        if modulo != checksum_char_idx
            throw(ArgumentError("Checksum $checksum_char doesn't match the parsed number of $res with modulo 37 of $modulo."))
        end
    end
    #@assert res >= 0 "Can't have negative numbers for Int64 conversion."
    
    return res
end


function crockford32_decode_uint128(s_input::String; skip_fn=skip_dashes_1, with_checksum=false)
    #@show "crockford32_decode_uint128", s_input
    res::UInt128 = 0x00000000000000000000000000000000
    s26m = skip_fn(s_input)
    #@show s26m
    ls = length(s26m)
    checksum_char = with_checksum ? s26m[ls] : '.'
    if with_checksum
        ls = ls - 1
    end
    #@show ls
    if ls == 26
        c = s26m[1]
        ni = CF32_REVERSE_DICT[c]
        #@show c, ni
        n = convert(UInt128, ni) << 124
        #@show n, typeof(n)
        res = res | n
        #@show res, typeof(res)
    end
    si = ls == 26 ? 2 : 1
    for i in si:ls
        c = s26m[i]
        ni = CF32_REVERSE_DICT[c]
        shift = (ls - i) * 5
        n = convert(UInt128, ni) << shift
        res = res | n
        #@show res
    end
    if with_checksum
        checksum_char_idx = CF32_REVERSE_DICT[checksum_char]
        modulo = mod(res, 37)
        if modulo != checksum_char_idx
            throw(ArgumentError("Checksum $checksum_char doesn't match the parsed number of $res with modulo 37 of $modulo."))
        end
    end
    #@assert res >= 0 "Can't have negative numbers for Int64 conversion."

    return res
end
#bitstring(typemax(Int128))
#bitstring(typemax(UInt128))
#convert(UInt128, typemax(Int128))
"""
    crockford32_decode_int64(s_input::String; skip_fn=skip_dashes_13_1, with_checksum=false)

Decodes a Crockford Base 32 encoded text into an Int64.

If `with_checksum` is set to `true`, parses the last character from the text as a modulo 37 checksum.

# Examples
```julia-repl
julia> crockford32_decode_int64("Z")
31

julia> crockford32_decode_int64("ZZ"; with_checksum=true)
31

julia> crockford32_decode_int64("Z-Z"; with_checksum=true)
31
```
"""
function crockford32_decode_int64(s::String; with_checksum=false)
    r = reinterpret(Int64, crockford32_decode_uint64(s, with_checksum=with_checksum))
    @assert r >= 0 "Decode_int64 not yet implemented without uint64 and should not support negative results."
    return r
end

# function crockford32_decode_int128(s::String)
#     ls = length(s)
#     @assert 1 <= ls <= 26 "Can't convert to Int128 empty or more than 26 characters."
#     if 1 <= ls <= 13
#         return convert(Int128, crockford32_decode_int64(s))
#     else
#         low = s[ls-13+1:end]
#         high = s[1:ls-13]
#         return convert(Int128, crockford32_decode_int64(high)) << 64 + crockford32_decode_int64(low)
#     end
# end
