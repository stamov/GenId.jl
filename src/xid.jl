
const XID_FIELD_TIMESTAMP = TimestampField(UInt64, 64, 32, UNIX_EPOCH_START)
const XID_FIELD_MACHINE_SEQUENCE = MachineSequenceField(Int64, 0, 24)

function XIdDefinition(machine_id::Int64)
    TSIDGenericContainer(
        Int128,
        :XIdDefinition,
        [
            XID_FIELD_TIMESTAMP,
            ConstantField(UInt64, :machine_id, 40, 24, machine_id),
            ProcessIdField(UInt64, 24, 16),
            XID_FIELD_MACHINE_SEQUENCE
        ])
end

