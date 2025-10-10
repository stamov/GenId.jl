using JET, Dates

include("../src/GenId.jl")
using .GenId

#report_package("GenId")
const bits_time = 41
const bits_machine = 10
const bits_tail = 12
const machine_id = 1
const SOME_EPOCH_START_2020 = DateTime(2020, 1, 1, 0, 0, 0, 0)
const SOME_EPOCH_START_VALUE_2020 = Dates.value(SOME_EPOCH_START_2020)
const SOME_EPOCH_END_2070 = DateTime(2070, 12, 31, 23, 59, 59, 999)
const SOME_EPOCH_END_VALUE_2070 = Dates.value(SOME_EPOCH_END_2070)

def1 = TsIdDefinition(Int64, bits_time, bits_machine, bits_tail, machine_id, SOME_EPOCH_START_2020, SOME_EPOCH_END_2070)
@report_opt tsid_generate(def1)
@report_call tsid_generate(def1)

