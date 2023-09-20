var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = GenId","category":"page"},{"location":"#GenId","page":"Home","title":"GenId","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"API Documentation for GenId.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [GenId]","category":"page"},{"location":"#GenId.bit_mask_int-NTuple{4, Any}","page":"Home","title":"GenId.bit_mask_int","text":"bit_mask_int(type, v, from, to)\n\nApplies a 64 bit signed integer mask to a value v, with ones between bits in postitions between from and to and zeroes for other bits. \n\nCounting of bits starts at 0.\n\nv can't be a negative integer.\n\nExamples\n\njulia> bit_mask_int(Int64, typemax(Int64), 0,0)\n1\njulia> bit_mask_int(Int64, typemax(Int64), 0,1)\n3\n\n\n\n\n\n","category":"method"},{"location":"#GenId.bit_mask_uint-NTuple{4, Any}","page":"Home","title":"GenId.bit_mask_uint","text":"bit_mask_uint(type, v, from, to)\n\nMasks a 64 bit unsigned integer v with ones between bits in postitions between from and to and zeroes for other bits. \n\nCounting of bits starts at 0.\n\nExamples\n\njulia> bit_mask_uint(UInt64, typemax(UInt64), 0,0)\n0x0000000000000001\njulia> bit_mask_uint(UInt64, typemax(UInt64), 12, 21)\n0x00000000003ff000\n\n\n\n\n\n","category":"method"},{"location":"#GenId.bit_mask_uint-Tuple{Type{<:Unsigned}, Any, Any}","page":"Home","title":"GenId.bit_mask_uint","text":"bit_mask_uint(from, to)\n\nCreates a 64 bit unsigned integer mask, with ones between bits in postitions between from and to and zeroes for other bits. \n\nCounting of bits starts at 0.\n\nExamples\n\njulia> bit_mask_uint(0,0)\n0x0000000000000000000000000000000000000000000000000000000000000001\njulia> bit_mask_uint(63,63)\n0x1000000000000000000000000000000000000000000000000000000000000000\njulia> bit_mask_uint(12,21)\n0x0000000000000000000000000000000000000000001111111111000000000000\n\n\n\n\n\n","category":"method"},{"location":"#GenId.crockford32_decode_int64-Tuple{String}","page":"Home","title":"GenId.crockford32_decode_int64","text":"crockford32_decode_int64(s_input::String; skip_fn=skip_dashes_13_1, with_checksum=false)\n\nDecodes a Crockford Base 32 encoded text into an Int64.\n\nIf with_checksum is set to true, parses the last character from the text as a modulo 37 checksum.\n\nExamples\n\njulia> crockford32_decode_int64(\"Z\")\n31\n\njulia> crockford32_decode_int64(\"ZZ\"; with_checksum=true)\n31\n\njulia> crockford32_decode_int64(\"Z-Z\"; with_checksum=true)\n31\n\n\n\n\n\n","category":"method"},{"location":"#GenId.crockford32_decode_uint64-Tuple{String}","page":"Home","title":"GenId.crockford32_decode_uint64","text":"crockford32_decode_uint64(s_input::String; skip_fn=skip_dashes_13_1, with_checksum=false)\n\nDecodes a Crockford Base 32 encoded text into an UInt64.\n\nIf with_checksum is set to true, parses the last character from the text as a modulo 37 checksum.\n\nExamples\n\njulia> crockford32_decode_uint64(\"Z\")\n0x000000000000001f\n\njulia> crockford32_decode_uint64(\"ZZ\"; with_checksum=true)\n0x000000000000001f\n\njulia> crockford32_decode_uint64(\"Z-Z\"; with_checksum=true)\n0x000000000000001f\n\n\n\n\n\n","category":"method"},{"location":"#GenId.crockford32_encode_int64-Tuple{Int64}","page":"Home","title":"GenId.crockford32_encode_int64","text":"crockford32_encode_int64(n::UInt64; started_init::Bool=false, with_checksum::Bool=false)\n\nEncodes an Int64 n using Crockford Base 32.\n\nIf with_checksum is set to true, adds a modulo 37 checksum character at the end.\n\nIf started_init is set to true, pads the string to the left to 13(14 when a checksum is generated) characters.\n\nExamples\n\njulia> crockford32_encode_int64(31)\n\"Z\"\n\njulia> crockford32_encode_int64(31; with_checksum=true)\n\"ZZ\"\n\njulia> crockford32_encode_int64(31; with_checksum=true, started_init=true)\n\"000000000000ZZ\"\n\n\n\n\n\n","category":"method"},{"location":"#GenId.crockford32_encode_uint64-Tuple{UInt64}","page":"Home","title":"GenId.crockford32_encode_uint64","text":"crockford32_encode_uint64(n::UInt64; started_init::Bool=false, with_checksum::Bool=false)\n\nEncodes an UInt64 n using Crockford Base 32.\n\nIf with_checksum is set to true, adds a modulo 37 checksum character at the end.\n\nIf started_init is set to true, pads the string to the left to 13(14 when a checksum is generated) characters.\n\nExamples\n\njulia> crockford32_encode_uint64(0x000000000000001f)\n\"Z\"\n\njulia> crockford32_encode_uint64(0x000000000000001f; with_checksum=true)\n\"ZZ\"\n\njulia> crockford32_encode_uint64(0x000000000000001f; with_checksum=true, started_init=true)\n\"000000000000ZZ\"\n\n\n\n\n\n","category":"method"},{"location":"#GenId.tsid_int_from_string-Tuple{TSIDGenericContainer, String}","page":"Home","title":"GenId.tsid_int_from_string","text":"tsid_int_from_string(def::TsIdDefinition, s::AbstractString)\n\nCreates a new UUID from a textual representation in s based on text_* flags in def`.\n\nExamples\n\njulia> tsid_from_string(iddef, \"DJR0RGDG0401\")\n489485826766409729\n\n\n\n\n\n","category":"method"},{"location":"#GenId.tsid_to_string-Union{Tuple{T}, Tuple{TSIDGenericContainer, T}} where T<:Integer","page":"Home","title":"GenId.tsid_to_string","text":"tsid_to_string(def::TsIdDefinition, tsid::T) where T <: Integer\n\nCreates a new UUID from a textual representation in s based on text_* flags in def`.\n\nExamples\n\njulia> tsid_to_string(iddef, 489485826766409729)\n\"DJR0RGDG0401\"\n\n\n\n\n\n","category":"method"}]
}
