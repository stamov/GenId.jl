# Insecure NanoID tests

@testset "Insecure NanoID" begin
    iddef_nano = InsecureNanoIdDefinition()
    @test iddef_nano.name == :InsecureNanoIdDefinition
    id1 = tsid_generate(iddef_nano)
    id1_str = tsid_to_string(iddef_nano, id1)
    @show id1, id1_str
    id2 = tsid_int_from_string(iddef_nano, id1_str)
    @test id2 == id1
end
