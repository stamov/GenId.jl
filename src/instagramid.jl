
function InstagramIdDefinition(epoch_start_dt::DateTime, machine_id::Int64)
    bits_time = 41
    v_epoch_end_dt = epoch_end_dt_from_epoch_start(epoch_start_dt, bits_time)
    def = TsIdDefinition(
        Int64;
        name=:InstagramIdDefinition,
        bits_time=bits_time,
        bits_group_1=12,
        bits_tail=10,
        group_1=machine_id,
        tail_algorithm=:machine_increment,
        epoch_start_dt=epoch_start_dt,
        epoch_end_dt=v_epoch_end_dt
    )
    return def
end

function tsid_generate(::Type{Val{:InstagramIdDefinition}}, def::TsIdDefinition)
    return tsid_generate(Val{:TsIdDefinition}, def)
end

