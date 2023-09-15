
const SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE = MachineSequenceField(Int64, 0, 12)

function SnowflakeIdDefinition(epoch_start_dt::DateTime, machine_id::Int64)
    TSIDGenericContainer(
        Int64,
        :SnowflakeIdDefinition,
        [
            TimestampField(Int64, 22, 41, epoch_start_dt),
            ConstantField(UInt64, :machine_id, 12, 10, machine_id),
            SNOWFLAKE_ID_FIELD_MACHINE_SEQUENCE
        ])
end
