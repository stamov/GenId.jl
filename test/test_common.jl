# Common test setup and quality checks

# Common constants used across tests
const SOME_EPOCH_START_2020 = DateTime(2020, 1, 1, 0, 0, 0, 0)
const SOME_EPOCH_START_VALUE_2020 = Dates.value(SOME_EPOCH_START_2020)
const SOME_EPOCH_END_2070 = DateTime(2070, 12, 31, 23, 59, 59, 999)
const SOME_EPOCH_END_VALUE_2070 = Dates.value(SOME_EPOCH_END_2070)
const SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE = MachineSequenceField(Int64, 0, 12)

@testset "GenId.quality" begin
    # Aqua.test_all(GenId; deps_compat=false)
    Aqua.test_all(GenId)
end
