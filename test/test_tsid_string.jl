# TSID string encoding/decoding tests

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
