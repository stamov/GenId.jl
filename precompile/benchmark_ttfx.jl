#!/usr/bin/env julia
"""
Time To First X (TTFX) Benchmark for GenId

Measures startup time and first-call compilation overhead.
Run this in a fresh Julia session for accurate results:

    julia --project=. precompile/benchmark_ttfx.jl

Results are saved to precompile/benchmark_results.txt
"""

println("=" ^ 70)
println("GenId TTFX Benchmark")
println("=" ^ 70)
println()

# Measure module loading time
println("⏱️  Measuring 'using GenId' time...")
t_load = @elapsed begin
    using GenId
    using Dates
end
println("   ✓ Module load time: $(round(t_load, digits=3))s")
println()

# Helper to run and time a block
macro time_operation(desc, expr)
    quote
        print("⏱️  ", $(esc(desc)), "... ")
        t = @elapsed $(esc(expr))
        println("$(round(t * 1000, digits=2))ms")
        t
    end
end

# Test Snowflake (Int64-based)
println("📊 Testing SnowflakeId (Int64):")
t_sf_def = @time_operation "   Create definition" begin
    sf_def = SnowflakeIdDefinition(DateTime(2020, 1, 1), Int64(1))
end

t_sf_gen = @time_operation "   Generate ID" begin
    sf_id = tsid_generate(sf_def)
end

t_sf_str = @time_operation "   Convert to string" begin
    sf_str = tsid_to_string(sf_def, sf_id)
end

t_sf_parse = @time_operation "   Parse from string" begin
    tsid_int_from_string(sf_def, sf_str)
end

t_sf_field = @time_operation "   Extract field value" begin
    tsid_getfield_value(sf_def, :timestamp, sf_id)
end
println()

# Test ULID (Int128-based)
println("📊 Testing ULID (Int128):")
t_ulid_def = @time_operation "   Create definition" begin
    ulid_def = ULIdDefinition()
end

t_ulid_gen = @time_operation "   Generate ID" begin
    ulid_id = tsid_generate(ulid_def)
end

t_ulid_str = @time_operation "   Convert to string" begin
    ulid_str = tsid_to_string(ulid_def, ulid_id)
end

t_ulid_parse = @time_operation "   Parse from string" begin
    tsid_int_from_string(ulid_def, ulid_str)
end

t_ulid_field = @time_operation "   Extract field value" begin
    tsid_getfield_value(ulid_def, :timestamp, ulid_id)
end
println()

# Test UUIDv7 (Int128-based, RFC 9562)
println("📊 Testing UUIDv7 Monotonic (RFC 9562 - Recommended):")
t_uuid_def = @time_operation "   Create definition" begin
    uuid_def = UUIDv7MonotonicDefinition()
end

t_uuid_gen = @time_operation "   Generate ID" begin
    uuid_id = tsid_generate(uuid_def)
end

t_uuid_str = @time_operation "   Convert to string" begin
    uuid_str = tsid_to_string(uuid_def, uuid_id)
end

t_uuid_parse = @time_operation "   Parse from string" begin
    tsid_int_from_string(uuid_def, uuid_str)
end
println()

# Calculate totals
total_time = t_load + t_sf_def + t_sf_gen + t_sf_str + t_sf_parse + t_sf_field +
             t_ulid_def + t_ulid_gen + t_ulid_str + t_ulid_parse + t_ulid_field +
             t_uuid_def + t_uuid_gen + t_uuid_str + t_uuid_parse

println("=" ^ 70)
println("📈 SUMMARY:")
println("   Module load time:        $(round(t_load, digits=3))s")
println("   Total operations time:   $(round((total_time - t_load) * 1000, digits=2))ms")
println("   TOTAL TIME (TTFX):       $(round(total_time, digits=3))s")
println("=" ^ 70)
println()

# Save results to file
results_file = joinpath(@__DIR__, "benchmark_results.txt")
open(results_file, "w") do io
    println(io, "GenId TTFX Benchmark Results")
    println(io, "Date: ", Dates.now())
    println(io, "Julia Version: ", VERSION)
    println(io, "=" ^ 70)
    println(io)
    println(io, "Module load time:        $(round(t_load, digits=3))s")
    println(io, "Snowflake operations:    $(round((t_sf_def + t_sf_gen + t_sf_str + t_sf_parse + t_sf_field) * 1000, digits=2))ms")
    println(io, "ULID operations:         $(round((t_ulid_def + t_ulid_gen + t_ulid_str + t_ulid_parse + t_ulid_field) * 1000, digits=2))ms")
    println(io, "UUIDv7 operations:       $(round((t_uuid_def + t_uuid_gen + t_uuid_str + t_uuid_parse) * 1000, digits=2))ms")
    println(io, "TOTAL TIME (TTFX):       $(round(total_time, digits=3))s")
end

println("✅ Results saved to: $results_file")
