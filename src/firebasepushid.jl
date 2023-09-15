
const FIREBASE_PUSH_ID_FIELD_TIMESTAMP = TimestampField(UInt64, :timestamp, 72, 47, UNIX_EPOCH_START)
const FIREBASE_PUSH_ID_FIELD_RANDOM = RandomField{UInt128}(UInt128, :random, 0, 72)

function FirebasePushIdDefinition()
    TSIDGenericContainer(
    Int128, 
    :FirebasePushIdDefinition, 
    [
        FIREBASE_PUSH_ID_FIELD_TIMESTAMP, 
        FIREBASE_PUSH_ID_FIELD_RANDOM
    ])
end

const FIREBASE_PUSHID_DEFINITION = FirebasePushIdDefinition()