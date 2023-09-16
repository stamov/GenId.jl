
const FIREBASE_PUSH_ID_FIELD_TIMESTAMP = TimestampField(UInt64, 72, 47, UNIX_EPOCH_START)
const FIREBASE_PUSH_ID_FIELD_RANDOM = RandomField(UInt128, 0, 72)

function FirebasePushIdDefinition()
    TSIDGenericContainer(
        Int128, 
        :FirebasePushIdDefinition, 
        [
            FIREBASE_PUSH_ID_FIELD_TIMESTAMP, 
            FIREBASE_PUSH_ID_FIELD_RANDOM
        ],
        text_algorithm=:base_64,
        text_full_width=true,
        text_max_length=20
    )
end

const FIREBASE_PUSHID_DEFINITION = FirebasePushIdDefinition()