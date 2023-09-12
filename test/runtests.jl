module GenIdTest

using Dates
using Test
using Aqua

using GenId

@testset "GenId" begin

    @testset "GenId.quality" begin
        Aqua.test_all(GenId; deps_compat=false)
    end


    @testset "GenId.croford32" begin
        @testset "crockford32_encode_uint64" begin
            @test crockford32_encode_uint64(0x0000000000000000) == "0"
            @test crockford32_encode_uint64(0x0000000000000001) == "1"
            @test crockford32_encode_uint64(0xffffffffffffffff) == "FZZZZZZZZZZZZ"
            @test crockford32_encode_uint64(0x000000000000001e) == "Y"
            @test crockford32_encode_uint64(0x000000000000001f) == "Z"
            @test crockford32_encode_uint64(0x0000000000000020) == "10"
            @test crockford32_encode_uint64(0x0000000000000021) == "11"
            @test crockford32_encode_uint64(0x000000000000002f) == "1F"
            @test crockford32_encode_uint64(0x000000000000002f, started_init=true) == "000000000001F"
        end

        @testset "crockford32_encode_int64" begin
            @test crockford32_encode_int64(convert(Int64, 0x0000000000000000)) == "0"
            @test crockford32_encode_int64(convert(Int64, 0x0000000000000001)) == "1"
            @test crockford32_encode_int64(convert(Int64, 0x0000000000000001), with_checksum=true) == "11"
            @test crockford32_encode_int64(convert(Int64, 0x0000000000000002)) == "2"
            @test crockford32_encode_int64(convert(Int64, 0x0000000000000002), with_checksum=true) == "22"
            @test crockford32_encode_int64(convert(Int64, 0x7fffffffffffffff)) == "7ZZZZZZZZZZZZ"
            @test crockford32_encode_int64(convert(Int64, 0x000000000000001e)) == "Y"
            @test crockford32_encode_int64(convert(Int64, 0x000000000000001f)) == "Z"
            @test crockford32_encode_int64(convert(Int64, 0x0000000000000020)) == "10"
            @test crockford32_encode_int64(convert(Int64, 0x0000000000000021)) == "11"
            @test crockford32_encode_int64(convert(Int64, 0x000000000000002f)) == "1F"
            @test crockford32_encode_int64(194, with_checksum=true) == "629"
            @test crockford32_encode_int64(398373, with_checksum=true) == "C515Z"
            @test crockford32_encode_int64(3838385658376483, with_checksum=true) == "3D2ZQ6TVC935"
            @test crockford32_encode_uint64(convert(UInt64, 18446744073709551615)) == "FZZZZZZZZZZZZ"
            @test crockford32_encode_uint64(convert(UInt64, 18446744073709551615), with_checksum=true) == "FZZZZZZZZZZZZB"
        end


        @testset "crockford32_encode_int128" begin
            @test crockford32_encode_int128(convert(Int128, 0x7fffffffffffffff0000000000000000)) == "7ZZZZZZZZZZZZ0000000000000"
            @test crockford32_encode_int128(convert(Int128, 0x7fffffffffffffff0000000000000001)) == "7ZZZZZZZZZZZZ0000000000001"
            @test crockford32_encode_int128(convert(Int128, 0x0000000000000001)) == "1"
            @test crockford32_encode_int128(convert(Int128, 0x000000000000001)) == "1"
            @test crockford32_encode_int128(convert(Int128, 0x70000000000000010000000000000000)) == "70000000000010000000000000"
            @test crockford32_encode_int128(convert(Int128, 0x00000000000000010000000000000000)) == "10000000000000"
            @test crockford32_encode_int128(convert(Int128, 170141183460469231722463931679029329919)) == "7ZZZZZZZZZZZZ7ZZZZZZZZZZZZ"
        end

        @testset "skip_dashes_13" begin
            @test GenId.skip_dashes_13("FZ") == "FZ"
            @test GenId.skip_dashes_13("FZZZZ-ZZZZ-ZZZZ") == "FZZZZZZZZZZZZ"
        end

        @testset "crockford32_decode_uint64" begin
            @test crockford32_decode_uint64("FZZZZZZZZZZZZ") == 0xffffffffffffffff
            @test crockford32_decode_uint64("FZZZZ-ZZZZ-ZZZZ") == 0xffffffffffffffff
        end

        @testset "crockford32_decode_int64" begin
            @test crockford32_decode_int64("11", with_checksum=true) == 1
            @test crockford32_decode_int64("1") == 1
            @test crockford32_decode_int64("629", with_checksum=true) == 194
            @test crockford32_decode_int64("62") == 194
            @test crockford32_decode_int64("DY2N") == 456789
            @test crockford32_decode_int64("C515Z", with_checksum=true) == 398373
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
            @test crockford32_decode_int128("7ZZZZZZZZZZZZ") == 9223372036854775807
            @test length(string(170141183460469231722463931679029329919, base=16)) == 32
            @test crockford32_decode_int128("7ZZZZZZZZZZZZ7ZZZZZZZZZZZZ") == 170141183460469231722463931679029329919
            #@test crockford32_decode_uint128("AWKHA8760HPZYHAWKHA8760HP") == 13
            #@test crockford32_decode_uint128("AWKHA8760HPZYHAWKHA8760HPAWKHA8760HPZYHAWKHA8760HP") == 13
        end

    end

    @testset "GenId.bit_mask" begin
        @test GenId.word_size(Int16) == GenId.word_size(UInt16) == 16
        @test GenId.word_size(Int32) == GenId.word_size(UInt32) == 32
        @test GenId.word_size(Int64) == GenId.word_size(UInt64) == 64
        @test GenId.word_size(Int128) == GenId.word_size(UInt128) == 128
        @test bitstring(GenId.bit_mask_uint(UInt64, 0, 0)) == "0000000000000000000000000000000000000000000000000000000000000001"
        @test bitstring(GenId.bit_mask_uint(UInt64, 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
        @test bitstring(GenId.bit_mask_uint(UInt64, 63, 63)) == "1000000000000000000000000000000000000000000000000000000000000000"
        @test bitstring(GenId.bit_mask_int(Int64, typemax(Int64), 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
        @test_throws DomainError bitstring(GenId.bit_mask_int(Int64, -1, 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
    end


    @testset "GenId.jl.tsid-41-10-12" begin

        SOME_EPOCH_START_2020 = DateTime(2020, 1, 1, 0, 0, 0, 0)
        SOME_EPOCH_START_VALUE_2020 = Dates.value(SOME_EPOCH_START_2020)
        #print(SOME_EPOCH_START_VALUE_2020)
        SOME_EPOCH_END_2070 = DateTime(2070, 12, 31, 23, 59, 59, 999)
        SOME_EPOCH_END_VALUE_2070 = Dates.value(SOME_EPOCH_END_2070)
        #print(SOME_EPOCH_END_VALUE_2070)

        bits_time = 41
        bits_machine = 10
        bits_tail = 12
        machine_id = 1
        iddef1 = TsIdDefinition(Int64, bits_time, bits_machine, bits_tail, machine_id, SOME_EPOCH_START_2020, SOME_EPOCH_END_2070)
        @show iddef1

        @testset "GenId TsIdDefinition" begin
            @test_throws DomainError TsIdDefinition(Int64, -3, bits_machine, bits_tail, machine_id, SOME_EPOCH_START_2020, SOME_EPOCH_END_2070)
            @test_throws DomainError TsIdDefinition(Int64, 1, 1, 1, machine_id, SOME_EPOCH_START_2020, SOME_EPOCH_END_2070)
        end
        @testset "tsid_timestamp" begin
            tsid_start = GenId._make_bits_timestamp(SOME_EPOCH_START_2020, SOME_EPOCH_START_VALUE_2020, iddef1.shift_bits_time)
            @test tsid_start == 0
            @test GenId.tsid_timestamp(tsid_start, SOME_EPOCH_START_VALUE_2020, bits_time) == SOME_EPOCH_START_2020
            
            tsid_end = GenId._make_bits_timestamp(SOME_EPOCH_END_2070, SOME_EPOCH_START_VALUE_2020, 22)
            @test tsid_end == 6750561160392605696
            @test tsid_timestamp(iddef1, tsid_end) == SOME_EPOCH_END_2070
            
            @test GenId._make_bits_timestamp(iddef1, SOME_EPOCH_START_2020) == tsid_start
            @test GenId._make_bits_timestamp(iddef1, SOME_EPOCH_END_2070) == tsid_end
        end

        @testset "tsid_machine_id" begin
            mid1 = GenId._make_bits_machine_id(1, iddef1.shift_bits_machine)
            @test mid1 == 4096
            @test tsid_machine_id(iddef1, mid1) == 1
            
            mid2 = GenId._make_bits_machine_id(2, iddef1.shift_bits_machine)
            @test mid2 == 8192
            @test tsid_machine_id(iddef1, mid2) == 2
            
            mid1023 = GenId._make_bits_machine_id(1023, iddef1.shift_bits_machine)
            @test mid1023 == 4190208
            @test tsid_machine_id(iddef1, mid1023) == 1023
            @test GenId._make_bits_machine_id(iddef1) == mid1
            
            tsid_r = GenId._make_bits_machine_id(iddef1)
            @test tsid_machine_id(iddef1, tsid_r) == machine_id
        end

        @testset "tsid_machine_tail :increment_global" begin
            @test GenId._make_bits_increment(4094, iddef1.tail_mod) == 4094
            @test GenId._make_bits_increment(4095, iddef1.tail_mod) == 4095
            @test GenId._make_bits_increment(4096, iddef1.tail_mod) == 0
            @test GenId._make_bits_increment(4097, iddef1.tail_mod) == 1
            
            GenId.reset_globabl_machine_id_increment()
            tsid_tincr_1 = GenId.tsid_generate(iddef1)
            tsid_tincr_2 = GenId.tsid_generate(iddef1)
            @test tsid_machine_tail(iddef1, tsid_tincr_1) == 1
            @test tsid_machine_tail(iddef1, tsid_tincr_2) == 2
            
            GenId.reset_globabl_machine_id_increment(4094)
            
            tsid_tincr_4095 = GenId.tsid_generate(iddef1)
            @test tsid_machine_tail(iddef1, tsid_tincr_4095) == 4095
            
            tsid_tincr_4096 = GenId.tsid_generate(iddef1)
            @test tsid_machine_tail(iddef1, tsid_tincr_4096) == 0
        end

        @testset "tsid_from_string" begin
            @test_throws MethodError tsid_from_string(13)
            @test tsid_to_string(convert(Int64, 0b0000000000000000000000000000000000000000000000000000000000000001)) == "1"
            @test tsid_to_string(0b0000000000000000000000000000000000000000000000000000000000000001) == "1"
            @test tsid_to_string(0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001) == "1"
            @test tsid_to_string(0b01111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111) == "7ZZZZZZZZZZZZ7ZZZZZZZZZZZZ"
            @test tsid_from_string("7ZZZZZZZZZZZZ7ZZZZZZZZZZZZ") == 9223372036854775807
            #@test tsid_to_str(1) == "DGVTV3540402"
            #@test tsid1_int64_from_str("D4PMAVXC0408") == 473674380866490376
            #@show tsid_machine_id(iddef1, 473674380866490376)
            #@test crockford32_encode_int64(tsid1_int64_from_str("D4PMAVXC0408")) == "D4PMAVXC0408"
        end

    end

end

end