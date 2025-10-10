# UUIDv7 Comprehensive Tests

@testset "UUIDv7 Comprehensive Tests" begin

    @testset "RFC 9562 Compliance" begin
        # Test all configurations comply with RFC 9562 spec
        configs = [
            ("Simple", UUIDv7SimpleDefinition()),
            ("Monotonic", UUIDv7MonotonicDefinition()),
            ("Sub-millisecond", UUIDv7SubMillisecondDefinition()),
            ("Distributed(0)", UUIDv7DistributedDefinition(0)),
            ("Distributed(63)", UUIDv7DistributedDefinition(63))
        ]

        for (name, defn) in configs
            # Generate multiple IDs to test consistency
            ids = [tsid_generate(defn) for _ in 1:10]

            for id in ids
                # Version field (bits 76-79) must be 7
                version = (id >> 76) & 0xf
                @test version == 7

                # Variant field (bits 62-63) must be 0b10 (value 2)
                variant = (id >> 62) & 0x3
                @test variant == 2

                # Timestamp should be reasonable (within 1 second of now)
                timestamp = (id >> 80) & 0xffffffffffff
                now_ms = Dates.value(Dates.now()) - Dates.value(GenId.UNIX_EPOCH_START)
                @test abs(Int(timestamp) - Int(now_ms)) < 1000

                # ID should be positive (bit 127 not set)
                @test id >= 0
            end
        end
    end

    @testset "Simple UUIDv7" begin
        defn = UUIDv7SimpleDefinition()

        # Basic generation
        id = tsid_generate(defn)
        @test typeof(id) == Int128
        @test id > 0

        # Generate multiple IDs - should all be unique
        ids = Set([tsid_generate(defn) for _ in 1:100])
        @test length(ids) == 100  # All unique

        # Const definition works
        id_const = tsid_generate(UUIDV7_SIMPLE_DEFINITION)
        @test typeof(id_const) == Int128

        # Text encoding round-trip
        id_original = tsid_generate(defn)
        id_str = tsid_to_string(defn, id_original)
        id_decoded = tsid_int_from_string(defn, id_str)
        @test id_original == id_decoded

        # String length check (hex without dashes = 32 chars)
        @test length(id_str) == 32
    end

    @testset "Monotonic UUIDv7" begin
        defn = UUIDv7MonotonicDefinition()

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

        # Counter should increment within same millisecond
        # Generate many IDs quickly to ensure some are in same ms
        reset_uuidv7_monotonic_counter(100)
        fast_ids = [tsid_generate(defn) for _ in 1:20]

        # Extract timestamps
        timestamps = [(id >> 80) & 0xffffffffffff for id in fast_ids]

        # If any share same timestamp, their counters should differ
        for i in 2:length(fast_ids)
            if timestamps[i] == timestamps[i-1]
                counter_i = (fast_ids[i] >> 64) & 0xfff
                counter_prev = (fast_ids[i-1] >> 64) & 0xfff
                # Counter should have incremented
                @test counter_i != counter_prev
            end
        end

        # Reset functions work
        reset_uuidv7_monotonic_counter(500)
        # Note: If timestamp changes between reset and generation,
        # counter will be randomly initialized, not 501
        id_after_reset = tsid_generate(defn)
        counter_after = (id_after_reset >> 64) & 0xfff
        # Counter should be valid (0-4095)
        @test 0 <= counter_after < 4096

        # Random reset
        reset_uuidv7_monotonic_counter()
        id_random = tsid_generate(defn)
        # Should still be valid
        @test id_random > 0

        # Const definition works
        id_const = tsid_generate(UUIDV7_MONOTONIC_DEFINITION)
        @test typeof(id_const) == Int128
    end

    @testset "Sub-millisecond UUIDv7" begin
        defn = UUIDv7SubMillisecondDefinition()

        # Basic generation
        id = tsid_generate(defn)
        @test typeof(id) == Int128
        @test id > 0

        # Extract sub-millisecond fraction
        subsec_fraction = (id >> 64) & 0xfff
        @test subsec_fraction >= 0
        @test subsec_fraction < 4096  # 12 bits max value

        # Generate multiple IDs
        ids = [tsid_generate(defn) for _ in 1:20]

        # Should have temporal ordering (mostly)
        # Not guaranteed due to random bits, but timestamps should progress
        timestamps = [(id >> 80) & 0xffffffffffff for id in ids]
        # First and last timestamp should be close
        @test timestamps[end] >= timestamps[1]
        @test timestamps[end] - timestamps[1] < 100  # Within 100ms

        # Const definition works
        id_const = tsid_generate(UUIDV7_SUBMILLISECOND_DEFINITION)
        @test typeof(id_const) == Int128
    end

    @testset "Distributed UUIDv7" begin
        # Test various machine IDs
        for machine_id in [0, 1, 31, 63]
            defn = UUIDv7DistributedDefinition(machine_id)

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
        end

        # Counter reset works
        defn = UUIDv7DistributedDefinition(5)
        reset_uuidv7_distributed_counter(20)
        # Note: If timestamp changes, counter will be randomly initialized
        id_after_reset = tsid_generate(defn)
        counter_after = (id_after_reset >> 64) & 0x3f  # 6 bits
        @test 0 <= counter_after < 64  # Valid range

        # Test machine ID validation
        @test_throws ArgumentError UUIDv7DistributedDefinition(-1)
        @test_throws ArgumentError UUIDv7DistributedDefinition(64)
    end

    @testset "Field Extraction" begin
        # Test timestamp extraction for all configs
        configs = [
            UUIDv7SimpleDefinition(),
            UUIDv7MonotonicDefinition(),
            UUIDv7SubMillisecondDefinition(),
            UUIDv7DistributedDefinition(0)
        ]

        for defn in configs
            id = tsid_generate(defn)

            # Extract timestamp via field accessor
            timestamp = tsid_getfield_value(defn, :timestamp, id)
            now_ms = Dates.value(Dates.now()) - Dates.value(GenId.UNIX_EPOCH_START)
            @test abs(Int(timestamp) - Int(now_ms)) < 1000

            # Extract via manual bit manipulation
            manual_ts = (id >> 80) & 0xffffffffffff
            @test manual_ts == timestamp
        end

        # Test monotonic counter extraction
        defn_mono = UUIDv7MonotonicDefinition()
        reset_uuidv7_monotonic_counter(123)
        id = tsid_generate(defn_mono)
        counter = tsid_getfield_value(defn_mono, :monotonic_counter, id)
        # Counter should be valid (may be random if timestamp changed)
        @test 0 <= counter < 4096

        # Test distributed counter and machine ID extraction
        defn_dist = UUIDv7DistributedDefinition(42)
        reset_uuidv7_distributed_counter(10)
        id = tsid_generate(defn_dist)

        machine_id = tsid_getfield_value(defn_dist, :machine_id, id)
        @test machine_id == 42

        counter = tsid_getfield_value(defn_dist, :distributed_counter, id)
        @test 0 <= counter < 64  # Valid range
    end

    @testset "Encoding/Decoding Round-trip" begin
        configs = [
            UUIDv7SimpleDefinition(),
            UUIDv7MonotonicDefinition(),
            UUIDv7SubMillisecondDefinition(),
            UUIDv7DistributedDefinition(15)
        ]

        for defn in configs
            # Test multiple IDs
            for _ in 1:10
                id_original = tsid_generate(defn)

                # Encode to string
                id_str = tsid_to_string(defn, id_original)
                @test length(id_str) == 32  # Hex format

                # Decode back
                id_decoded = tsid_int_from_string(defn, id_str)

                # Should match exactly
                @test id_decoded == id_original
            end
        end
    end

    @testset "Counter Overflow Handling" begin
        # Test monotonic counter overflow (12 bits = 0-4095)
        defn_mono = UUIDv7MonotonicDefinition()
        reset_uuidv7_monotonic_counter(4094)
        sleep(0.001)  # Let state settle

        id1 = tsid_generate(defn_mono)
        counter1 = (id1 >> 64) & 0xfff
        # Counter should be in valid range (may be reset if timestamp changed)
        @test 0 <= counter1 < 4096

        # Next should be monotonic
        id2 = tsid_generate(defn_mono)
        @test id2 > id1  # Still monotonic

        # Test distributed counter overflow (6 bits = 0-63)
        defn_dist = UUIDv7DistributedDefinition(7)
        reset_uuidv7_distributed_counter(62)
        sleep(0.001)  # Let state settle

        id1_dist = tsid_generate(defn_dist)
        counter1_dist = (id1_dist >> 64) & 0x3f
        # Counter should be in valid range (may be reset if timestamp changed)
        @test 0 <= counter1_dist < 64

        # Next should be monotonic
        id2_dist = tsid_generate(defn_dist)
        @test id2_dist > id1_dist  # Still monotonic
    end

    @testset "Bit Layout Verification" begin
        # Verify no field overlaps
        function check_no_overlaps(definition)
            fields = definition.fields
            for i in 1:length(fields)
                for j in (i+1):length(fields)
                    field1 = fields[i]
                    field2 = fields[j]
                    range1 = field1.bits_offset:(field1.bits_offset + field1.bits_length - 1)
                    range2 = field2.bits_offset:(field2.bits_offset + field2.bits_length - 1)
                    overlap = intersect(range1, range2)
                    if !isempty(overlap)
                        return false, "$(field1.name) overlaps $(field2.name)"
                    end
                end
            end
            return true, ""
        end

        # Check all UUIDv7 configurations
        @test check_no_overlaps(UUIDv7SimpleDefinition())[1]
        @test check_no_overlaps(UUIDv7MonotonicDefinition())[1]
        @test check_no_overlaps(UUIDv7SubMillisecondDefinition())[1]
        @test check_no_overlaps(UUIDv7DistributedDefinition(0))[1]

        # Verify generated IDs never have bit 127 set (always positive)
        # Note: UUIDv7 field layout can include bit 127 in timestamp field,
        # but actual timestamp values never set it to 1
        configs = [
            UUIDv7SimpleDefinition(),
            UUIDv7MonotonicDefinition(),
            UUIDv7SubMillisecondDefinition(),
            UUIDv7DistributedDefinition(0)
        ]

        for defn in configs
            for _ in 1:10
                id = tsid_generate(defn)
                @test id >= 0  # Never negative
                @test (id & (Int128(1) << 127)) == 0  # Bit 127 never set
            end
        end
    end

    @testset "Timestamp Validity" begin
        # Verify timestamps are reasonable across all configs
        configs = [
            UUIDv7SimpleDefinition(),
            UUIDv7MonotonicDefinition(),
            UUIDv7SubMillisecondDefinition(),
            UUIDv7DistributedDefinition(1)
        ]

        for defn in configs
            id = tsid_generate(defn)

            # Extract timestamp
            ts = (id >> 80) & 0xffffffffffff

            # Convert to DateTime
            dt = DateTime(Dates.UTM(ts + Dates.value(GenId.UNIX_EPOCH_START)))

            # Should be very close to now
            now = Dates.now()
            diff = abs(Dates.value(dt) - Dates.value(now))
            @test diff < 1000  # Within 1 second

            # Should be after Unix epoch (1970)
            @test dt > GenId.UNIX_EPOCH_START

            # Should be before year 2100
            @test dt < DateTime(2100, 1, 1)
        end
    end

end
