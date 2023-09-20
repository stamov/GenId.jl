
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
        ],
        make_basic_coder(;
            algorithm=:base_32_hex,
            bits_per_character=6,
            dictionary="0123456789ABCDEFGHIJKLMNOPQRSTUV",
            pad_char='0',
            use_full_with=true,
            max_string_length=20
        )
    )
end

