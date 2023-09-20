const UUIDv7_1_FIELD_TIMESTAMP = TimestampField(Int64, 76, 48, UNIX_EPOCH_START)
const UUIDv7_1_FIELD_VERSION = ConstantField(Int64, :variant, 72, 4, 7)
const UUIDv7_1_FIELD_MACHINE_SEQUENCE = MachineSequenceField(Int64, 64, 12)
const UUIDv7_1_FIELD_VARIANT = ConstantField(Int64, :variant, 62, 2, 2)
const UUIDv7_1_FIELD_RANDOM = RandomField(UInt64, 0, 62)

const UUIDv7_1_ID_FIELD_RANDOM = RandomField(UInt128, 0, 72)
function UUIDv7_1_IdDefinition()
    TSIDGenericContainer(
        Int128,
        :UUIDv7_1_IdDefinition,
        [
            UUIDv7_1_FIELD_TIMESTAMP,
            UUIDv7_1_FIELD_VERSION,
            UUIDv7_1_FIELD_MACHINE_SEQUENCE,
            UUIDv7_1_FIELD_VARIANT,
            UUIDv7_1_FIELD_RANDOM
        ],
        text_algorithm=:base_32_hex,
        text_full_width=true,
        #text_max_length=20
    )
end
