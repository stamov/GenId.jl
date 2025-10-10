# =============================================================================
# Secure UUIDv7 Configurations (Cryptographically Secure Random)
# =============================================================================
#
# These configurations use CryptographicRandomField instead of RandomField
# for RFC 9562 Section 6.9 compliance: "SHOULD use CSPRNG"
#
# Trade-off: ~2-5x slower than standard configs, but cryptographically secure
# Use cases: Security tokens, session IDs, authentication, security-critical systems

"""
    UUIDv7SecureSimpleDefinition()

Cryptographically secure version of UUIDv7SimpleDefinition() using `RandomDevice()`.

**Identical to UUIDv7SimpleDefinition except:**
- Uses `CryptographicRandomField` for all 74 random bits
- Cryptographically unpredictable random values from `/dev/urandom` (Unix) or `CryptGenRandom` (Windows)
- Suitable for security-sensitive applications
- ~2-3x slower than standard simple configuration

**When to use this instead of `UUIDv7SimpleDefinition()`:**
- ✅ UUIDs used as security tokens or session identifiers
- ✅ Authentication systems requiring unpredictable IDs
- ✅ Compliance with strict security standards (HIPAA, PCI-DSS, etc.)
- ✅ Applications where security > performance
- ❌ High-throughput database primary keys (use monotonic instead)
- ❌ Non-security-critical distributed IDs

**RFC 9562 Compliance:** Fully compliant with Section 6.9 CSPRNG recommendation.

# Examples
```julia-repl
julia> defn = UUIDv7SecureSimpleDefinition()
julia> id = tsid_generate(defn)  # Cryptographically secure
julia> uuid_str = tsid_to_string(defn, id)
"0192e209ae3f7c8b8f714d9e2b1a0c3f"
```
"""
function UUIDv7SecureSimpleDefinition()
    TSIDGenericContainer(
        Int128,
        :UUIDv7SecureSimple,
        [
            TimestampField(Int128, 80, 48, UNIX_EPOCH_START),
            ConstantField(Int128, :version, 76, 4, 7),
            CryptographicRandomField(UInt128, 64, 12),  # Secure 12-bit random
            ConstantField(Int128, :variant, 62, 2, 2),
            CryptographicRandomField(UInt128, 0, 62)    # Secure 62-bit random
        ],
        make_basic_coder(
            algorithm=:base_16,
            bits_per_character=4,
            dictionary="0123456789abcdef",
            pad_char='0',
            use_full_with=true
        )
    )
end

const UUIDV7_SECURE_SIMPLE_DEFINITION = UUIDv7SecureSimpleDefinition()

"""
    UUIDv7SecureMonotonicDefinition()

Cryptographically secure version of UUIDv7MonotonicDefinition() with secure random bits.

**Identical to UUIDv7MonotonicDefinition except:**
- Uses `CryptographicRandomField` for 62 random bits
- Counter initialization still uses fast `rand()` (counter behavior, not security-critical)
- Main random payload is cryptographically secure
- ~1.5-2x slower than standard monotonic configuration

**When to use this instead of `UUIDv7MonotonicDefinition()`:**
- ✅ Database primary keys for security-sensitive tables (user auth, payments)
- ✅ Event logging where UUIDs must be unpredictable
- ✅ Systems requiring both ordering AND security
- ❌ High-frequency event streams (>100K IDs/second)
- ❌ Non-sensitive database records

**Security Note:** Counter values are sequential and predictable (by design for monotonicity).
Only the 62-bit random payload is cryptographically secure. If counter values must also
be unpredictable, use `UUIDv7SecureSimpleDefinition()` instead.

**RFC 9562 Compliance:** Fully compliant with Section 6.9 CSPRNG recommendation for random bits.

# Examples
```julia-repl
julia> defn = UUIDv7SecureMonotonicDefinition()
julia> id1 = tsid_generate(defn)
julia> id2 = tsid_generate(defn)
julia> id1 < id2  # Still monotonic
true
```
"""
function UUIDv7SecureMonotonicDefinition()
    TSIDGenericContainer(
        Int128,
        :UUIDv7SecureMonotonic,
        [
            TimestampField(Int128, 80, 48, UNIX_EPOCH_START),
            ConstantField(Int128, :version, 76, 4, 7),
            UUIDv7MonotonicCounterField(Int128, 64, 12),      # Counter (predictable by design)
            ConstantField(Int128, :variant, 62, 2, 2),
            CryptographicRandomField(UInt128, 0, 62)          # Secure 62-bit random
        ],
        make_basic_coder(
            algorithm=:base_16,
            bits_per_character=4,
            dictionary="0123456789abcdef",
            pad_char='0',
            use_full_with=true
        )
    )
end

const UUIDV7_SECURE_MONOTONIC_DEFINITION = UUIDv7SecureMonotonicDefinition()

"""
    UUIDv7SecureSubMillisecondDefinition()

Cryptographically secure version of UUIDv7SubMillisecondDefinition().

**Identical to UUIDv7SubMillisecondDefinition except:**
- Uses `CryptographicRandomField` for 62 random bits
- Sub-millisecond fraction still uses `time_ns()` (temporal data, not random)
- ~2x slower than standard sub-millisecond configuration

**When to use this instead of `UUIDv7SubMillisecondDefinition()`:**
- ✅ High-precision event logging with security requirements
- ✅ Scientific instrumentation requiring unpredictable IDs
- ✅ Forensics and audit trails
- ❌ High-frequency trading (latency-critical)

**RFC 9562 Compliance:** Fully compliant with Section 6.9 CSPRNG recommendation.

# Examples
```julia-repl
julia> defn = UUIDv7SecureSubMillisecondDefinition()
julia> id = tsid_generate(defn)
```
"""
function UUIDv7SecureSubMillisecondDefinition()
    TSIDGenericContainer(
        Int128,
        :UUIDv7SecureSubMillisecond,
        [
            TimestampField(Int128, 80, 48, UNIX_EPOCH_START),
            ConstantField(Int128, :version, 76, 4, 7),
            UUIDv7SubMillisecondField(Int128, 64, 12),  # Sub-ms precision (temporal, not random)
            ConstantField(Int128, :variant, 62, 2, 2),
            CryptographicRandomField(UInt128, 0, 62)    # Secure 62-bit random
        ],
        make_basic_coder(
            algorithm=:base_16,
            bits_per_character=4,
            dictionary="0123456789abcdef",
            pad_char='0',
            use_full_with=true
        )
    )
end

const UUIDV7_SECURE_SUBMILLISECOND_DEFINITION = UUIDv7SecureSubMillisecondDefinition()

"""
    UUIDv7SecureDistributedDefinition(machine_id::Int)

Cryptographically secure version of UUIDv7DistributedDefinition().

**Identical to UUIDv7DistributedDefinition except:**
- Uses `CryptographicRandomField` for 62 random bits
- Machine ID and counter are still predictable (structural data, not random)
- ~2x slower than standard distributed configuration

**When to use this instead of `UUIDv7DistributedDefinition()`:**
- ✅ Multi-datacenter authentication systems
- ✅ Distributed security-sensitive applications
- ✅ Kubernetes deployments requiring unpredictable IDs
- ❌ High-throughput microservices (>50K IDs/second per node)

**Security Note:** Machine ID and counter values are predictable by design
(needed for distributed coordination). Only the 62-bit random payload is
cryptographically secure.

**RFC 9562 Compliance:** Fully compliant with Section 6.9 CSPRNG recommendation for random bits.

# Arguments
- `machine_id::Int`: Unique machine identifier (0-63)

# Examples
```julia-repl
julia> machine_id = parse(Int, get(ENV, "MACHINE_ID", "0"))
julia> defn = UUIDv7SecureDistributedDefinition(machine_id)
julia> id = tsid_generate(defn)
```
"""
function UUIDv7SecureDistributedDefinition(machine_id::Int)
    @argcheck 0 <= machine_id < 64 "Machine ID must be in range 0-63 (6 bits)"

    TSIDGenericContainer(
        Int128,
        :UUIDv7SecureDistributed,
        [
            TimestampField(Int128, 80, 48, UNIX_EPOCH_START),
            ConstantField(Int128, :version, 76, 4, 7),
            ConstantField(Int128, :machine_id, 70, 6, machine_id),
            UUIDv7DistributedCounterField(Int128, 64, 6),  # Counter (predictable by design)
            ConstantField(Int128, :variant, 62, 2, 2),
            CryptographicRandomField(UInt128, 0, 62)       # Secure 62-bit random
        ],
        make_basic_coder(
            algorithm=:base_16,
            bits_per_character=4,
            dictionary="0123456789abcdef",
            pad_char='0',
            use_full_with=true
        )
    )
end
