# Bit layout integrity and field overlap detection tests

@testset "Int128 bit 127 handling" begin
    # Verify bit 127 is never set in generated IDs
    for i in 1:100
        id = tsid_generate(ULID_DEFINITION)
        @test id >= 0  # Never negative
        @test (id & (Int128(1) << 127)) == 0  # Bit 127 never set
    end

    # Note: The system uses bits 0-126 (127 bits), not the full 128 bits
    # Different encoding schemes have different maximum values due to bit alignment
    # We test with safe values that work across all encodings

    # Test with large but safe values (using bits 0-120, leaving bits 121-127 unused)
    # This ensures compatibility across all encoding schemes
    safe_max = (Int128(1) << 120) - 1

    # Test ULID with safe large value
    encoded = tsid_to_string(ULID_DEFINITION, safe_max)
    decoded = tsid_int_from_string(ULID_DEFINITION, encoded)
    @test decoded == safe_max

    # Test Firebase Push ID with safe large value
    fb_encoded = tsid_to_string(FIREBASE_PUSHID_DEFINITION, safe_max)
    fb_decoded = tsid_int_from_string(FIREBASE_PUSHID_DEFINITION, fb_encoded)
    @test fb_decoded == safe_max

    # Test Nano ID with safe large value
    nano_def = InsecureNanoIdDefinition()
    nano_encoded = tsid_to_string(nano_def, safe_max)
    nano_decoded = tsid_int_from_string(nano_def, nano_encoded)
    @test nano_decoded == safe_max

    # Verify all bits 0-63 can be represented (lower 64 bits)
    lower_max = (Int128(1) << 64) - 1  # All lower 64 bits set
    encoded_lower = tsid_to_string(ULID_DEFINITION, lower_max)
    decoded_lower = tsid_int_from_string(ULID_DEFINITION, encoded_lower)
    @test decoded_lower == lower_max

    # Test with upper bits set (bits 64-119)
    upper_safe = ((Int128(1) << 56) - 1) << 64  # 56 bits set in upper range
    encoded_upper = tsid_to_string(ULID_DEFINITION, upper_safe)
    decoded_upper = tsid_int_from_string(ULID_DEFINITION, encoded_upper)
    @test decoded_upper == upper_safe
end

@testset "Field overlap detection" begin
    # Helper function to check for overlaps
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
                    return false, "$(field1.name) (bits $range1) overlaps with $(field2.name) (bits $range2) at bits $overlap"
                end
            end
        end
        return true, ""
    end

    # Verify no fields overlap in each definition
    @test check_no_overlaps(ULID_DEFINITION)[1]
    @test check_no_overlaps(FIREBASE_PUSHID_DEFINITION)[1]
    nano_def = InsecureNanoIdDefinition()
    @test check_no_overlaps(nano_def)[1]

    snowflake_def = SnowflakeIdDefinition(SOME_EPOCH_START_2020, convert(Int64, 1))
    @test check_no_overlaps(snowflake_def)[1]

    instagram_def = InstagramIdDefinition(SOME_EPOCH_START_2020, 1)
    @test check_no_overlaps(instagram_def)[1]

    xid_def = XIdDefinition(1)
    @test check_no_overlaps(xid_def)[1]

    # Verify total bits don't exceed 127 for Int128 containers
    function check_total_bits(definition)
        if definition.type != Int128
            return true  # Only checking Int128 containers
        end

        total_bits = 0
        max_bit = -1
        for field in definition.fields
            total_bits += field.bits_length
            field_max_bit = field.bits_offset + field.bits_length - 1
            if field_max_bit > max_bit
                max_bit = field_max_bit
            end
        end

        # Max bit should be at most 126 (0-indexed, so 127 bits total)
        return max_bit <= 126
    end

    @test check_total_bits(ULID_DEFINITION)
    @test check_total_bits(FIREBASE_PUSHID_DEFINITION)
    @test check_total_bits(nano_def)
    @test check_total_bits(xid_def)
end
