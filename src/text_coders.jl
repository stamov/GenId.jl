

struct TextCoder
    algorithm::Symbol
    bits_per_character::Int64
    dictionary_encoding::String
    dictionary_decoding::IdDict{Char,UInt64}
    pad_char::Char
    has_checksum::Bool
    use_full_width::Bool
    max_string_length::Int64
end


function make_basic_coder(; algorithm::Symbol, bits_per_character::Int64, dictionary::String, pad_char::Char='0', has_checksum::Bool=false, use_full_with::Bool=false, max_string_length::Int64=typemax(Int64))
    reverse_dictionary = IdDict{Char,UInt64}()
    len = length(dictionary)
    for i in 1:len
        c = dictionary[i]
        p = findfirst(uppercase(c), dictionary)
        push!(reverse_dictionary, c => p - 1)
    end
    return TextCoder(algorithm, bits_per_character, dictionary, reverse_dictionary, pad_char, has_checksum, use_full_with, max_string_length)
end

function make_crockford_base_32_coder(; pad_char::Char='0', has_checksum::Bool=false, use_full_with::Bool=false, max_string_length::Int64=typemax(Int64))
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

    return TextCoder(:crockford_base_32, 5, dictionary_string, reverse_dictionary, pad_char, has_checksum, use_full_with, max_string_length)
end