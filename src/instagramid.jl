
const INSTAGRAM_ID_FIELD_MACHINE_SEQUENCE = MachineSequenceField(Int64, 0, 10)

function InstagramIdDefinition(epoch_start_dt::DateTime, machine_id::Int64)
    TSIDGenericContainer(
        Int64,
        :InstagramIdDefinition,
        [
            TimestampField(Int64, 23, 41, epoch_start_dt),
            ConstantField(UInt64, :shard_id, 10, 13, machine_id),
            INSTAGRAM_ID_FIELD_MACHINE_SEQUENCE
        ],
        make_crockford_base_32_coder(;
            pad_char='0',
            has_checksum=false,
            use_full_with=true
        )
    )
end
