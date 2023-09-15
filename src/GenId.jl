module GenId

using ArgCheck
using Dates

const UNIX_EPOCH_START = DateTime(1970, 1, 1, 0, 0, 0, 0)

include("base64.jl")
include("base32.jl")
include("base32_crockford.jl")
include("bitmasks.jl")
include("tsid.jl")
include("snowflakeid.jl")
include("instagramid.jl")
include("firebasepushid.jl")
include("ulid.jl")
include("xid.jl")

#@__MODULE__
#println("in file eval:", @__MODULE__)

export bit_mask_uint, bit_mask_int

export crockford32_encode_uint64, crockford32_encode_int64, crockford32_decode_int64, crockford32_decode_uint64
export crockford32_encode_int128, crockford32_decode_uint128, crockford32_decode_int128

export AbstractField, AbstractGeneratedField, ConstantField, GeneratedField, RandomField, TimestampField, extract_value_from_bits, implant_value_into_int

export FIREBASE_PUSHID_DEFINITION, ULID_DEFINITION

export TSID, TsIdDefinition
export reset_globabl_machine_id_increment
export def_bits_time, def_bits_group_1, def_bits_group_2, def_bits_tail, def_group_1, def_group_2
export tsid_generate
export tsid_timestamp, tsid_group_1, tsid_group_2, tsid_tail
export tsid_to_string, tsid_int_from_string

#export FirebasePushIdDefinition, InstagramIdDefinition, SnowflakeIdDefinition, ULIdDefinition #, XIdDefinition
export FirebasePushIdDefinition, InstagramIdDefinition, SnowflakeIdDefinition, ULIdDefinition


# using Base64
# base64encode(convert(Int128, 1))
# base64decode("AQAAAAAAAAAAAAAAAAAAAA==")

end
