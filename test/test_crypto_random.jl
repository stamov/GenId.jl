# Cryptographic Random Field and Secure UUIDv7 Configuration Tests

@testset "CryptographicRandomField" begin
    # Test basic field creation
    field = CryptographicRandomField(UInt64, 0, 32)
    @test field.type == UInt64
    @test field.name == :crypto_random
    @test field.bits_offset == 0
    @test field.bits_length == 32

    # Test random value generation
    val1 = generate_field_value(field)
    val2 = generate_field_value(field)

    # Values should be different (statistically)
    @test val1 != val2  # Extremely unlikely to be equal with crypto random

    # Values should be within valid range (32 bits)
    @test 0 <= val1 <= (1 << 32)
    @test 0 <= val2 <= (1 << 32)

    # Test with different bit lengths
    for bits in [8, 16, 24, 32, 48, 62]
        field_test = CryptographicRandomField(UInt64, 0, bits)
        val = generate_field_value(field_test)
        @test 0 <= val <= (1 << bits)
    end

    # Test randomness distribution (should not have obvious patterns)
    # Generate 100 values and check they're all unique (statistically should be for crypto random)
    field_large = CryptographicRandomField(UInt128, 0, 64)
    values = Set([generate_field_value(field_large) for _ in 1:100])
    @test length(values) == 100  # All unique with high probability
end

@testset "Secure UUIDv7 Simple" begin
    defn = UUIDv7SecureSimpleDefinition()

    # Basic generation
    id = tsid_generate(defn)
    @test typeof(id) == Int128
    @test id > 0

    # RFC 9562 compliance
    version = (id >> 76) & 0xf
    @test version == 7

    variant = (id >> 62) & 0x3
    @test variant == 2

    # Timestamp validity
    timestamp = (id >> 80) & 0xffffffffffff
    now_ms = Dates.value(Dates.now()) - Dates.value(GenId.UNIX_EPOCH_START)
    @test abs(Int(timestamp) - Int(now_ms)) < 1000

    # Generate multiple IDs - should all be unique
    ids = Set([tsid_generate(defn) for _ in 1:100])
    @test length(ids) == 100  # All unique

    # Const definition works
    id_const = tsid_generate(UUIDV7_SECURE_SIMPLE_DEFINITION)
    @test typeof(id_const) == Int128

    # Text encoding round-trip
    id_original = tsid_generate(defn)
    id_str = tsid_to_string(defn, id_original)
    id_decoded = tsid_int_from_string(defn, id_str)
    @test id_original == id_decoded

    # String length check (hex without dashes = 32 chars)
    @test length(id_str) == 32
end

@testset "Secure UUIDv7 Monotonic" begin
    defn = UUIDv7SecureMonotonicDefinition()

    # Reset counter to known state
    reset_uuidv7_monotonic_counter(0)

    # Generate sequence - should be strictly monotonic
    ids = [tsid_generate(defn) for _ in 1:50]

    # Check strict monotonic ordering
    for i in 2:length(ids)
        @test ids[i] > ids[i-1]
    end

    # All should be unique
    @test length(unique(ids)) == length(ids)

    # RFC 9562 compliance
    for id in ids
        version = (id >> 76) & 0xf
        @test version == 7

        variant = (id >> 62) & 0x3
        @test variant == 2
    end

    # Const definition works
    id_const = tsid_generate(UUIDV7_SECURE_MONOTONIC_DEFINITION)
    @test typeof(id_const) == Int128

    # Text encoding round-trip
    id_original = tsid_generate(defn)
    id_str = tsid_to_string(defn, id_original)
    id_decoded = tsid_int_from_string(defn, id_str)
    @test id_original == id_decoded
end

@testset "Secure UUIDv7 Sub-millisecond" begin
    defn = UUIDv7SecureSubMillisecondDefinition()

    # Basic generation
    id = tsid_generate(defn)
    @test typeof(id) == Int128
    @test id > 0

    # Extract sub-millisecond fraction
    subsec_fraction = (id >> 64) & 0xfff
    @test subsec_fraction >= 0
    @test subsec_fraction < 4096  # 12 bits max value

    # RFC 9562 compliance
    version = (id >> 76) & 0xf
    @test version == 7

    variant = (id >> 62) & 0x3
    @test variant == 2

    # Generate multiple IDs
    ids = [tsid_generate(defn) for _ in 1:20]

    # Should have temporal ordering (mostly)
    timestamps = [(id >> 80) & 0xffffffffffff for id in ids]
    @test timestamps[end] >= timestamps[1]
    @test timestamps[end] - timestamps[1] < 100  # Within 100ms

    # Const definition works
    id_const = tsid_generate(UUIDV7_SECURE_SUBMILLISECOND_DEFINITION)
    @test typeof(id_const) == Int128
end

@testset "Secure UUIDv7 Distributed" begin
    # Test various machine IDs
    for machine_id in [0, 1, 31, 63]
        defn = UUIDv7SecureDistributedDefinition(machine_id)

        # Basic generation
        id = tsid_generate(defn)
        @test typeof(id) == Int128
        @test id > 0

        # Extract and verify machine ID
        extracted_machine_id = (id >> 70) & 0x3f
        @test extracted_machine_id == machine_id

        # Also test via field extraction
        field_machine_id = tsid_getfield_value(defn, :machine_id, id)
        @test field_machine_id == machine_id

        # RFC 9562 compliance
        version = (id >> 76) & 0xf
        @test version == 7

        variant = (id >> 62) & 0x3
        @test variant == 2
    end

    # Test machine ID validation
    @test_throws ArgumentError UUIDv7SecureDistributedDefinition(-1)
    @test_throws ArgumentError UUIDv7SecureDistributedDefinition(64)
end

@testset "Secure vs Non-Secure Comparison" begin
    # Both should produce valid UUIDs
    defn_standard = UUIDv7SimpleDefinition()
    defn_secure = UUIDv7SecureSimpleDefinition()

    id_standard = tsid_generate(defn_standard)
    id_secure = tsid_generate(defn_secure)

    # Both should be valid Int128
    @test typeof(id_standard) == Int128
    @test typeof(id_secure) == Int128

    # Both should have correct version/variant
    @test (id_standard >> 76) & 0xf == 7
    @test (id_secure >> 76) & 0xf == 7
    @test (id_standard >> 62) & 0x3 == 2
    @test (id_secure >> 62) & 0x3 == 2

    # Timestamps should be similar (within 1 second)
    ts_standard = (id_standard >> 80) & 0xffffffffffff
    ts_secure = (id_secure >> 80) & 0xffffffffffff
    @test abs(Int(ts_standard) - Int(ts_secure)) < 1000

    # Random bits will be different (statistical test)
    # Extract the 62-bit random payload
    random_standard = id_standard & ((Int128(1) << 62) - 1)
    random_secure = id_secure & ((Int128(1) << 62) - 1)
    @test random_standard != random_secure  # Should be different (statistically)
end

@testset "Cryptographic Randomness Quality" begin
    # Statistical test: Generate many IDs and check randomness distribution
    # For cryptographic random, we should see no obvious patterns

    defn = UUIDv7SecureSimpleDefinition()
    ids = [tsid_generate(defn) for _ in 1:1000]

    # All should be unique
    @test length(unique(ids)) == 1000

    # Extract random bits (lower 62 bits)
    random_bits = [id & ((Int128(1) << 62) - 1) for id in ids]

    # All random bits should be unique (with high probability for crypto random)
    @test length(unique(random_bits)) == 1000

    # Check bit distribution (roughly 50% should have bit 0 set, etc.)
    # This is a simple statistical test
    bit_0_count = sum([id & 1 for id in random_bits])
    # Should be roughly 500 ± some tolerance (using 100 for safety)
    @test 400 <= bit_0_count <= 600

    # Check for runs (should not have long sequences of similar values)
    # Sort and check no two adjacent values are too close
    sorted_random = sort(random_bits)
    min_distance = minimum([sorted_random[i+1] - sorted_random[i] for i in 1:length(sorted_random)-1])
    # With 62 bits and 1000 samples, minimum distance should be reasonably large
    @test min_distance > 1000  # At least 1000 apart (very weak test, but catches obvious issues)
end
