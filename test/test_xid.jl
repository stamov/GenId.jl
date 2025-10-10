# XID tests

@testset "XID" begin
    reset_globabl_machine_id_increment()
    now = Dates.now()
    iddef_xid = XIdDefinition(1)
    @test iddef_xid.name == :XIdDefinition
    id1 = tsid_generate(iddef_xid)
    #@show id1
    #@show tsid_to_string(iddef_xid, id1)
    @test tsid_getfield_value(iddef_xid, :timestamp, id1) < Dates.value(now) + 100
    @test tsid_getfield_value(iddef_xid, :machine_id, id1) == 1
    @test tsid_getfield_value(iddef_xid, :process_id, id1) == bit_mask_uint(UInt16, getpid(), 0, 15)
    @test tsid_getfield_value(iddef_xid, :machine_sequence, id1) == 1
end
