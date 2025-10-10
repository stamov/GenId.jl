# Bit manipulation and field tests

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

@testset "unsigned_int_for_signed - all branches" begin
    # Signed integer types
    @test GenId.unsigned_int_for_signed(Int16) == UInt16
    @test GenId.unsigned_int_for_signed(Int32) == UInt32
    @test GenId.unsigned_int_for_signed(Int64) == UInt64
    @test GenId.unsigned_int_for_signed(Int128) == UInt128

    # Unsigned integer types (pass-through)
    @test GenId.unsigned_int_for_signed(UInt16) == UInt16
    @test GenId.unsigned_int_for_signed(UInt32) == UInt32
    @test GenId.unsigned_int_for_signed(UInt64) == UInt64
    @test GenId.unsigned_int_for_signed(UInt128) == UInt128
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

@testset "tsid_to_string - all type branches" begin
    epoch = DateTime(2020, 1, 1)

    # Int64 with Crockford Base32
    @testset "Int64 with Crockford" begin
        def_int64 = TSIDGenericContainer(
            Int64,
            :TestInt64Crockford,
            [ConstantField(Int64, :test, 0, 10, 42)],
            make_crockford_base_32_coder()
        )
        result = tsid_to_string(def_int64, Int64(42))
        @test typeof(result) == String
        @test length(result) > 0

        # Test with checksum
        def_int64_checksum = TSIDGenericContainer(
            Int64,
            :TestInt64Checksum,
            [ConstantField(Int64, :test, 0, 10, 42)],
            make_crockford_base_32_coder(; has_checksum=true)
        )
        result_checksum = tsid_to_string(def_int64_checksum, Int64(42))
        @test typeof(result_checksum) == String
        @test length(result_checksum) > length(result)  # Checksum adds character
    end

    # Int128 with Crockford Base32
    @testset "Int128 with Crockford" begin
        def_int128 = TSIDGenericContainer(
            Int128,
            :TestInt128Crockford,
            [ConstantField(Int128, :test, 0, 10, 42)],
            make_crockford_base_32_coder()
        )
        result = tsid_to_string(def_int128, Int128(42))
        @test typeof(result) == String
        @test length(result) > 0
    end

    # UInt64 with Crockford Base32
    @testset "UInt64 with Crockford" begin
        def_uint64 = TSIDGenericContainer(
            UInt64,
            :TestUInt64Crockford,
            [ConstantField(UInt64, :test, 0, 10, 42)],
            make_crockford_base_32_coder()
        )
        result = tsid_to_string(def_uint64, UInt64(42))
        @test typeof(result) == String
        @test length(result) > 0
    end

    # Note: UInt128 with Crockford Base32 is not implemented
    # (crockford32_encode_uint128 function doesn't exist despite branch in code)

    # Int128 with base32 (non-Crockford) using base_dictionary_encode_int128
    @testset "Int128 with base32 dictionary" begin
        def_int128_base32 = TSIDGenericContainer(
            Int128,
            :TestInt128Base32,
            [ConstantField(Int128, :test, 0, 10, 42)],
            make_basic_coder(
                algorithm=:base_32,
                bits_per_character=5,
                dictionary="234567ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                pad_char='2',
                use_full_with=false
            )
        )
        result = tsid_to_string(def_int128_base32, Int128(42))
        @test typeof(result) == String
        @test length(result) > 0
    end

    # Int128 with base64 dictionary
    @testset "Int128 with base64 dictionary" begin
        def_int128_base64 = TSIDGenericContainer(
            Int128,
            :TestInt128Base64,
            [ConstantField(Int128, :test, 0, 10, 42)],
            make_basic_coder(
                algorithm=:base_64,
                bits_per_character=6,
                dictionary="-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz",
                pad_char='0',
                use_full_with=false
            )
        )
        result = tsid_to_string(def_int128_base64, Int128(42))
        @test typeof(result) == String
        @test length(result) > 0
    end

    # Test max_string_length truncation
    @testset "max_string_length truncation" begin
        def_truncated = TSIDGenericContainer(
            Int64,
            :TestTruncated,
            [ConstantField(Int64, :test, 0, 32, 1234567890)],
            make_crockford_base_32_coder(; max_string_length=5)
        )
        result = tsid_to_string(def_truncated, Int64(1234567890))
        @test length(result) == 5
    end
end

@testset "tsid_int_from_string - all type branches" begin
    # Int64 with Crockford Base32
    @testset "Int64 with Crockford" begin
        def_int64 = TSIDGenericContainer(
            Int64,
            :TestInt64Crockford,
            [ConstantField(Int64, :test, 0, 10, 42)],
            make_crockford_base_32_coder()
        )
        original = Int64(42)
        encoded = tsid_to_string(def_int64, original)
        decoded = tsid_int_from_string(def_int64, encoded)
        @test decoded == original
    end

    # Int128 with Crockford Base32
    @testset "Int128 with Crockford" begin
        def_int128 = TSIDGenericContainer(
            Int128,
            :TestInt128Crockford,
            [ConstantField(Int128, :test, 0, 10, 42)],
            make_crockford_base_32_coder()
        )
        original = Int128(42)
        encoded = tsid_to_string(def_int128, original)
        decoded = tsid_int_from_string(def_int128, encoded)
        @test decoded == original
    end

    # UInt64 with Crockford Base32
    @testset "UInt64 with Crockford" begin
        def_uint64 = TSIDGenericContainer(
            UInt64,
            :TestUInt64Crockford,
            [ConstantField(UInt64, :test, 0, 10, 42)],
            make_crockford_base_32_coder()
        )
        original = UInt64(42)
        encoded = tsid_to_string(def_uint64, original)
        decoded = tsid_int_from_string(def_uint64, encoded)
        @test decoded == original
    end

    # Note: UInt128 with Crockford Base32 is not implemented
    # (crockford32_decode_uint128 exists but encode doesn't)

    # Int128 with base32 (non-Crockford) using base_dictionary
    @testset "Int128 with base32 dictionary" begin
        def_int128_base32 = TSIDGenericContainer(
            Int128,
            :TestInt128Base32,
            [ConstantField(Int128, :test, 0, 10, 42)],
            make_basic_coder(
                algorithm=:base_32,
                bits_per_character=5,
                dictionary="234567ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                pad_char='2',
                use_full_with=false
            )
        )
        original = Int128(42)
        encoded = tsid_to_string(def_int128_base32, original)
        decoded = tsid_int_from_string(def_int128_base32, encoded)
        @test decoded == original
    end

    # Int128 with base64 dictionary
    @testset "Int128 with base64 dictionary" begin
        def_int128_base64 = TSIDGenericContainer(
            Int128,
            :TestInt128Base64,
            [ConstantField(Int128, :test, 0, 10, 42)],
            make_basic_coder(
                algorithm=:base_64,
                bits_per_character=6,
                dictionary="-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz",
                pad_char='0',
                use_full_with=false
            )
        )
        original = Int128(42)
        encoded = tsid_to_string(def_int128_base64, original)
        decoded = tsid_int_from_string(def_int128_base64, encoded)
        @test decoded == original
    end

    # Test with checksum
    @testset "Int64 with checksum" begin
        def_int64_checksum = TSIDGenericContainer(
            Int64,
            :TestInt64Checksum,
            [ConstantField(Int64, :test, 0, 10, 42)],
            make_crockford_base_32_coder(; has_checksum=true)
        )
        original = Int64(42)
        encoded = tsid_to_string(def_int64_checksum, original)
        decoded = tsid_int_from_string(def_int64_checksum, encoded)
        @test decoded == original
    end
end

@testset "tsid_generate - all field types" begin
    epoch = DateTime(2020, 1, 1)

    # Test with TimestampField
    @testset "With TimestampField" begin
        def_timestamp = TSIDGenericContainer(
            Int64,
            :TestTimestamp,
            [TimestampField(Int64, 0, 41, epoch)],
            make_crockford_base_32_coder()
        )
        id1 = tsid_generate(def_timestamp)
        sleep(0.001)  # Wait 1ms
        id2 = tsid_generate(def_timestamp)
        @test id2 > id1  # Timestamp should increase
    end

    # Test with RandomField
    @testset "With RandomField" begin
        def_random = TSIDGenericContainer(
            Int64,
            :TestRandom,
            [RandomField(Int64, 0, 32)],
            make_crockford_base_32_coder()
        )
        id1 = tsid_generate(def_random)
        id2 = tsid_generate(def_random)
        # Random fields should likely be different (not guaranteed but very probable)
        # Just verify they're generated successfully
        @test typeof(id1) == Int64
        @test typeof(id2) == Int64
    end

    # Test with CryptographicRandomField
    @testset "With CryptographicRandomField" begin
        def_crypto = TSIDGenericContainer(
            Int64,
            :TestCrypto,
            [CryptographicRandomField(Int64, 0, 32)],
            make_crockford_base_32_coder()
        )
        id1 = tsid_generate(def_crypto)
        id2 = tsid_generate(def_crypto)
        @test typeof(id1) == Int64
        @test typeof(id2) == Int64
    end

    # Test with MachineSequenceField
    @testset "With MachineSequenceField" begin
        GenId.reset_globabl_machine_id_increment(0)
        def_sequence = TSIDGenericContainer(
            Int64,
            :TestSequence,
            [MachineSequenceField(Int64, 0, 12)],
            make_crockford_base_32_coder()
        )
        id1 = tsid_generate(def_sequence)
        id2 = tsid_generate(def_sequence)
        id3 = tsid_generate(def_sequence)
        # Sequence should increment
        @test id2 == id1 + 1
        @test id3 == id2 + 1
    end

    # Test with ConstantField
    @testset "With ConstantField" begin
        def_constant = TSIDGenericContainer(
            Int64,
            :TestConstant,
            [ConstantField(Int64, :machine_id, 0, 10, 123)],
            make_crockford_base_32_coder()
        )
        id1 = tsid_generate(def_constant)
        id2 = tsid_generate(def_constant)
        # Constant fields should produce same ID
        @test id1 == id2
        @test id1 == 123
    end

    # Test with ProcessIdField
    @testset "With ProcessIdField" begin
        def_process = TSIDGenericContainer(
            Int64,
            :TestProcess,
            [ProcessIdField(Int64, 0, 16)],
            make_crockford_base_32_coder()
        )
        id1 = tsid_generate(def_process)
        id2 = tsid_generate(def_process)
        # Process ID should be constant within same process
        @test id1 == id2
        @test typeof(id1) == Int64
    end

    # Test with multiple fields (composite)
    @testset "With multiple fields" begin
        GenId.reset_globabl_machine_id_increment(0)
        def_composite = TSIDGenericContainer(
            Int64,
            :TestComposite,
            [
                TimestampField(Int64, 22, 41, epoch),
                ConstantField(Int64, :machine_id, 12, 10, 5),
                MachineSequenceField(Int64, 0, 12)
            ],
            make_crockford_base_32_coder()
        )
        id1 = tsid_generate(def_composite)
        id2 = tsid_generate(def_composite)

        # Extract and verify fields
        timestamp1 = tsid_getfield_value(def_composite, :timestamp, id1)
        machine1 = tsid_getfield_value(def_composite, :machine_id, id1)
        sequence1 = tsid_getfield_value(def_composite, :machine_sequence, id1)

        timestamp2 = tsid_getfield_value(def_composite, :timestamp, id2)
        machine2 = tsid_getfield_value(def_composite, :machine_id, id2)
        sequence2 = tsid_getfield_value(def_composite, :machine_sequence, id2)

        @test machine1 == 5
        @test machine2 == 5
        @test sequence2 == sequence1 + 1  # Sequence increments
        @test timestamp2 >= timestamp1  # Timestamp monotonic
    end

    # Test with Int128 type
    @testset "With Int128 type" begin
        def_int128 = TSIDGenericContainer(
            Int128,
            :TestInt128,
            [
                TimestampField(Int128, 80, 47, epoch),
                RandomField(Int128, 0, 80)
            ],
            make_crockford_base_32_coder()
        )
        id = tsid_generate(def_int128)
        @test typeof(id) == Int128
        @test id >= 0  # Should be positive
    end

    # Test with UInt64 type
    @testset "With UInt64 type" begin
        def_uint64 = TSIDGenericContainer(
            UInt64,
            :TestUInt64,
            [RandomField(UInt64, 0, 32)],
            make_crockford_base_32_coder()
        )
        id = tsid_generate(def_uint64)
        @test typeof(id) == UInt64
    end

    # Note: UInt128 type with Crockford not tested here due to missing encoder
    # (can test tsid_generate separately without tsid_to_string)
    @testset "With UInt128 type - generation only" begin
        def_uint128 = TSIDGenericContainer(
            UInt128,
            :TestUInt128,
            [RandomField(UInt128, 0, 64)],
            make_crockford_base_32_coder()
        )
        id = tsid_generate(def_uint128)
        @test typeof(id) == UInt128
    end
end
