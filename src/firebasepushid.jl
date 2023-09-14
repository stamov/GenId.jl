function FirebasePushIdDefinition(epoch_start_dt::DateTime)
    bits_time = 48
    bits_tail= 72
    v_epoch_end_dt = epoch_end_dt_from_epoch_start(epoch_start_dt, bits_time)
    def = TsIdDefinition(
        Int128;
        name=:FirebasePushIdDefinition,
        bits_ignore_start=7,
        bits_time=bits_time,
        bits_group_1=0,
        bits_tail=bits_tail,
        group_1=0,
        tail_algorithm=:random,
        epoch_start_dt=epoch_start_dt,
        epoch_end_dt=v_epoch_end_dt
    )
    return def
end

_make_timestamp_FirebasePushIdDefinition() = convert(Int128, Dates.value(Dates.now())) << 72

function tsid_generate(::Type{Val{:FirebasePushIdDefinition}}, def::TsIdDefinition)
    ts = convert(UInt128, _make_timestamp_FirebasePushIdDefinition())
    r_high = convert(UInt128, rand(0:(1 << 7))) << 64
    r_low = rand(typemin(UInt64):typemax(UInt64))
    return convert(Int128, ts | r_high | r_low)
end



#BASE_64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
