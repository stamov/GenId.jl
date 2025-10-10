# Firebase Push ID tests

@testset "Firebase PushID" begin
    iddef_firebase_push_id = FIREBASE_PUSHID_DEFINITION
    now = Dates.now()
    id1 = tsid_generate(iddef_firebase_push_id)
    @test tsid_getfield_value(iddef_firebase_push_id, :timestamp, id1) < Dates.value(now) + 100
    @test typeof(id1) == iddef_firebase_push_id.type
    id_int_1 = 301430602692632926610578560781911544
    #id_int_1_str = GenId.base32encode_int128(id_int_1; started_init=true)
    id_int_1_str = GenId.base_dictionary_encode_int128(id_int_1, iddef_firebase_push_id.text_coder)
    @test id_int_1_str == "DVqh4j54DWG1F0Pda-Ms"
    @test length(id_int_1_str) == 20
    id_int_2 = GenId.base_dictionary_decode_int128("DVqh4j54DWG1F0Pda-Ms", iddef_firebase_push_id.text_coder)
    @test id_int_1 == id_int_2

    @test tsid_to_string(iddef_firebase_push_id, id_int_1) == "DVqh4j54DWG1F0Pda-Ms"
    @test tsid_int_from_string(iddef_firebase_push_id, "DVqh4j54DWG1F0Pda-Ms") == id_int_1
end
