using GenId
using Test
using Aqua

@testset "GenId.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(GenId)
    end
    # Write your tests here.
end
