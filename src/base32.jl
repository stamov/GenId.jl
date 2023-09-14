BASE_32_CHARS = "234567ABCDEFGHIJKLMNOPQRSTUVWXYZ"

function base32encode_int128(n::Int128; started_init::Bool=false)
    #@show n
    if n == 0 
        if started_init
            return "22222222222222222222222222"
        else
            return "2"
        end
    end
    buf = fill('.', 26)
    started = started_init
    p = 26

    mask = reinterpret(Int128, 0x70000000000000000000000000000000)
    mn = n & mask
    mni = mn >> 125 + 1
    if mn != 0 || started
        c = BASE_32_CHARS[mni]
        buf[p] = c
        p = p - 1
        started = true
    end

    mask_init = reinterpret(Int128, 0x0000000000000000000000000000001f)
    for i in 24:-1:0
        mask = mask_init << (i * 5)
        mn = n & mask
        mni = mn >> (i * 5) + 1
        if mn != 0 || started || i == 0
            c = BASE_32_CHARS[mni]
            #@show mask, mni, c, p
            buf[p] = c
            p = p - 1
            started = true
        end
    end
    #@show buf
    res = reverse(String(buf[p+1:end]))

    return res
end

const BASE_32_REVERSE_DICT = IdDict{Char,UInt64}()
l = length(BASE_32_CHARS)
for i in 1:l
    c = BASE_32_CHARS[i]
    p = findfirst(uppercase(c), BASE_32_CHARS)
    push!(BASE_32_REVERSE_DICT, c => p - 1)
end

function base32decode_int128(s_input::String)
    res::UInt128 = 0x00000000000000000000000000000000
    s26m = s_input
    #@show s26m
    ls = length(s26m)
    #@show ls
    if ls == 26
        c = s26m[1]
        #@show 1, c
        ni = BASE_32_REVERSE_DICT[c]
        #@show c, ni
        n = convert(UInt128, ni) << 125
        #@show bitstring(n)
        #@show n, typeof(n)
        res = res | n
        #@show res
        #@show bitstring(res)
        #@show res, typeof(res)
    end
    si = ls == 26 ? 2 : 1
    for i in si:ls
        c = s26m[i]
        #@show i, c
        ni = BASE_32_REVERSE_DICT[c]
        shift = (ls - i) * 5
        n = convert(UInt128, ni) << shift
        #@show bitstring(n)
        res = res | n
        #@show res
        #@show bitstring(res)
        #@show res
    end

    return convert(Int128, res)
end
