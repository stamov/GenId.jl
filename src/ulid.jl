
const UL_ID_FIELD_TIMESTAMP = TimestampField(UInt64, :timestamp, 80, 47, UNIX_EPOCH_START)
const UL_ID_FIELD_RANDOM = RandomField{UInt128}(UInt128, :random, 0, 80)

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