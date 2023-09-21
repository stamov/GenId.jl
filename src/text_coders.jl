

struct TextCoder
    algorithm::Symbol
    bits_per_character::Int64
    dictionary_encoding::String
    dictionary_decoding::IdDict{Char,UInt64}
    pad_char::Char
    separator_char::Char
    has_checksum::Bool
    use_full_width::Bool
    max_string_length::Int64
end


function make_basic_coder(; algorithm::Symbol, bits_per_character::Int64, dictionary::String, pad_char::Char='0', separator_char::Char='-', has_checksum::Bool=false, use_full_with::Bool=false, max_string_length::Int64=typemax(Int64))
    reverse_dictionary = IdDict{Char,UInt64}()
    len = length(dictionary)
    for i in 1:len
        c = dictionary[i]
        p = findfirst(c, dictionary)
        push!(reverse_dictionary, c => p - 1)
    end
    return TextCoder(algorithm, bits_per_character, dictionary, reverse_dictionary, pad_char, separator_char, has_checksum, use_full_with, max_string_length)
end

function make_crockford_base_32_coder(; pad_char::Char='0', separator_char::Char='-', has_checksum::Bool=false, use_full_with::Bool=false, max_string_length::Int64=typemax(Int64))
    dictionary = Vector{Char}(raw"0123456789ABCDEFGHJKMNPQRSTVWXYZ*~$=U")
    dictionary_string = String(dictionary)
    reverse_dictionary = IdDict{Char,UInt64}()
    for c in '0':'z'
        p = findfirst(c, dictionary_string)
        if p != nothing
            push!(reverse_dictionary, c => p - 1)
        else
            p = findfirst(uppercase(c), dictionary_string)
            if p != nothing
                push!(reverse_dictionary, c => p - 1)
            end
        end
    end

    push!(reverse_dictionary, 'i' => findfirst('1', dictionary_string) - 1)
    push!(reverse_dictionary, 'I' => findfirst('1', dictionary_string) - 1)
    push!(reverse_dictionary, 'l' => findfirst('1', dictionary_string) - 1)
    push!(reverse_dictionary, 'L' => findfirst('1', dictionary_string) - 1)
    push!(reverse_dictionary, 'o' => findfirst('0', dictionary_string) - 1)
    push!(reverse_dictionary, 'O' => findfirst('0', dictionary_string) - 1)
    push!(reverse_dictionary, '*' => findfirst('*', dictionary_string) - 1)
    push!(reverse_dictionary, '~' => findfirst('~', dictionary_string) - 1)
    push!(reverse_dictionary, '$' => findfirst('$', dictionary_string) - 1)
    push!(reverse_dictionary, '=' => findfirst('=', dictionary_string) - 1)
    push!(reverse_dictionary, 'u' => findfirst('U', dictionary_string) - 1)
    push!(reverse_dictionary, 'U' => findfirst('U', dictionary_string) - 1)

    return TextCoder(:crockford_base_32, 5, dictionary_string, reverse_dictionary, pad_char, separator_char, has_checksum, use_full_with, max_string_length)
end

@inline mask_rest(::Type{Val{4}}) = 0xf
@inline mask_rest(::Type{Val{5}}) = 0x1f
@inline mask_rest(::Type{Val{6}}) = 0x3f

function base_dictionary_encode_int128(n::Int128, coder::TextCoder)
    bitsize = 128
    base_bits_tail = div(bitsize, coder.bits_per_character) * coder.bits_per_character
    #@show base_bits_tail
    base_bits_leading = bitsize - base_bits_tail
    #@show base_bits_leading
    has_leading_char = base_bits_leading > 0
    #@show has_leading_char
    max_chars = div(bitsize, coder.bits_per_character) + 1 * has_leading_char
    #@show max_chars
    head_mask = bit_mask_uint(UInt128, base_bits_tail, 128)
    #@show bitstring(head_mask)

    #@show coder.dictionary_encoding
    started = coder.use_full_width
    if n == 0
        if started
            return coder.dictionary_encoding[1]^max_chars
        else
            return String([coder.dictionary_encoding[1]])
        end
    end
    buf = fill('.', max_chars)
    p = max_chars

    mask = reinterpret(Int128, head_mask)
    #@show bitstring(mask)
    mn = n & mask
    #@show bitstring(mn)
    mni = mn >> base_bits_tail
    #@show mni
    #@show bitstring(mni)
    if mn != 0 || started
        c = coder.dictionary_encoding[mni+1]
        #@show c
        buf[p] = c
        p = p - 1
        started = true
    end

    mask_init = convert(Int128, mask_rest(Val{coder.bits_per_character}))
    remaining_number_of_chars = p-1
    for i in remaining_number_of_chars:-1:0
        #@show i
        mask = mask_init << (i * coder.bits_per_character)
        #@show bitstring(mask)
        mn = n & mask
        #@show bitstring(mn)
        mni = mn >> (i * coder.bits_per_character)
        #@show bitstring(mni)
        #@show mni
        if mn != 0 || started || i == 0
            c = coder.dictionary_encoding[mni+1]
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

function base_dictionary_decode_int128(s_input::String, coder::TextCoder)
    #@show coder.dictionary_encoding
    #@show coder.dictionary_decoding
    res::UInt128 = zero(UInt128)
    s22m = s_input
    #@show s26m
    ls = length(s22m)
    #@show ls
    if ls == 22
        c = s22m[1]
        #@show 1, c
        ni = coder.dictionary_decoding[c]
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
        ni = coder.dictionary_decoding[c]
        #@show convert(Int, ni)
        #@show bitstring(ni)
        shift = (ls - i) * coder.bits_per_character
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
