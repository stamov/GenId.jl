# Snowflake ID tests

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
