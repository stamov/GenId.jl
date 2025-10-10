module GenIdTest

using Dates
using Test
using Aqua

using GenId

@testset "GenId" begin

    # Common test setup and quality checks
    include("test_common.jl")

    # Text encoder/decoder tests
    include("test_encoders.jl")

    # Bit manipulation and field tests
    include("test_bitmasks.jl")

    # UUID implementation tests (each in separate file)
    include("test_snowflake.jl")
    include("test_instagram.jl")
    include("test_ulid.jl")
    include("test_xid.jl")
    include("test_firebase.jl")
    include("test_nanoid.jl")

    # TSID string encoding/decoding tests
    include("test_tsid_string.jl")

    # Bit layout integrity and field overlap tests
    include("test_integrity.jl")

    # UUIDv7 comprehensive tests
    include("test_uuidv7.jl")

    # Cryptographic random field and secure UUIDv7 tests
    include("test_crypto_random.jl")

end

end
