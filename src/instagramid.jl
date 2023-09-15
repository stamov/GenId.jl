
const INSTAGRAM_ID_FIELD_MACHINE_SEQUENCE = MachineSequenceField(Int64, 0, 10)

function InstagramIdDefinition(epoch_start_dt::DateTime, machine_id::Int64)
    TSIDGenericContainer(
        Int64,
        :InstagramIdDefinition,
        [
            TimestampField(Int64, 22, 41, epoch_start_dt),
            ConstantField(UInt64, :machine_id, 10, 12, machine_id),
            INSTAGRAM_ID_FIELD_MACHINE_SEQUENCE
        ])
end
