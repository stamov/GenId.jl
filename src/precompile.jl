# Precompilation workload for GenId
# This file uses PrecompileTools to reduce Time To First X (TTFX) for GenId operations

using PrecompileTools

@compile_workload begin
    # Common test epoch and machine ID
    test_epoch = DateTime(2020, 1, 1)
    test_machine_id = Int64(1)

    # ==========================================================================
    # Int64-based ID Types (Snowflake, Instagram)
    # ==========================================================================

    # Snowflake ID
    sf_def = SnowflakeIdDefinition(test_epoch, test_machine_id)
    sf_id = tsid_generate(sf_def)
    sf_str = tsid_to_string(sf_def, sf_id)
    tsid_int_from_string(sf_def, sf_str)
    tsid_getfield_value(sf_def, :timestamp, sf_id)
    tsid_getfield_value(sf_def, :machine_id, sf_id)
    tsid_getfield_value(sf_def, :machine_sequence, sf_id)
    tsid_generate_string(sf_def)

    # Instagram ID
    ig_def = InstagramIdDefinition(test_epoch, test_machine_id)
    ig_id = tsid_generate(ig_def)
    ig_str = tsid_to_string(ig_def, ig_id)
    tsid_int_from_string(ig_def, ig_str)
    tsid_getfield_value(ig_def, :timestamp, ig_id)
    tsid_generate_string(ig_def)

    # ==========================================================================
    # Int128-based ID Types (ULID, XID, Firebase, NanoID, UUIDv7)
    # ==========================================================================

    # ULID - Note: String ops skipped for Int128 types due to encoding bugs
    ulid_def = ULIdDefinition()
    ulid_id = tsid_generate(ulid_def)
    tsid_getfield_value(ulid_def, :timestamp, ulid_id)

    # Use predefined constant
    ulid_id2 = tsid_generate(ULID_DEFINITION)

    # XID - Note: String ops skipped for Int128 types due to encoding bugs
    xid_def = XIdDefinition(test_machine_id)
    xid_id = tsid_generate(xid_def)
    tsid_getfield_value(xid_def, :timestamp, xid_id)

    # Firebase Push ID - Note: String ops skipped for Int128 types due to encoding bugs
    fb_def = FirebasePushIdDefinition()
    fb_id = tsid_generate(fb_def)
    tsid_getfield_value(fb_def, :timestamp, fb_id)

    # Use predefined constant
    fb_id2 = tsid_generate(FIREBASE_PUSHID_DEFINITION)

    # NanoID (Insecure) - Note: String ops skipped for Int128 types due to encoding bugs
    nano_def = InsecureNanoIdDefinition()
    nano_id = tsid_generate(nano_def)

    # ==========================================================================
    # UUIDv7 Variants (all 4 configurations)
    # Note: String encoding operations skipped due to library encoding bugs with Int128
    # ==========================================================================

    # UUIDv7 Simple
    uuid7_simple_def = UUIDv7SimpleDefinition()
    uuid7_simple_id = tsid_generate(uuid7_simple_def)
    tsid_getfield_value(uuid7_simple_def, :timestamp, uuid7_simple_id)

    # Use predefined constant
    uuid7_simple_id2 = tsid_generate(UUIDV7_SIMPLE_DEFINITION)

    # UUIDv7 Monotonic (Recommended)
    uuid7_mono_def = UUIDv7MonotonicDefinition()
    uuid7_mono_id = tsid_generate(uuid7_mono_def)
    tsid_getfield_value(uuid7_mono_def, :timestamp, uuid7_mono_id)
    tsid_getfield_value(uuid7_mono_def, :monotonic_counter, uuid7_mono_id)

    # Use predefined constant
    uuid7_mono_id2 = tsid_generate(UUIDV7_MONOTONIC_DEFINITION)

    # UUIDv7 Sub-millisecond
    uuid7_sub_def = UUIDv7SubMillisecondDefinition()
    uuid7_sub_id = tsid_generate(uuid7_sub_def)
    tsid_getfield_value(uuid7_sub_def, :timestamp, uuid7_sub_id)

    # Use predefined constant
    uuid7_sub_id2 = tsid_generate(UUIDV7_SUBMILLISECOND_DEFINITION)

    # UUIDv7 Distributed
    uuid7_dist_def = UUIDv7DistributedDefinition(5)
    uuid7_dist_id = tsid_generate(uuid7_dist_def)
    tsid_getfield_value(uuid7_dist_def, :timestamp, uuid7_dist_id)
    tsid_getfield_value(uuid7_dist_def, :machine_id, uuid7_dist_id)
    tsid_getfield_value(uuid7_dist_def, :distributed_counter, uuid7_dist_id)

    # ==========================================================================
    # UUIDv7 Secure Variants (cryptographic random)
    # Note: String encoding operations skipped due to library encoding bugs with Int128
    # ==========================================================================

    # UUIDv7 Secure Simple
    uuid7_sec_simple_def = UUIDv7SecureSimpleDefinition()
    uuid7_sec_simple_id = tsid_generate(uuid7_sec_simple_def)

    # Use predefined constant
    uuid7_sec_simple_id2 = tsid_generate(UUIDV7_SECURE_SIMPLE_DEFINITION)

    # UUIDv7 Secure Monotonic
    uuid7_sec_mono_def = UUIDv7SecureMonotonicDefinition()
    uuid7_sec_mono_id = tsid_generate(uuid7_sec_mono_def)

    # Use predefined constant
    uuid7_sec_mono_id2 = tsid_generate(UUIDV7_SECURE_MONOTONIC_DEFINITION)

    # UUIDv7 Secure Sub-millisecond
    uuid7_sec_sub_def = UUIDv7SecureSubMillisecondDefinition()
    uuid7_sec_sub_id = tsid_generate(uuid7_sec_sub_def)

    # Use predefined constant
    uuid7_sec_sub_id2 = tsid_generate(UUIDV7_SECURE_SUBMILLISECOND_DEFINITION)

    # UUIDv7 Secure Distributed
    uuid7_sec_dist_def = UUIDv7SecureDistributedDefinition(10)
    uuid7_sec_dist_id = tsid_generate(uuid7_sec_dist_def)

    # ==========================================================================
    # Text Encoding/Decoding Functions
    # ==========================================================================

    # Crockford Base32 - Int64
    crockford32_encode_int64(Int64(123456789))
    crockford32_encode_uint64(UInt64(123456789))
    crockford32_decode_int64("3V2S3")
    crockford32_decode_uint64("3V2S3")

    # Crockford Base32 - Int128 (skipped due to encoding bugs)
    # crockford32_encode_int128(Int128(123456789012345))
    # crockford32_decode_int128("1CD0ZYS59")
    # crockford32_decode_uint128("1CD0ZYS59")

    # Text coders
    make_crockford_base_32_coder()
    make_crockford_base_32_coder(pad_char='0', has_checksum=false, use_full_with=true)
    make_basic_coder(algorithm=:base_16, bits_per_character=4,
                     dictionary="0123456789abcdef", pad_char='0', use_full_with=true)

    # ==========================================================================
    # Bit Manipulation Operations
    # ==========================================================================

    # Bit masking
    bit_mask_uint(UInt64, 0xFFFFFFFF, 0, 32)
    bit_mask_int(Int64, 123456789, 0, 32)
    bit_mask_uint(UInt128, 0xFFFFFFFFFFFFFFFF, 0, 64)
    bit_mask_int(Int128, 123456789012345, 0, 64)

    # Field operations (using example fields)
    test_field = TimestampField(Int64, 22, 41, test_epoch)
    generate_field_value(test_field)
    extract_value_from_bits(test_field, Int64, sf_id)
    implant_value_into_int(Int64(0), test_field, Int64(1000))

    # ==========================================================================
    # Utility Functions
    # ==========================================================================

    reset_globabl_machine_id_increment()
    reset_uuidv7_monotonic_counter()
    reset_uuidv7_distributed_counter()
end
