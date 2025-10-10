module GenId

using ArgCheck
using Dates
using Random: RandomDevice

const UNIX_EPOCH_START = DateTime(1970, 1, 1, 0, 0, 0, 0)

include("text_coders.jl")
#include("base64.jl")
#include("base32.jl")
#include("base32hex.jl")
include("base32_crockford.jl")
include("bitmasks.jl")
include("tsid.jl")
include("snowflakeid.jl")
include("instagramid.jl")
include("firebasepushid.jl")
include("ulid.jl")
include("xid.jl")
include("nanoid.jl")
include("uuidv7.jl")
include("uuidv7_secure.jl")

#@__MODULE__
#println("in file eval:", @__MODULE__)

export bit_mask_uint, bit_mask_int

export crockford32_encode_uint64, crockford32_encode_int64, crockford32_decode_int64, crockford32_decode_uint64
export crockford32_encode_int128, crockford32_decode_uint128, crockford32_decode_int128
export make_basic_coder, make_crockford_base_32_coder
export AbstractField, AbstractGeneratedField, ConstantField, CryptographicRandomField, GeneratedField, MachineSequenceField, ProcessIdField, RandomField, TimestampField
export extract_value_from_bits, implant_value_into_int, generate_field_value

export FIREBASE_PUSHID_DEFINITION, ULID_DEFINITION
export UUIDV7_SIMPLE_DEFINITION, UUIDV7_MONOTONIC_DEFINITION, UUIDV7_SUBMILLISECOND_DEFINITION
export UUIDV7_SECURE_SIMPLE_DEFINITION, UUIDV7_SECURE_MONOTONIC_DEFINITION, UUIDV7_SECURE_SUBMILLISECOND_DEFINITION

#export TSID, TsIdDefinition
export TSIDGenericContainer
export reset_globabl_machine_id_increment
export reset_uuidv7_monotonic_counter, reset_uuidv7_distributed_counter
#export def_bits_time, def_bits_group_1, def_bits_group_2, def_bits_tail, def_group_1, def_group_2
export tsid_generate, tsid_generate_string
#export tsid_timestamp, tsid_group_1, tsid_group_2, tsid_tail
export tsid_to_string, tsid_int_from_string

export FirebasePushIdDefinition, InsecureNanoIdDefinition, InstagramIdDefinition, SnowflakeIdDefinition, ULIdDefinition, XIdDefinition
export UUIDv7SimpleDefinition, UUIDv7MonotonicDefinition, UUIDv7SubMillisecondDefinition, UUIDv7DistributedDefinition
export UUIDv7SecureSimpleDefinition, UUIDv7SecureMonotonicDefinition, UUIDv7SecureSubMillisecondDefinition, UUIDv7SecureDistributedDefinition
export tsid_getfield_value



# dt1 = DateTime(now())
# ms1 = Dates.value(dt1)
# @show bitstring(ms1)
# ums1 = ms1 - Dates.value(UNIX_EPOCH_START)
# @show bitstring(ums1)
# udt = DateTime(Dates.UTM(ums1 + Dates.value(UNIX_EPOCH_START)))


# ums1_masked = bit_mask_int(Int64, div(ums1, 1000)*1000, 0, 63)
# bitstring(ums1_masked)
# ut1_masked = DateTime(Dates.UTM(ums1_masked + Dates.value(UNIX_EPOCH_START)))



# ues_dt = DateTime(1970, 1, 1, 0, 0, 59, 0)
# ues_ms = Dates.value(ues_dt)
# bitstring(ues_ms)
# ues_dt_ms1 = Dates.value(DateTime(1970, 1, 1, 0, 0, 58, 1))
# bitstring(ues_dt_ms1)
# ues_dt_ms999 = Dates.value(DateTime(1970, 1, 1, 0, 0, 58, 999))
# bitstring(ues_dt_ms999)
# ues_dt_ms999d1000m1000 = div(Dates.value(DateTime(1970, 1, 1, 0, 0, 58, 999)), 1000)*1000
# bitstring(ues_dt_ms999d1000m1000)
# ut1_masked = DateTime(Dates.UTM(ues_dt_ms999d1000m1000))
# 0000000000000000001110001000001100010111010101000001101001110111
# 0000000000000000001110001000001100010111010101000001011010010000

# x1 = Dates.value(DateTime(1991, 1, 1, 0, 0, 59, 999))
# bitstring(x1)
# x11 = div(Dates.value(DateTime(1971, 1, 1, 0, 0, 59, 999)), 1000) * 1000
# bitstring(x11)
# x111 = DateTime(Dates.UTM(x11))

end
