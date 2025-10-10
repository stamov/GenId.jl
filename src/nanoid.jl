
const ALPHABET = "useandom-26T198340PX75pxJACKVERYMINDBUSHWOLF_GQZbfghjklqvwyzrict"

struct SimpleNanoIdContainer <: TSIDAbstractContainer end

const SIMPLE_NANO_ID_CONTAINER = SimpleNanoIdContainer()

function tsid_generate_string(def::SimpleNanoIdContainer)
    buf = Char[]
    for i in 1:21.
        push!(buf, ALPHABET[rand(1:64)])
    end
    join(buf)
end



const NANO_ID_FIELD_RANDOM = RandomField(Int128, 0, 122)

function InsecureNanoIdDefinition()
    TSIDGenericContainer(
        Int128,
        :InsecureNanoIdDefinition,
        [
            NANO_ID_FIELD_RANDOM
        ],
        make_basic_coder(;
            algorithm=:base_64,
            bits_per_character=6,
            dictionary="useandom-26T198340PX75pxJACKVERYMINDBUSHWOLF_GQZbfghjklqvwyzrict",
            pad_char='0',
            use_full_with=true,
            max_string_length=21
        )
    )
end

const INSECURE_NANO_ID_DEFINITION = InsecureNanoIdDefinition()
