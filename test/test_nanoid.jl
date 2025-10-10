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

@testset "Simple NanoID String Generation" begin
    # Test basic string generation
    id_str = tsid_generate_string(GenId.SIMPLE_NANO_ID_CONTAINER)

    # Verify string length is exactly 21 characters
    @test length(id_str) == 21

    # Verify all characters are from the ALPHABET
    alphabet_chars = Set(GenId.ALPHABET)
    for char in id_str
        @test char in alphabet_chars
    end

    # Test multiple generations produce different results (randomness check)
    id_str2 = tsid_generate_string(GenId.SIMPLE_NANO_ID_CONTAINER)
    id_str3 = tsid_generate_string(GenId.SIMPLE_NANO_ID_CONTAINER)

    # All three should be 21 characters
    @test length(id_str2) == 21
    @test length(id_str3) == 21

    # With high probability, at least two should be different
    # (probability of collision is extremely low: 1/64^21)
    @test (id_str != id_str2) || (id_str != id_str3) || (id_str2 != id_str3)

    # Test character distribution over multiple samples
    # Generate 100 IDs and verify we see different characters
    unique_chars = Set{Char}()
    for i in 1:100
        test_id = tsid_generate_string(GenId.SIMPLE_NANO_ID_CONTAINER)
        @test length(test_id) == 21
        for char in test_id
            push!(unique_chars, char)
        end
    end

    # With 100 IDs × 21 chars = 2100 samples from 64-char alphabet,
    # we should see a significant portion of the alphabet
    @test length(unique_chars) > 30  # At least half the alphabet should appear
end
