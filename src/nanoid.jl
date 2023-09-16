
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
        ];
        text_algorithm=:base_64,
        text_full_width=true,
        text_max_length=21
    )
end

const INSECURE_NANO_ID_DEFINITION = InsecureNanoIdDefinition()
