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

push!(BASE_32_REVERSE_DICT, '2' => 0)
push!(BASE_32_REVERSE_DICT, '3' => 1)
push!(BASE_32_REVERSE_DICT, '4' => 2)
push!(BASE_32_REVERSE_DICT, '5' => 3)
push!(BASE_32_REVERSE_DICT, '6' => 4)
push!(BASE_32_REVERSE_DICT, '7' => 5)
push!(BASE_32_REVERSE_DICT, 'A' => 6)
push!(BASE_32_REVERSE_DICT, 'B' => 7)
push!(BASE_32_REVERSE_DICT, 'C' => 8)
push!(BASE_32_REVERSE_DICT, 'D' => 9)
push!(BASE_32_REVERSE_DICT, 'E' => 10)
push!(BASE_32_REVERSE_DICT, 'F' => 11)
push!(BASE_32_REVERSE_DICT, 'G' => 12)
push!(BASE_32_REVERSE_DICT, 'H' => 13)
push!(BASE_32_REVERSE_DICT, 'I' => 14)
push!(BASE_32_REVERSE_DICT, 'J' => 15)
push!(BASE_32_REVERSE_DICT, 'K' => 16)
push!(BASE_32_REVERSE_DICT, 'L' => 17)
push!(BASE_32_REVERSE_DICT, 'M' => 18)
push!(BASE_32_REVERSE_DICT, 'N' => 19)
push!(BASE_32_REVERSE_DICT, 'O' => 20)
push!(BASE_32_REVERSE_DICT, 'P' => 21)
push!(BASE_32_REVERSE_DICT, 'Q' => 22)
push!(BASE_32_REVERSE_DICT, 'R' => 23)
push!(BASE_32_REVERSE_DICT, 'S' => 24)
push!(BASE_32_REVERSE_DICT, 'T' => 25)
push!(BASE_32_REVERSE_DICT, 'U' => 26)
push!(BASE_32_REVERSE_DICT, 'V' => 27)
push!(BASE_32_REVERSE_DICT, 'W' => 28)
push!(BASE_32_REVERSE_DICT, 'X' => 29)
push!(BASE_32_REVERSE_DICT, 'Y' => 30)
push!(BASE_32_REVERSE_DICT, 'Z' => 31)

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
