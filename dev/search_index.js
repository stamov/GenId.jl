var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = GenId","category":"page"},{"location":"#GenId","page":"Home","title":"GenId","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"API Documentation for GenId.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [GenId]","category":"page"},{"location":"#GenId.bit_mask_int-NTuple{4, Any}","page":"Home","title":"GenId.bit_mask_int","text":"bit_mask_int(type, v, from, to)\n\nApplies a 64 bit signed integer mask to a value v, with ones between bits in postitions between from and to and zeroes for other bits. \n\nCounting of bits starts at 0.\n\nv can't be a negative integer.\n\nExamples\n\njulia> bit_mask_int(Int64, typemax(Int64), 0,0)\n1\njulia> bit_mask_int(Int64, typemax(Int64), 0,1)\n3\n\n\n\n\n\n","category":"method"},{"location":"#GenId.bit_mask_uint-NTuple{4, Any}","page":"Home","title":"GenId.bit_mask_uint","text":"bit_mask_uint(type, v, from, to)\n\nMasks a 64 bit unsigned integer v with ones between bits in postitions between from and to and zeroes for other bits. \n\nCounting of bits starts at 0.\n\nExamples\n\njulia> bit_mask_uint(UInt64, typemax(UInt64), 0,0)\n0x0000000000000001\njulia> bit_mask_uint(UInt64, typemax(UInt64), 12, 21)\n0x00000000003ff000\n\n\n\n\n\n","category":"method"},{"location":"#GenId.bit_mask_uint-Tuple{Type{<:Unsigned}, Any, Any}","page":"Home","title":"GenId.bit_mask_uint","text":"bit_mask_uint(from, to)\n\nCreates a 64 bit unsigned integer mask, with ones between bits in postitions between from and to and zeroes for other bits. \n\nCounting of bits starts at 0.\n\nExamples\n\njulia> bit_mask_uint(0,0)\n0x0000000000000000000000000000000000000000000000000000000000000001\njulia> bit_mask_uint(63,63)\n0x1000000000000000000000000000000000000000000000000000000000000000\njulia> bit_mask_uint(12,21)\n0x0000000000000000000000000000000000000000001111111111000000000000\n\n\n\n\n\n","category":"method"},{"location":"#GenId.crockford32_decode_int64-Tuple{String}","page":"Home","title":"GenId.crockford32_decode_int64","text":"crockford32_decode_int64(s_input::String; skip_fn=skip_dashes_13_1, with_checksum=false)\n\nDecodes a Crockford Base 32 encoded text into an Int64.\n\nIf with_checksum is set to true, parses the last character from the text as a modulo 37 checksum.\n\nExamples\n\njulia> crockford32_decode_int64(\"Z\")\n31\n\njulia> crockford32_decode_int64(\"ZZ\"; with_checksum=true)\n31\n\njulia> crockford32_decode_int64(\"Z-Z\"; with_checksum=true)\n31\n\n\n\n\n\n","category":"method"},{"location":"#GenId.crockford32_decode_uint64-Tuple{String}","page":"Home","title":"GenId.crockford32_decode_uint64","text":"crockford32_decode_uint64(s_input::String; skip_fn=skip_dashes_13_1, with_checksum=false)\n\nDecodes a Crockford Base 32 encoded text into an UInt64.\n\nIf with_checksum is set to true, parses the last character from the text as a modulo 37 checksum.\n\nExamples\n\njulia> crockford32_decode_uint64(\"Z\")\n0x000000000000001f\n\njulia> crockford32_decode_uint64(\"ZZ\"; with_checksum=true)\n0x000000000000001f\n\njulia> crockford32_decode_uint64(\"Z-Z\"; with_checksum=true)\n0x000000000000001f\n\n\n\n\n\n","category":"method"},{"location":"#GenId.crockford32_encode_int64-Tuple{Int64}","page":"Home","title":"GenId.crockford32_encode_int64","text":"crockford32_encode_int64(n::UInt64; started_init::Bool=false, with_checksum::Bool=false)\n\nEncodes an Int64 n using Crockford Base 32.\n\nIf with_checksum is set to true, adds a modulo 37 checksum character at the end.\n\nIf started_init is set to true, pads the string to the left to 13(14 when a checksum is generated) characters.\n\nExamples\n\njulia> crockford32_encode_int64(31)\n\"Z\"\n\njulia> crockford32_encode_int64(31; with_checksum=true)\n\"ZZ\"\n\njulia> crockford32_encode_int64(31; with_checksum=true, started_init=true)\n\"000000000000ZZ\"\n\n\n\n\n\n","category":"method"},{"location":"#GenId.crockford32_encode_uint64-Tuple{UInt64}","page":"Home","title":"GenId.crockford32_encode_uint64","text":"crockford32_encode_uint64(n::UInt64; started_init::Bool=false, with_checksum::Bool=false)\n\nEncodes an UInt64 n using Crockford Base 32.\n\nIf with_checksum is set to true, adds a modulo 37 checksum character at the end.\n\nIf started_init is set to true, pads the string to the left to 13(14 when a checksum is generated) characters.\n\nExamples\n\njulia> crockford32_encode_uint64(0x000000000000001f)\n\"Z\"\n\njulia> crockford32_encode_uint64(0x000000000000001f; with_checksum=true)\n\"ZZ\"\n\njulia> crockford32_encode_uint64(0x000000000000001f; with_checksum=true, started_init=true)\n\"000000000000ZZ\"\n\n\n\n\n\n","category":"method"},{"location":"#GenId.tsid_from_string-Tuple{String}","page":"Home","title":"GenId.tsid_from_string","text":"tsid_from_string(s::AbstractString)\n\nCreates a new UUID from a textual representation in s.\n\nExamples\n\njulia> tsid_from_string(\"DJR0RGDG0401\")\n489485826766409729\n\n\n\n\n\n","category":"method"},{"location":"#GenId.tsid_generate-Tuple{TsIdDefinition}","page":"Home","title":"GenId.tsid_generate","text":"tsid_generate(def)\n\nCreates a new UUID based on def.\n\nExamples\n\njulia> iddef = TsIdDefinition(\n    # Data type used for storage of the ID\n    Int64; \n    # Number of bits used for the timestamp section.\n    bits_time=41, \n    # Number of bits used for the machine section.\n    bits_machine=10, \n    # Number of bits for the tail section.\n    # Can be a random number or a local machine/thread specific sequence.\n    bits_tail=12, \n    machine_id=1, \n    # Start of the epoch for this UUID scheme.\n    # Time before that can't be represented.\n    epoch_start_dt=DateTime(2020, 1, 1, 0, 0, 0, 0), \n    # Start of the epoch for this UUID scheme.\n    # Time after that can't be represented.\n    epoch_end_dt=DateTime(2070, 12, 31, 23, 59, 59, 999)\n)\nTsIdDefinition(Int64, 41, 10, 12, 1, 4096, 22, 12, Dates.DateTime(\"2020-01-01T00:00:00\"), Dates.DateTime(\"2070-12-31T23:59:59.999\"), 63713520000000, 65322979199999)\n\njulia> tsid_generate(iddef)\n489485826766409729\n\n\n\n\n\n","category":"method"},{"location":"#GenId.tsid_machine_id-Union{Tuple{TT}, Tuple{TsIdDefinition, TT}} where TT<:Integer","page":"Home","title":"GenId.tsid_machine_id","text":"tsid_machine_id(def::TsIdDefinition, tsid::TT) where {TT<:Integer}\n\nExtracts the machine id from an existing tsid.\n\nExamples\n\njulia> tsid_machine_id(iddef, 489485826766409729)\n1\n\n\n\n\n\n","category":"method"},{"location":"#GenId.tsid_machine_tail-Union{Tuple{TT}, Tuple{TsIdDefinition, TT}} where TT<:Integer","page":"Home","title":"GenId.tsid_machine_tail","text":"tsid_machine_tail(def::TsIdDefinition, tsid::TT) where {TT<:Integer}\n\nExtracts the tail (an increment or a random number) from an existing tsid.\n\nExamples\n\njulia> tsid_machine_tail(iddef, 489485826766409729)\n1\n\n\n\n\n\n","category":"method"},{"location":"#GenId.tsid_timestamp-Union{Tuple{TT}, Tuple{TsIdDefinition, TT}} where TT<:Integer","page":"Home","title":"GenId.tsid_timestamp","text":"tsid_timestamp(def::TsIdDefinition, tsid::TT) where {TT<:Integer}\n\nExtracts the timestamp from an existing tsid.\n\nExamples\n\njulia> tsid_timestamp(iddef, 489485826766409729)\n2023-09-12T17:21:55.308\n\n\n\n\n\n","category":"method"}]
}
