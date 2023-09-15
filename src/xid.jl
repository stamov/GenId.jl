
#const UNIX_EPOCH_START = DateTime(1970, 1, 1, 0, 0, 0, 0),

# function XIdDefinition(machine_id::Int64)
#     bits_time = 32
#     v_epoch_end_dt = epoch_end_dt_from_epoch_start(UNIX_EPOCH_START, bits_time * 8)
#     def = TsIdDefinition(
#         Int128;
#         name=:XIdDefinition,
#         bits_time=bits_time,
#         bits_group_1=24,
#         bits_group_2=16,
#         bits_tail=24,
#         group_1=machine_id,
#         tail_algorithm=:machine_increment,
#         epoch_start_dt=UNIX_EPOCH_START,
#         epoch_end_dt=v_epoch_end_dt
#     )
#     return def
# end

# function tsid_generate(::Type{Val{:XIdDefinition}}, def::TsIdDefinition)
#     #return tsid_generate(Val{:TsIdDefinition}, def)
#     div(_make_bits_timestamp(def), 1000) | _make_bits_group_1(def) | _make_bits_tail(def)
# end

