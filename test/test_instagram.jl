# Instagram ID tests

@testset "Instagram ID" begin
    iddef_instagram = InstagramIdDefinition(SOME_EPOCH_START_2020, 1)
    @test iddef_instagram.name == :InstagramIdDefinition
    reset_globabl_machine_id_increment()
    now = Dates.now()
    id1 = tsid_generate(iddef_instagram)
    @test tsid_getfield_value(iddef_instagram, :timestamp, id1) < Dates.value(now) + 100
    @test tsid_getfield_value(iddef_instagram, :shard_id, id1) == 1
    @test tsid_getfield_value(iddef_instagram, :machine_sequence, id1) == 1
end
