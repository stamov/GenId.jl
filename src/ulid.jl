
const UL_ID_FIELD_TIMESTAMP = TimestampField(UInt64, 80, 47, UNIX_EPOCH_START)
const UL_ID_FIELD_RANDOM = RandomField(UInt128, 0, 80)

function ULIdDefinition()
    TSIDGenericContainer(
        Int128,
        :ULIdDefinition,
        [
            UL_ID_FIELD_TIMESTAMP,
            UL_ID_FIELD_RANDOM
        ])
end

const ULID_DEFINITION = ULIdDefinition()