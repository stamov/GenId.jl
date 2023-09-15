BASE_64_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/"

function base64encode_int128(n::Int128; started_init::Bool=false)
    #@show n
    #@show bitstring(n)
    #@show n
    if n == 0 
        if started_init
            return "0000000000000000000000"
        else
            return "0"
        end
    end
    buf = fill('.', 22)
    started = started_init
    p = 22

    mask = reinterpret(Int128, 0xc0000000000000000000000000000000)
    #@show bitstring(mask)
    mn = n & mask
    #@show bitstring(mn)
    mni = mn >> 126
    #@show mni
    #@show bitstring(mni)
    if mn != 0 || started
        c = BASE_64_CHARS[mni+1]
        #@show c
        buf[p] = c
        p = p - 1
        started = true
    end

    mask_init = reinterpret(Int128, 0x0000000000000000000000000000003f)
    for i in 20:-1:0
        mask = mask_init << (i * 6)
        #@show bitstring(mask)
        mn = n & mask
        #@show bitstring(mn)
        mni = mn >> (i * 6)
        #@show bitstring(mni)
        #@show mni
        if mn != 0 || started || i == 0
            c = BASE_64_CHARS[mni+1]
            #@show mni+1, c
            #@show c
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

const BASE_64_REVERSE_DICT = IdDict{Char,UInt128}()
l = length(BASE_64_CHARS)
for i in 1:l
    c = BASE_64_CHARS[i]
    p = findfirst(c, BASE_64_CHARS)
    push!(BASE_64_REVERSE_DICT, c => convert(Int128, p) - 1)
end

function base64decode_int128(s_input::String)
    res::UInt128 = 0x00000000000000000000000000000000
    s22m = s_input
    #@show s26m
    ls = length(s22m)
    #@show ls
    if ls == 22
        c = s22m[1]
        #@show 1, c
        ni = BASE_64_REVERSE_DICT[c]
        #@show c, ni
        n = convert(UInt128, ni) << 126
        #@show bitstring(n)
        #@show n, typeof(n)
        res = res | n
        #@show res
        #@show bitstring(res)
        #@show res, typeof(res)
    end
    si = ls == 22 ? 2 : 1
    for i in si:ls
        c = s22m[i]
        #@show i, c
        ni = BASE_64_REVERSE_DICT[c]
        #@show convert(Int, ni)
        #@show bitstring(ni)
        shift = (ls - i) * 6
        #@show shift
        n = convert(UInt128, ni) << shift
        #@show n
        #@show bitstring(n)
        res = res | n
        #@show bitstring(res)
        #@show res
        #@show bitstring(res)
        #@show res
    end

    return convert(Int128, res)
end
