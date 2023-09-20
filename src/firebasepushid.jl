
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
        make_basic_coder(;
            algorithm=:base_64, 
            bits_per_character=6,
            dictionary="-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz",
            pad_char='0',
            has_checksum=false,
            use_full_with=true,
            max_string_length=20
        )
    )
end

const FIREBASE_PUSHID_DEFINITION = FirebasePushIdDefinition()