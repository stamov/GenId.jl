
function SnowflakeIdDefinition(epoch_start_dt::DateTime, machine_id::Int64)
    bits_time = 41
    v_epoch_end_dt = DateTime(Dates.UTM(Dates.value(epoch_start_dt) + convert(Int64, (1 << bits_time) - 1)))
    def = TsIdDefinition(
        Int64;
        name=:SnowflakeIdDefinition,
        bits_time=bits_time,
        bits_group_1=10,
        bits_tail=12,
        group_1=machine_id,
        tail_algorithm=:machine_increment,
        epoch_start_dt=epoch_start_dt,
        epoch_end_dt=v_epoch_end_dt
    )
    return def
end

