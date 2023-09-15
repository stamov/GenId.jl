
function ULIdDefinition()
    bits_time = 47
    v_epoch_end_dt = epoch_end_dt_from_epoch_start(UNIX_EPOCH_START, bits_time)
    def = TsIdDefinition(
        Int128;
        name=:ULIdDefinition,
        bits_time=bits_time,
        bits_group_1=0,
        bits_tail=80,
        group_1=0,
        tail_algorithm=:machine_increment,
        epoch_start_dt=UNIX_EPOCH_START,
        epoch_end_dt=v_epoch_end_dt
    )
    return def
end
_make_timestamp_ULIdDefinition() = convert(Int128, Dates.value(Dates.now())) << 48

function tsid_generate(::Type{Val{:ULIdDefinition}}, def::TsIdDefinition)
    ts = convert(UInt128, _make_timestamp_ULIdDefinition())
    r = rand(0:convert(UInt128, 80))
    return ts | r
end

#tsid_timestamp(def::TsIdDefinition, tsid::TT) where {TT<:Integer} = tsid_timestamp(tsid, def.epoch_start_ms, def.shift_bits_time)

