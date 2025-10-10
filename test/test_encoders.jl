# Text encoder/decoder tests

@testset "GenId.croford32" begin
    @testset "crockford32_encode_uint64" begin
        @test crockford32_encode_uint64(0x0000000000000000) == "0"
        @test crockford32_encode_uint64(0x0000000000000000; with_checksum=true) == "00"
        @test crockford32_encode_uint64(0x0000000000000001) == "1"
        @test crockford32_encode_uint64(0xffffffffffffffff) == "FZZZZZZZZZZZZ"
        @test crockford32_encode_uint64(convert(UInt64, typemax(Int64))) == "7ZZZZZZZZZZZZ"
        @test crockford32_encode_uint64(typemax(UInt64)) == "FZZZZZZZZZZZZ"
        @test crockford32_encode_uint64(0x000000000000001e) == "Y"
        @test crockford32_encode_uint64(0x000000000000001f) == "Z"
        @test crockford32_encode_uint64(0x0000000000000020) == "10"
        @test crockford32_encode_uint64(0x0000000000000021) == "11"
        @test crockford32_encode_uint64(0x000000000000002f) == "1F"
        @test crockford32_encode_uint64(0x000000000000002f; started_init=true) == "000000000001F"
    end

    @testset "crockford32_encode_int64" begin
        @test crockford32_encode_int64(convert(Int64, 0x0000000000000000)) == "0"
        @test crockford32_encode_int64(0; with_checksum=true) == "00"
        @test crockford32_encode_int64(convert(Int64, 0x0000000000000001)) == "1"
        @test crockford32_encode_int64(convert(Int64, 0x0000000000000001); with_checksum=true) == "11"
        @test crockford32_encode_int64(convert(Int64, 0x0000000000000002)) == "2"
        @test crockford32_encode_int64(convert(Int64, 0x0000000000000002); with_checksum=true) == "22"
        @test crockford32_encode_int64(convert(Int64, 0x7fffffffffffffff)) == "7ZZZZZZZZZZZZ"
        @test crockford32_encode_int64(convert(Int64, 0x000000000000001e)) == "Y"
        @test crockford32_encode_int64(convert(Int64, 0x000000000000001f)) == "Z"
        @test crockford32_encode_int64(convert(Int64, 0x0000000000000020)) == "10"
        @test crockford32_encode_int64(convert(Int64, 0x0000000000000021)) == "11"
        @test crockford32_encode_int64(convert(Int64, 0x000000000000002f)) == "1F"
        @test crockford32_encode_int64(194; with_checksum=true) == "629"
        @test crockford32_encode_int64(398373; with_checksum=true) == "C515Z"
        @test crockford32_encode_int64(3838385658376483; with_checksum=true) == "3D2ZQ6TVC935"
        @test crockford32_encode_uint64(convert(UInt64, 18446744073709551615)) == "FZZZZZZZZZZZZ"
        @test crockford32_encode_uint64(convert(UInt64, 18446744073709551615); with_checksum=true) == "FZZZZZZZZZZZZB"
    end


    @testset "crockford32_encode_int128" begin
        @test crockford32_encode_int128(convert(Int128, 0x7fffffffffffffff0000000000000000)) == "3ZZZZZZZZZZZZG000000000000"
        @test crockford32_encode_int128(convert(Int128, 0x7fffffffffffffff0000000000000001)) == "3ZZZZZZZZZZZZG000000000001"
        @test crockford32_encode_int128(convert(Int128, 0x7fffffffffffffff7fffffffffffffff)) == "3ZZZZZZZZZZZZQZZZZZZZZZZZZ"
        @test crockford32_encode_int128(convert(Int128, typemax(Int128))) == "3ZZZZZZZZZZZZZZZZZZZZZZZZZ"
        @test crockford32_encode_int128(convert(Int128, 0x7fffffffffffffffffffffffffffffff)) == "3ZZZZZZZZZZZZZZZZZZZZZZZZZ"
        @test crockford32_encode_int128(convert(Int128, 0)) == "0"
        @test crockford32_encode_int128(convert(Int128, 0); with_checksum=true) == "00"
        @test crockford32_encode_int128(convert(Int128, 1)) == "1"
        @test crockford32_encode_int128(convert(Int128, 1); with_checksum=true) == "11"
        @test crockford32_encode_int128(convert(Int128, 0x000000000000001)) == "1"
        @test crockford32_encode_int128(convert(Int128, 0x10000000000000010000000000000000)) == "0G00000000000G000000000000"
        @test crockford32_encode_int128(convert(Int128, 0x10000000000000001000000000000000)) == "0G000000000001000000000000"
        @test crockford32_encode_int128(convert(Int128, 0x70000000000000010000000000000000)) == "3G00000000000G000000000000"
        @test crockford32_encode_int128(convert(Int128, 0x7f000000000000010000000000000000)) == "3Z00000000000G000000000000"
        @test crockford32_encode_int128(convert(Int128, 0x7f000000000000001000000000000000)) == "3Z000000000001000000000000"
        @test crockford32_encode_int128(convert(Int128, 0x00000000000000010000000000000000)) == "G000000000000"
        @test crockford32_encode_int128(convert(Int128, 0x00000000000000001000000000000000)) == "1000000000000"
        @test crockford32_encode_int128(convert(Int128, 170141183460469231722463931679029329919)) == "3ZZZZZZZZZZZZQZZZZZZZZZZZZ"
    end

    @testset "skip_dashes_13" begin
        @test GenId.skip_dashes("FZ") == "FZ"
        @test GenId.skip_dashes("FZZZZ-ZZZZ-ZZZZ") == "FZZZZZZZZZZZZ"
    end

    @testset "crockford32_decode_uint64" begin
        @test crockford32_decode_uint64("7ZZZZZZZZZZZZ") == 0x7fffffffffffffff
        @test crockford32_decode_uint64("7ZZZZZZZZZZZZ") == convert(UInt64, typemax(Int64))
        @test crockford32_decode_uint64("FZZZZZZZZZZZZ") == 0xffffffffffffffff
        @test crockford32_decode_uint64("FZZZZ-ZZZZ-ZZZZ") == 0xffffffffffffffff
    end

    @testset "crockford32_decode_int64" begin
        @test crockford32_decode_int64("11"; with_checksum=true) == 1
        @test crockford32_decode_int64("0") == 0
        @test crockford32_decode_int64("00"; with_checksum=true) == 0
        @test_throws AssertionError crockford32_decode_int64("01"; with_checksum=true) == 0
        @test crockford32_decode_int64("1") == 1
        @test crockford32_decode_int64("629"; with_checksum=true) == 194
        @test crockford32_decode_int64("62") == 194
        @test crockford32_decode_int64("DY2N") == 456789
        @test crockford32_decode_int64("C515Z"; with_checksum=true) == 398373
        @test crockford32_decode_int64("C515") == 398373
        @test crockford32_decode_int64("5ZZZZZZZZZZZZ") == 6917529027641081855
        @test crockford32_decode_int64("5bcdefghjkmnp") == 6174908412290781878
        @test crockford32_decode_int64("5BCDEFGHJKMNP") == 6174908412290781878
        @test crockford32_decode_int64("3D2ZQ6TVC93") == 3838385658376483
        @test crockford32_decode_int64("3D2-ZQ6T-VC93") == 3838385658376483
        @test crockford32_decode_int64("7ZZZZZZZZZZZZ") == 9223372036854775807
        @test crockford32_decode_int64("7ZZZZ-ZZZZ-ZZZZ") == 9223372036854775807
    end

    @testset "crockford32_decode_int128" begin
        @test length(string(9223372036854775807, base=16)) == 16
        @test crockford32_decode_uint128("07ZZZZZZZZZZZZ") == 9223372036854775807
        @test length(string(170141183460469231722463931679029329919, base=16)) == 32
        #@test crockford32_decode_int128("7ZZZZZZZZZZZZ7ZZZZZZZZZZZZ") == 170141183460469231722463931679029329919
        @test crockford32_decode_uint128("7ZZZZZZZZZZZZZZZZZZZZZZZZZ") == 0x7fffffffffffffffffffffffffffffff
        @test crockford32_decode_uint128("7ZZZZZZZZZZZZZZZZZZZZZZZZZ") == convert(UInt128, typemax(Int128))
        @test crockford32_decode_int128("00000000000000000000000001") == 1
        @test crockford32_decode_int128("000000000000000000000000011"; with_checksum=true) == 1
        @test_throws AssertionError crockford32_decode_int128("000000000000000000000000012"; with_checksum=true) == 1
        @test crockford32_decode_int128("7ZZZZZZZZZZZZZZZZZZZZZZZZZ") == typemax(Int128)
        @test_throws AssertionError crockford32_decode_int128("8ZZZZZZZZZZZZZZZZZZZZZZZZZ")
        #@test crockford32_decode_uint128("AWKHA8760HPZYHAWKHA8760HP") == 13
        #@test crockford32_decode_uint128("AWKHA8760HPZYHAWKHA8760HPAWKHA8760HPZYHAWKHA8760HP") == 13
    end

end

@testset "base32" begin
    tcf = make_basic_coder(;
        algorithm=:base_32,
        bits_per_character=5,
        dictionary="234567ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        pad_char='2',
        use_full_with=false
    )
    tct = make_basic_coder(;
        algorithm=:base_32,
        bits_per_character=5,
        dictionary="234567ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        pad_char='2',
        use_full_with=true
    )
    #@test GenId.base32encode_int128(convert(Int128, 0); started_init=true) == "2"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 0), tcf) == "2"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 0), tct) == "22222222222222222222222222"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 1), tcf) == "3"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 1), tct) == "22222222222222222222222223"
    @test GenId.base_dictionary_encode_int128(typemax(Int128), tcf) == "5ZZZZZZZZZZZZZZZZZZZZZZZZZ"
    @test GenId.base_dictionary_decode_int128("2", tcf) == 0
    @test GenId.base_dictionary_decode_int128("3", tcf) == 1
    @test GenId.base_dictionary_decode_int128("2222222222222222222222222", tcf) == 0
    @test GenId.base_dictionary_decode_int128("2222222222222222222222223", tcf) == 1
    @test GenId.base_dictionary_decode_int128("5ZZZZZZZZZZZZZZZZZZZZZZZZZ", tcf) == typemax(Int128)
    ok = true
    for i in 1:1000
        r = rand(0:typemax(Int128))
        s = GenId.base_dictionary_encode_int128(r, tcf)
        f = GenId.base_dictionary_decode_int128(s, tcf)
        if r != f
            @show :base_32, r, s, f
            ok = false
        end
    end
    @test ok == true
end

@testset "base64" begin
    tcf = make_basic_coder(;
        algorithm=:base_64,
        bits_per_character=6,
        dictionary="-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz",
        pad_char='0',
        use_full_with=false
    )
    tct = make_basic_coder(;
        algorithm=:base_64,
        bits_per_character=6,
        dictionary="-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz",
        pad_char='0',
        use_full_with=true
    )
    @test GenId.base_dictionary_encode_int128(convert(Int128, 0), tcf) == "-"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 0), tct) == "----------------------"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 1), tcf) == "0"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 1), tct) == "---------------------0"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 10), tcf) == "9"
    @test GenId.base_dictionary_encode_int128(typemax(Int128), tcf) == "0zzzzzzzzzzzzzzzzzzzzz"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 63), tcf) == "z"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 64), tcf) == "0-"
    @test GenId.base_dictionary_encode_int128(convert(Int128, 65), tcf) == "00"
    @test GenId.base_dictionary_decode_int128("-", tcf) == 0
    @test GenId.base_dictionary_decode_int128("0", tcf) == 1
    @test GenId.base_dictionary_decode_int128("A", tcf) == 11
    @test GenId.base_dictionary_decode_int128("z", tcf) == 63
    @test GenId.base_dictionary_decode_int128("0-", tcf) == 64
    @test GenId.base_dictionary_decode_int128("00", tcf) == 65
    @test GenId.base_dictionary_decode_int128("10", tcf) == 129
    @test GenId.base_dictionary_decode_int128("11", tcf) == 130
    @test GenId.base_dictionary_decode_int128("----------------------", tcf) == 0
    @test GenId.base_dictionary_decode_int128("---------------------0", tcf) == 1
    @test GenId.base_dictionary_decode_int128("0zzzzzzzzzzzzzzzzzzzzz", tcf) == typemax(Int128)

    tcf22 = make_basic_coder(;
        algorithm=:base_64,
        bits_per_character=6,
        dictionary="-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz",
        pad_char='0',
        use_full_with=false,
        max_string_length=22
    )

    #@show "!+-------------------------------------------------------------------"
    s = "DVqh4j54DWG1F0Pda-Ms"
    r = 301430602692632926610578560781911544
    @test GenId.base_dictionary_decode_int128(s, tcf22) == 301430602692632926610578560781911544

    s = "0nlFslT4egAtALWMufGCWP"
    @test GenId.base_dictionary_encode_int128(GenId.base_dictionary_decode_int128(s, tcf22), tcf22) == s
    s = "0xCp88XEq4zfFlFc7w3FnU"
    @test GenId.base_dictionary_encode_int128(GenId.base_dictionary_decode_int128(s, tcf22), tcf22) == s
    s = "WLig_yjsbi3533cN6eu6e"
    @test GenId.base_dictionary_encode_int128(GenId.base_dictionary_decode_int128(s, tcf22), tcf22) == s
    s = "QWqHmAFtCdSKybuPdaYaI"
    @test GenId.base_dictionary_encode_int128(GenId.base_dictionary_decode_int128(s, tcf22), tcf22) == s
    s = "0DIR5jE2U8o3az6DX5gUT5"
    @test GenId.base_dictionary_encode_int128(GenId.base_dictionary_decode_int128(s, tcf22), tcf22) == s

    ok = true
    for i in 1:1000
        r = rand(0:typemax(Int128))
        s = GenId.base_dictionary_encode_int128(r, tcf22)
        f = GenId.base_dictionary_decode_int128(s, tcf22)
        #@show bitstring(r), s
        if r != f
            @show :base_64, r, s, f
            @show bitstring(r)
            @show bitstring(f)
            ok = false
        end
    end
    @test ok == true

    tcf21 = make_basic_coder(;
        algorithm=:base_64,
        bits_per_character=6,
        dictionary="-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz",
        pad_char='0',
        use_full_with=false,
        max_string_length=21
    )

    s = "0DIR5jE2U8o3az6DX5gUT5"
    s21 = "DIR5jE2U8o3az6DX5gUT5"
    @test GenId.base_dictionary_encode_int128(GenId.base_dictionary_decode_int128(s, tcf21), tcf21) == s21

end
