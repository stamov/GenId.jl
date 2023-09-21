module GenIdTest

using Dates
using Test
using Aqua

using GenId

@testset "GenId" begin

    @testset "GenId.quality" begin
        # Aqua.test_all(GenId; deps_compat=false)
        Aqua.test_all(GenId)
    end

    SOME_EPOCH_START_2020 = DateTime(2020, 1, 1, 0, 0, 0, 0)
    SOME_EPOCH_START_VALUE_2020 = Dates.value(SOME_EPOCH_START_2020)
    #print(SOME_EPOCH_START_VALUE_2020)
    SOME_EPOCH_END_2070 = DateTime(2070, 12, 31, 23, 59, 59, 999)
    SOME_EPOCH_END_VALUE_2070 = Dates.value(SOME_EPOCH_END_2070)
    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE = MachineSequenceField(Int64, 0, 12)

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

    @testset "GenId.bit_mask" begin
        @test GenId.word_size(Int16) == GenId.word_size(UInt16) == 16
        @test GenId.word_size(Int32) == GenId.word_size(UInt32) == 32
        @test GenId.word_size(Int64) == GenId.word_size(UInt64) == 64
        @test GenId.word_size(Int128) == GenId.word_size(UInt128) == 128
        @test GenId.mask1(UInt128) == convert(UInt128, 1)
        @test GenId.unsigned_int_for_signed(Int16) == UInt16
        @test GenId.unsigned_int_for_signed(Int32) == UInt32
        @test GenId.unsigned_int_for_signed(Int64) == UInt64
        @test GenId.unsigned_int_for_signed(Int128) == UInt128
        @test bitstring(bit_mask_uint(UInt64, 0, 0)) == "0000000000000000000000000000000000000000000000000000000000000001"
        @test bitstring(bit_mask_uint(UInt64, 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
        @test bitstring(bit_mask_uint(UInt64, 63, 63)) == "1000000000000000000000000000000000000000000000000000000000000000"
        @test bitstring(bit_mask_uint(UInt64, typemax(UInt64), 0, 0)) == "0000000000000000000000000000000000000000000000000000000000000001"
        @test bitstring(bit_mask_uint(UInt64, typemax(UInt64), 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
        @test bitstring(bit_mask_int(Int64, typemax(Int64), 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
        @test_throws AssertionError bitstring(GenId.bit_mask_int(Int64, -1, 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
    end

    @testset "MachineSequenceField" begin
        GenId.reset_globabl_machine_id_increment(4093)
        f = GenId.MachineSequenceField(Int64, 0, 12)
        @test GenId.generate_field_value(f) == 4094
        @test GenId.generate_field_value(f) == 4095
        @test GenId.generate_field_value(f) == 0
        @test GenId.generate_field_value(f) == 1

        GenId.reset_globabl_machine_id_increment()
        @test GenId.generate_field_value(f) == 1
        @test GenId.generate_field_value(f) == 2
    end

    @testset "GenId.GeneratedField" begin
        f1 = GeneratedField(Int64, :hello, 1, 2)

        @test typeof(extract_value_from_bits(f1, Int64, 0)) == Int64
        #@show bitstring(0)
        @test extract_value_from_bits(f1, Int64, 0) == 0
        #@show bitstring(1)
        @test extract_value_from_bits(f1, Int64, 1) == 0
        #@show bitstring(2)
        @test extract_value_from_bits(f1, Int64, 2) == 1
        #@show bitstring(3)
        @test extract_value_from_bits(f1, Int64, 3) == 1
        #@show bitstring(4)
        @test extract_value_from_bits(f1, Int64, 4) == 2
        #@show bitstring(5)
        @test extract_value_from_bits(f1, Int64, 5) == 2
        #@show bitstring(6)
        @test extract_value_from_bits(f1, Int64, 6) == 3
        #@show bitstring(7)
        @test extract_value_from_bits(f1, Int64, 7) == 3
        #@show bitstring(8)
        @test extract_value_from_bits(f1, Int64, 8) == 0

        @test typeof(extract_value_from_bits(f1, Int64, 0x0)) == Int64
        @test typeof(extract_value_from_bits(f1, UInt64, 0x0)) == Int64 # see f1 definition
        #@show bitstring(0)
        @test extract_value_from_bits(f1, UInt64, 0x0) == 0
        #@show bitstring(1)
        @test extract_value_from_bits(f1, UInt64, 0x1) == 0
        #@show bitstring(2)
        @test extract_value_from_bits(f1, UInt64, 0x2) == 1
        #@show bitstring(3)
        @test extract_value_from_bits(f1, UInt64, 0x3) == 1
        #@show bitstring(4)
        @test extract_value_from_bits(f1, UInt64, 0x4) == 2
        #@show bitstring(5)
        @test extract_value_from_bits(f1, UInt64, 0x5) == 2
        #@show bitstring(6)
        @test extract_value_from_bits(f1, UInt64, 0x6) == 3
        #@show bitstring(7)
        @test extract_value_from_bits(f1, UInt64, 0x7) == 3
        #@show bitstring(8)
        @test extract_value_from_bits(f1, UInt64, 0x8) == 0

        f2 = GeneratedField(UInt64, :hello, 1, 2)
        @test typeof(extract_value_from_bits(f2, UInt64, 0)) == UInt64
        @test typeof(extract_value_from_bits(f2, Int64, 0)) == UInt64

        f3 = GeneratedField(UInt128, :hello, 1, 2)
        @test typeof(extract_value_from_bits(f3, UInt128, 0)) == UInt128
        @test typeof(extract_value_from_bits(f3, UInt128, convert(Int128, 0))) == UInt128
        @test typeof(extract_value_from_bits(f3, UInt128, convert(UInt128, 0))) == UInt128

        # #@show bitstring(0)
        @test implant_value_into_int(0, f1, 0) == 0
        # #@show bitstring(1)
        @test implant_value_into_int(0, f1, 1) == 2
        # #@show bitstring(2)
        @test implant_value_into_int(0, f1, 2) == 4
        # #@show bitstring(3)
        @test implant_value_into_int(0, f1, 3) == 6
        # # implant_value_into_int can overwrite if new_value has more than GeneratedField.bit_length bits
        # #@show bitstring(4)
        @test implant_value_into_int(0, f1, 4) == 8
    end

    # @testset "GenId.jl.tsid-41-10-12" begin

    #     SOME_EPOCH_START_2020 = DateTime(2020, 1, 1, 0, 0, 0, 0)
    #     SOME_EPOCH_START_VALUE_2020 = Dates.value(SOME_EPOCH_START_2020)
    #     #print(SOME_EPOCH_START_VALUE_2020)
    #     SOME_EPOCH_END_2070 = DateTime(2070, 12, 31, 23, 59, 59, 999)
    #     SOME_EPOCH_END_VALUE_2070 = Dates.value(SOME_EPOCH_END_2070)
    #     #print(SOME_EPOCH_END_VALUE_2070)

    #     bits_time = 41
    #     bits_machine = 10
    #     bits_tail = 12
    #     machine_id = 1
    #     iddef_int64_1 = TsIdDefinition(
    #         Int64; 
    #         bits_time=bits_time,
    #         bits_group_1=bits_machine,
    #         bits_tail=bits_tail,
    #         group_1=machine_id,
    #         epoch_start_dt=SOME_EPOCH_START_2020, 
    #         epoch_end_dt=SOME_EPOCH_END_2070)
    #     #@show iddef_int64_1
    #     #@show typeof(iddef_int64_1)

    #     @testset "GenId TsIdDefinition" begin
    #         @test typeof(iddef_int64_1) == TsIdDefinition
    #         @test_throws AssertionError TsIdDefinition(
    #             Int64;
    #             bits_time=-3,
    #             bits_group_1=bits_machine,
    #             bits_tail=bits_tail,
    #             group_1=machine_id,
    #             epoch_start_dt=DateTime("2000-01-12T17:21:55.308"),
    #             epoch_end_dt=SOME_EPOCH_END_2070)
    #         @test_throws AssertionError TsIdDefinition(
    #             Int64;
    #             bits_time=bits_time,
    #             bits_group_1=72,
    #             bits_tail=bits_tail,
    #             group_1=machine_id,
    #             epoch_start_dt=DateTime("2000-01-12T17:21:55.308"),
    #             epoch_end_dt=SOME_EPOCH_END_2070)
    #         @test_throws AssertionError TsIdDefinition(
    #             Int64;
    #             bits_time=bits_time,
    #             bits_group_1=bits_machine,
    #             bits_tail=92,
    #             group_1=machine_id,
    #             epoch_start_dt=DateTime("2000-01-12T17:21:55.308"),
    #             epoch_end_dt=SOME_EPOCH_END_2070)
    #         @test_throws AssertionError TsIdDefinition(
    #             Int64;
    #             bits_time=-3,
    #             bits_group_1=bits_machine,
    #             bits_tail=bits_tail,
    #             group_1=machine_id,
    #             epoch_start_dt=SOME_EPOCH_START_2020,
    #             epoch_end_dt = DateTime("2090-01-12T17:21:55.308"))
    #         @test_throws AssertionError TsIdDefinition(
    #             Int64;
    #             bits_time=-3,
    #             bits_group_1=bits_machine,
    #             bits_tail=bits_tail,
    #             group_1=machine_id,
    #             epoch_start_dt=SOME_EPOCH_START_2020,
    #             epoch_end_dt=SOME_EPOCH_END_2070)
    #         @test_throws AssertionError TsIdDefinition(
    #             Int64;
    #             bits_time=1,
    #             bits_group_1=1,
    #             bits_tail=1,
    #             group_1=machine_id,
    #             epoch_start_dt=SOME_EPOCH_START_2020,
    #             epoch_end_dt=SOME_EPOCH_END_2070)
    #         @test_throws AssertionError TsIdDefinition(
    #             Int64;
    #             bits_time=bits_time,
    #             bits_group_1=bits_machine,
    #             bits_tail=bits_tail,
    #             group_1=machine_id,
    #             epoch_start_dt=SOME_EPOCH_END_2070,
    #             epoch_end_dt=SOME_EPOCH_START_2020)

    #     end
    #     @testset "tsid_timestamp" begin
    #         tsid_start = GenId._make_bits_timestamp(SOME_EPOCH_START_2020, SOME_EPOCH_START_VALUE_2020, iddef_int64_1.shift_bits_time)
    #         @test tsid_start == 0
    #         @test GenId.tsid_timestamp(tsid_start, SOME_EPOCH_START_VALUE_2020, bits_time) == SOME_EPOCH_START_2020
            
    #         tsid_end = GenId._make_bits_timestamp(SOME_EPOCH_END_2070, SOME_EPOCH_START_VALUE_2020, 22)
    #         @test tsid_end == 6750561160392605696
    #         @test tsid_timestamp(iddef_int64_1, tsid_end) == SOME_EPOCH_END_2070
            
    #         @test GenId._make_bits_timestamp(iddef_int64_1, SOME_EPOCH_START_2020) == tsid_start
    #         @test GenId._make_bits_timestamp(iddef_int64_1, SOME_EPOCH_END_2070) == tsid_end
    #     end

    #     @testset "tsid_machine_id" begin
    #         mid1 = GenId._make_bits_group_1(1, iddef_int64_1.shift_bits_group_1)
    #         @test mid1 == 4096
    #         @test tsid_group_1(iddef_int64_1, mid1) == 1
            
    #         mid2 = GenId._make_bits_group_1(2, iddef_int64_1.shift_bits_group_1)
    #         @test mid2 == 8192
    #         @test tsid_group_1(iddef_int64_1, mid2) == 2
            
    #         mid1023 = GenId._make_bits_group_1(1023, iddef_int64_1.shift_bits_group_1)
    #         @test mid1023 == 4190208
    #         @test tsid_group_1(iddef_int64_1, mid1023) == 1023
    #         @test GenId._make_bits_group_1(iddef_int64_1) == mid1
            
    #         tsid_r = GenId._make_bits_group_1(iddef_int64_1)
    #         @test tsid_group_1(iddef_int64_1, tsid_r) == machine_id

    #         @test tsid_timestamp(iddef_int64_1, TSID{Int64}(489485826766409729)) == DateTime("2023-09-12T17:21:55.308")
    #         @test tsid_group_1(iddef_int64_1, TSID{Int64}(489485826766409729)) == machine_id
    #         @test tsid_group_2(iddef_int64_1, TSID{Int64}(489485826766409729)) == 0
    #         @test tsid_tail(iddef_int64_1, TSID{Int64}(489485826766409729)) == 1

    #     end

        
    #     @testset "def_*" begin
    #         @test def_group_1(iddef_int64_1) == machine_id
    #         @test def_group_2(iddef_int64_1) == 0
    #         @test def_bits_time(iddef_int64_1) == bits_time
    #         @test def_bits_group_1(iddef_int64_1) == bits_machine
    #         @test def_bits_group_2(iddef_int64_1) == 0
    #         @test def_bits_tail(iddef_int64_1) == bits_tail
    #     end

    #     @testset "tsid_generate random" begin
    #         n_ids = 1000
            
    #         iddef_s1 = GenId.TsIdDefinition(
    #             Int64;
    #             bits_time=41,
    #             bits_group_1=10,
    #             bits_tail=12,
    #             tail_algorithm=:machine_increment,
    #             group_1=1,
    #             epoch_start_dt=DateTime(2020, 1, 1, 0, 0, 0, 0),
    #             epoch_end_dt=DateTime(2070, 12, 31, 23, 59, 59, 999)
    #         )
            
    #         ids = [tsid_generate(iddef_s1) for i in 1:n_ids]
    #         millis = collect(map(x -> tsid_timestamp(iddef_s1, x), ids))
    #         tails = collect(map(x -> tsid_tail(iddef_s1, x), ids))
            
    #         montonic = true
    #         for i in 2:n_ids
    #             if millis[i] < millis[i-1]
    #                 monotonic = false
    #             end
    #         end
    #         @test monotinic = true
            
    #         sequential = true
    #         for i in 2:n_ids
    #             if tails[i] < tails[i-1]
    #                 sequential = false
    #             end
    #         end
    #         @test sequential = true


    #         iddef_r1 = GenId.TsIdDefinition(
    #             Int64;
    #             bits_time=41,
    #             bits_group_1=10,
    #             bits_tail=12,
    #             tail_algorithm=:random,
    #             group_1=1,
    #             epoch_start_dt=DateTime(2020, 1, 1, 0, 0, 0, 0),
    #             epoch_end_dt=DateTime(2070, 12, 31, 23, 59, 59, 999)
    #         )
            
    #         ids = [tsid_generate(iddef_r1) for i in 1:n_ids]
    #         millis = collect(map(x -> tsid_timestamp(iddef_r1, x), ids))
    #         tails = collect(map(x -> tsid_tail(iddef_r1, x), ids))
            
    #         montonic = true
    #         for i in 2:n_ids
    #             if millis[i] < millis[i-1]
    #                 monotonic = false
    #             end
    #         end
    #         @test monotinic = true

    #         sequential = true
    #         for i in 2:n_ids
    #             if tails[i] < tails[i-1]
    #                 sequential = false
    #             end
    #         end
    #         @test sequential == false

    #         in_rand_max = true
    #         for i in 1:n_ids
    #             if tails[i] < 0 || tails[i] > iddef_r1.rand_max
    #                 in_rand_max = false
    #             end
    #         end
    #         @test in_rand_max == true

    #     end

        @testset "Snowflake ID" begin
            iddef_snowflake = SnowflakeIdDefinition(SOME_EPOCH_START_2020, convert(Int64, 1))
            @test iddef_snowflake.name == :SnowflakeIdDefinition
            reset_globabl_machine_id_increment()
            now = Dates.now()
            id1 = tsid_generate(iddef_snowflake)
            @test tsid_getfield_value(iddef_snowflake, :timestamp, id1) < Dates.value(now) + 100
            @test tsid_getfield_value(iddef_snowflake, :machine_id, id1) == 1
            @test tsid_getfield_value(iddef_snowflake, :machine_sequence, id1) == 1
        end

        @testset "Instagram ID" begin
            iddef_instagram = InstagramIdDefinition(SOME_EPOCH_START_2020, 1)
            @test iddef_instagram.name == :InstagramIdDefinition
            reset_globabl_machine_id_increment()
            now = Dates.now()
            id1 = tsid_generate(iddef_instagram)
            @test tsid_getfield_value(iddef_instagram, :timestamp, id1) < Dates.value(now) + 100
            @test tsid_getfield_value(iddef_instagram, :shard_id, id1) == 1
            @test tsid_getfield_value(iddef_instagram, :machine_sequence, id1) == 1
        end

        @testset "ULID" begin
            iddef_ulid = ULID_DEFINITION # ULIdDefinition()
            @test iddef_ulid.name == :ULIdDefinition
            now = Dates.now()
            id1 = tsid_generate(iddef_ulid)
            @test tsid_getfield_value(iddef_ulid, :timestamp, id1) < Dates.value(now) + 100
        end

        @testset "XID" begin
            reset_globabl_machine_id_increment()
            now = Dates.now()
            iddef_xid = XIdDefinition(1)
            @test iddef_xid.name == :XIdDefinition
            id1 = tsid_generate(iddef_xid)
            #@show id1
            #@show tsid_to_string(iddef_xid, id1)
            @test tsid_getfield_value(iddef_xid, :timestamp, id1) < Dates.value(now) + 100
            @test tsid_getfield_value(iddef_xid, :machine_id, id1) == 1
            @test tsid_getfield_value(iddef_xid, :process_id, id1) == bit_mask_uint(UInt16, getpid(), 0, 15)
            @test tsid_getfield_value(iddef_xid, :machine_sequence, id1) == 1
        end

        @testset "Insecure NanoID" begin
            iddef_nano = InsecureNanoIdDefinition()
            @test iddef_nano.name == :InsecureNanoIdDefinition
            id1 = tsid_generate(iddef_nano)
            id1_str = tsid_to_string(iddef_nano, id1)
            @show id1, id1_str
            id2 = tsid_int_from_string(iddef_nano, id1_str)
            @test id2 == id1
        end

        @testset "UUIDv7 1" begin
            iddef_uuidv7_1 = UUIDv7_1_IdDefinition()
            @show tsid_generate(iddef_uuidv7_1)
            @show tsid_generate_string(iddef_uuidv7_1)
        end

        @testset "Firebase PushID" begin
            iddef_firebase_push_id = FIREBASE_PUSHID_DEFINITION
            now = Dates.now()
            id1 = tsid_generate(iddef_firebase_push_id)
            @test tsid_getfield_value(iddef_firebase_push_id, :timestamp, id1) < Dates.value(now) + 100
            @test typeof(id1) == iddef_firebase_push_id.type
            id_int_1 = 301430602692632926610578560781911544
            #id_int_1_str = GenId.base32encode_int128(id_int_1; started_init=true)
            id_int_1_str = GenId.base_dictionary_encode_int128(id_int_1, iddef_firebase_push_id.text_coder)
            @test id_int_1_str == "DVqh4j54DWG1F0Pda-Ms"
            @test length(id_int_1_str) == 20
            id_int_2 = GenId.base_dictionary_decode_int128("DVqh4j54DWG1F0Pda-Ms", iddef_firebase_push_id.text_coder)
            @test id_int_1 == id_int_2

            @test tsid_to_string(iddef_firebase_push_id, id_int_1) == "DVqh4j54DWG1F0Pda-Ms"
            @test tsid_int_from_string(iddef_firebase_push_id, "DVqh4j54DWG1F0Pda-Ms") == id_int_1
        end

        @testset "tsid_to_string" begin
            
            iddef_int64_1 = TSIDGenericContainer(
                Int64,
                :SnowflakeIdDefinition,
                [
                    TimestampField(Int64, 22, 41, SOME_EPOCH_START_2020),
                    ConstantField(UInt64, :machine_id, 12, 10, 1),
                    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
                ],
                make_crockford_base_32_coder(;
                    pad_char='0',
                    has_checksum=false,
                    use_full_with=false
                )
            )
            @test tsid_to_string(iddef_int64_1, 489485826766409729) == "DJR0RGDG0401"

            iddef_int64_2 = TSIDGenericContainer(
                Int64,
                :SnowflakeIdDefinition,
                [
                    TimestampField(Int64, 22, 41, SOME_EPOCH_START_2020),
                    ConstantField(UInt64, :machine_id, 12, 10, 1),
                    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
                ],
                make_crockford_base_32_coder(;
                    pad_char='0',
                    has_checksum=true,
                    use_full_with=false
                )
            )
            @test tsid_to_string(iddef_int64_2, 489485826766409729) == "DJR0RGDG04014"

            iddef_int64_3 = TSIDGenericContainer(
                Int64,
                :SnowflakeIdDefinition,
                [
                    TimestampField(Int64, 22, 41, SOME_EPOCH_START_2020),
                    ConstantField(UInt64, :machine_id, 12, 10, 1),
                    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
                ],
                make_crockford_base_32_coder(;
                    pad_char='0',
                    has_checksum=false,
                    use_full_with=true
                )
            )
            @test tsid_to_string(iddef_int64_3, 489485826766409729) == "0DJR0RGDG0401"

            iddef_int64_4 = TSIDGenericContainer(
                Int64,
                :SnowflakeIdDefinition,
                [
                    TimestampField(Int64, 22, 41, SOME_EPOCH_START_2020),
                    ConstantField(UInt64, :machine_id, 12, 10, 1),
                    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
                ],
                make_crockford_base_32_coder(;
                    pad_char='0',
                    has_checksum=true,
                    use_full_with=true
                )
            )
            @test tsid_to_string(iddef_int64_4, 489485826766409729) == "0DJR0RGDG04014"

            iddef_int64_5 = TSIDGenericContainer(
                Int64,
                :SnowflakeIdDefinition,
                [
                    TimestampField(Int64, 22, 41, SOME_EPOCH_START_2020),
                    ConstantField(UInt64, :machine_id, 12, 10, 1),
                    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
                ],
                make_crockford_base_32_coder(;
                    pad_char='0',
                    has_checksum=false,
                    use_full_with=false
                )
            )
            @test tsid_to_string(iddef_int64_5, 489485826766409729) == "DJR0RGDG0401"
            
        end

        @testset "tsid_from_string" begin
            # @test_throws MethodError tsid_int_from_string(13)
            iddef_int64_1 = TSIDGenericContainer(
                Int64,
                :SnowflakeIdDefinition,
                [
                    TimestampField(Int64, 22, 41, SOME_EPOCH_START_2020),
                    ConstantField(UInt64, :machine_id, 12, 10, 1),
                    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
                ],
                make_crockford_base_32_coder(;
                    pad_char='0',
                    has_checksum=false,
                    use_full_with=true
                )
            )
            @test tsid_int_from_string(iddef_int64_1, "DJR0RGDG0401") == 489485826766409729

            iddef_int64_2 = TSIDGenericContainer(
                Int64,
                :SnowflakeIdDefinition,
                [
                    TimestampField(Int64, 22, 41, SOME_EPOCH_START_2020),
                    ConstantField(UInt64, :machine_id, 12, 10, 1),
                    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
                ],
                make_crockford_base_32_coder(;
                    pad_char='0',
                    has_checksum=true,
                    use_full_with=false
                )
            )
            @test tsid_int_from_string(iddef_int64_2, "DJR0RGDG04014") == 489485826766409729

            iddef_int64_3 = TSIDGenericContainer(
                Int64,
                :SnowflakeIdDefinition,
                [
                    TimestampField(Int64, 22, 41, SOME_EPOCH_START_2020),
                    ConstantField(UInt64, :machine_id, 12, 10, 1),
                    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
                ],
                make_crockford_base_32_coder(;
                    pad_char='0',
                    has_checksum=false,
                    use_full_with=true
                )
            )
            @test tsid_int_from_string(iddef_int64_3, "0DJR0RGDG0401") == 489485826766409729

            iddef_int64_4 = TSIDGenericContainer(
                Int64,
                :SnowflakeIdDefinition,
                [
                    TimestampField(Int64, 22, 41, SOME_EPOCH_START_2020),
                    ConstantField(UInt64, :machine_id, 12, 10, 1),
                    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
                ],
                make_crockford_base_32_coder(;
                    pad_char='0',
                    has_checksum=true,
                    use_full_with=true
                )
            )
            @test tsid_int_from_string(iddef_int64_4, "0DJR0RGDG04014") == 489485826766409729

            iddef_int64_5 = TSIDGenericContainer(
                Int64,
                :SnowflakeIdDefinition,
                [
                    TimestampField(Int64, 22, 41, SOME_EPOCH_START_2020),
                    ConstantField(UInt64, :machine_id, 12, 10, 1),
                    SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
                ],
                make_crockford_base_32_coder(;
                    pad_char='0',
                    has_checksum=false,
                    use_full_with=true
                )
            )
            @test tsid_int_from_string(iddef_int64_5, "00000000000000000000000001") == convert(Int128, 1)
            @test tsid_int_from_string(iddef_int64_5, "0000000000001") == 1
            @test tsid_int_from_string(iddef_int64_5, "DJR0RGDG0401") == 489485826766409729
        end

    end

end

