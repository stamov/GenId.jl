
# struct FirebasePushIdDefinition
#     function FirebasePushIdDefinition()
#         return new()
#     end
# end

# function FirebasePushIdDefinition()
#     bits_time=47
#     epoch_start_dt = DateTime(1, 1, 1, 0, 0, 0, 0)
#     epoch_end_dt = epoch_end_dt_from_epoch_start(epoch_start_dt, bits_time)
#     def = TsIdDefinition(
#         Int128;
#         name=:FirebasePushIdDefinition,
#         bits_ignore_start=8,
#         bits_time=bits_time,
#         bits_group_1=0,
#         bits_tail=72,
#         text_algorithm = :base_64,
#         group_1=0,
#         tail_algorithm=:random,
#         epoch_start_dt=epoch_start_dt,
#         epoch_end_dt=epoch_end_dt
#     )
#     return def
# end

# _make_timestamp_FirebasePushIdDefinition() = convert(Int128, Dates.value(Dates.now())) << 72

# function tsid_generate(::Type{Val{:FirebasePushIdDefinition}}, def::TsIdDefinition)
#     ts = convert(UInt128, _make_timestamp_FirebasePushIdDefinition())
#     r = rand(0:convert(UInt128, 72))
#     # r_high = convert(UInt128, rand(0:(1 << 7))) << 64
#     # r_low = rand(typemin(UInt64):typemax(UInt64))
#     # return convert(Int128, ts | r_high | r_low)
#     return ts | r
# end

const FIREBASE_PUSH_ID_FIELD_TIMESTAMP = TimestampField{UInt64}(UInt64, :timestamp, 72, 47)
const FIREBASE_PUSH_ID_FIELD_RANDOM = RandomField{UInt128}(UInt128, :random, 0, 72)
# struct FirebasePushIdDefinition <: TSIDAbstractContainer
#     type::DataType
#     name::Symbol
#     field_timestamp::GeneratedField
#     field_random::GeneratedField
#     FirebasePushIdDefinition() = new(Int128, :FirebasePushIdDefinition, FIREBASE_PUSH_ID_FIELD_TIMESTAMP, FIREBASE_PUSH_ID_FIELD_RANDOM)
# end

function FirebasePushIdDefinition()
    TSIDGenericContainer(
    Int128, 
    :FirebasePushIdDefinition, 
    [
        FIREBASE_PUSH_ID_FIELD_TIMESTAMP, 
        FIREBASE_PUSH_ID_FIELD_RANDOM
    ])
end
