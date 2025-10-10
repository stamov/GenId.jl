# Bit manipulation and field tests

@testset "GenId.bit_mask" begin
    @test GenId.word_size(Int16) == GenId.word_size(UInt16) == 16
    @test GenId.word_size(Int32) == GenId.word_size(UInt32) == 32
    @test GenId.word_size(Int64) == GenId.word_size(UInt64) == 64
    @test GenId.word_size(Int128) == GenId.word_size(UInt128) == 128
    @test GenId.mask1(UInt128) == convert(UInt128, 1)
    @test GenId.unsigned_int_for_signed(Int16) == UInt16
    @test GenId.unsigned_int_for_signed(Int32) == UInt32
    @test GenId.unsigned_int_for_signed(Int64) == UInt64
    @test GenId.unsigned_int_for_signed(Int128) == UInt128
    @test bitstring(bit_mask_uint(UInt64, 0, 0)) == "0000000000000000000000000000000000000000000000000000000000000001"
    @test bitstring(bit_mask_uint(UInt64, 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
    @test bitstring(bit_mask_uint(UInt64, 63, 63)) == "1000000000000000000000000000000000000000000000000000000000000000"
    @test bitstring(bit_mask_uint(UInt64, typemax(UInt64), 0, 0)) == "0000000000000000000000000000000000000000000000000000000000000001"
    @test bitstring(bit_mask_uint(UInt64, typemax(UInt64), 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
    @test bitstring(bit_mask_int(Int64, typemax(Int64), 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
    @test_throws AssertionError bitstring(GenId.bit_mask_int(Int64, -1, 12, 21)) == "0000000000000000000000000000000000000000001111111111000000000000"
end

@testset "MachineSequenceField" begin
    GenId.reset_globabl_machine_id_increment(4093)
    f = GenId.MachineSequenceField(Int64, 0, 12)
    @test GenId.generate_field_value(f) == 4094
    @test GenId.generate_field_value(f) == 4095
    @test GenId.generate_field_value(f) == 0
    @test GenId.generate_field_value(f) == 1

    GenId.reset_globabl_machine_id_increment()
    @test GenId.generate_field_value(f) == 1
    @test GenId.generate_field_value(f) == 2
end

@testset "GenId.GeneratedField" begin
    f1 = GeneratedField(Int64, :hello, 1, 2)

    @test typeof(extract_value_from_bits(f1, Int64, 0)) == Int64
    #@show bitstring(0)
    @test extract_value_from_bits(f1, Int64, 0) == 0
    #@show bitstring(1)
    @test extract_value_from_bits(f1, Int64, 1) == 0
    #@show bitstring(2)
    @test extract_value_from_bits(f1, Int64, 2) == 1
    #@show bitstring(3)
    @test extract_value_from_bits(f1, Int64, 3) == 1
    #@show bitstring(4)
    @test extract_value_from_bits(f1, Int64, 4) == 2
    #@show bitstring(5)
    @test extract_value_from_bits(f1, Int64, 5) == 2
    #@show bitstring(6)
    @test extract_value_from_bits(f1, Int64, 6) == 3
    #@show bitstring(7)
    @test extract_value_from_bits(f1, Int64, 7) == 3
    #@show bitstring(8)
    @test extract_value_from_bits(f1, Int64, 8) == 0

    @test typeof(extract_value_from_bits(f1, Int64, 0x0)) == Int64
    @test typeof(extract_value_from_bits(f1, UInt64, 0x0)) == Int64 # see f1 definition
    #@show bitstring(0)
    @test extract_value_from_bits(f1, UInt64, 0x0) == 0
    #@show bitstring(1)
    @test extract_value_from_bits(f1, UInt64, 0x1) == 0
    #@show bitstring(2)
    @test extract_value_from_bits(f1, UInt64, 0x2) == 1
    #@show bitstring(3)
    @test extract_value_from_bits(f1, UInt64, 0x3) == 1
    #@show bitstring(4)
    @test extract_value_from_bits(f1, UInt64, 0x4) == 2
    #@show bitstring(5)
    @test extract_value_from_bits(f1, UInt64, 0x5) == 2
    #@show bitstring(6)
    @test extract_value_from_bits(f1, UInt64, 0x6) == 3
    #@show bitstring(7)
    @test extract_value_from_bits(f1, UInt64, 0x7) == 3
    #@show bitstring(8)
    @test extract_value_from_bits(f1, UInt64, 0x8) == 0

    f2 = GeneratedField(UInt64, :hello, 1, 2)
    @test typeof(extract_value_from_bits(f2, UInt64, 0)) == UInt64
    @test typeof(extract_value_from_bits(f2, Int64, 0)) == UInt64

    f3 = GeneratedField(UInt128, :hello, 1, 2)
    @test typeof(extract_value_from_bits(f3, UInt128, 0)) == UInt128
    @test typeof(extract_value_from_bits(f3, UInt128, convert(Int128, 0))) == UInt128
    @test typeof(extract_value_from_bits(f3, UInt128, convert(UInt128, 0))) == UInt128

    # #@show bitstring(0)
    @test implant_value_into_int(0, f1, 0) == 0
    # #@show bitstring(1)
    @test implant_value_into_int(0, f1, 1) == 2
    # #@show bitstring(2)
    @test implant_value_into_int(0, f1, 2) == 4
    # #@show bitstring(3)
    @test implant_value_into_int(0, f1, 3) == 6
    # # implant_value_into_int can overwrite if new_value has more than GeneratedField.bit_length bits
    # #@show bitstring(4)
    @test implant_value_into_int(0, f1, 4) == 8
end
