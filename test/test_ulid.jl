# ULID tests

@testset "ULID" begin
    iddef_ulid = ULID_DEFINITION # ULIdDefinition()
    @test iddef_ulid.name == :ULIdDefinition
    now = Dates.now()
    id1 = tsid_generate(iddef_ulid)
    @test tsid_getfield_value(iddef_ulid, :timestamp, id1) < Dates.value(now) + 100
end
