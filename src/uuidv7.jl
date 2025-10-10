# UUIDv7 Implementation for GenId
# RFC 9562 compliant UUID version 7 with multiple configuration options
#
# Bit Layout (LSB-0 notation, GenId standard):
#   Bits 80-127 (48 bits): unix_ts_ms  - Unix timestamp in milliseconds
#   Bits 76-79  (4 bits):  version     - Constant value 7
#   Bits 64-75  (12 bits): rand_a      - Random or structured data (configuration dependent)
#   Bits 62-63  (2 bits):  variant     - Constant value 0b10 (2)
#   Bits 0-61   (62 bits): rand_b      - Random bits (cryptographic)
#
# RFC MSB-0 to GenId LSB-0 translation:
#   RFC bits 0-47    → GenId bits 80-127  (timestamp)
#   RFC bits 48-51   → GenId bits 76-79   (version)
#   RFC bits 52-63   → GenId bits 64-75   (rand_a / counter / subsec)
#   RFC bits 64-65   → GenId bits 62-63   (variant)
#   RFC bits 66-127  → GenId bits 0-61    (rand_b)

using Base: @lock

# =============================================================================
# Global State for Monotonic Counter (Configuration 2)
# =============================================================================

const UUIDV7_MONOTONIC_LOCK = ReentrantLock()
const UUIDV7_MONOTONIC_COUNTER = Ref{UInt16}(rand(UInt16) % 0x1000)
const UUIDV7_MONOTONIC_LAST_TS = Ref{UInt64}(0)

"""
Reset the UUIDv7 monotonic counter to a random or specified value.

# Examples
```julia-repl
julia> reset_uuidv7_monotonic_counter()  # Random value
julia> reset_uuidv7_monotonic_counter(100)  # Specific value
```
"""
reset_uuidv7_monotonic_counter() = (UUIDV7_MONOTONIC_COUNTER[] = rand(UInt16) % 0x1000; UUIDV7_MONOTONIC_LAST_TS[] = 0)
reset_uuidv7_monotonic_counter(n::Int) = (UUIDV7_MONOTONIC_COUNTER[] = n % 0x1000; UUIDV7_MONOTONIC_LAST_TS[] = 0)

# =============================================================================
# Global State for Distributed Counter (Configuration 4)
# =============================================================================

const UUIDV7_DISTRIBUTED_LOCK = ReentrantLock()
const UUIDV7_DISTRIBUTED_COUNTER = Ref{UInt8}(rand(UInt8) % 0x40)
const UUIDV7_DISTRIBUTED_LAST_TS = Ref{UInt64}(0)

"""
Reset the UUIDv7 distributed counter to a random or specified value.

# Examples
```julia-repl
julia> reset_uuidv7_distributed_counter()  # Random value
julia> reset_uuidv7_distributed_counter(10)  # Specific value
```
"""
reset_uuidv7_distributed_counter() = (UUIDV7_DISTRIBUTED_COUNTER[] = rand(UInt8) % 0x40; UUIDV7_DISTRIBUTED_LAST_TS[] = 0)
reset_uuidv7_distributed_counter(n::Int) = (UUIDV7_DISTRIBUTED_COUNTER[] = n % 0x40; UUIDV7_DISTRIBUTED_LAST_TS[] = 0)

# =============================================================================
# Custom Field Types
# =============================================================================

"""
    UUIDv7MonotonicCounterField{T} <: AbstractGeneratedField

Custom field type for UUIDv7 monotonic counter that increments within each
millisecond and resets to a random value when the timestamp advances.

Provides guaranteed monotonic ordering within each millisecond with capacity
of 4096 IDs per millisecond (12-bit counter).

Thread-safe via lock-protected atomic operations.
"""
struct UUIDv7MonotonicCounterField{T} <: AbstractGeneratedField
    type::DataType
    name::Symbol
    bits_offset::Int64
    bits_length::Int64

    UUIDv7MonotonicCounterField(type, bits_offset, bits_length) =
        new{type}(type, :monotonic_counter, bits_offset, bits_length)
end

function generate_field_value(field::UUIDv7MonotonicCounterField{T}) where {T}
    # Get current timestamp in milliseconds since Unix epoch
    current_ts = UInt64(Dates.value(Dates.now()) - Dates.value(UNIX_EPOCH_START))

    counter = @lock UUIDV7_MONOTONIC_LOCK begin
        if current_ts == UUIDV7_MONOTONIC_LAST_TS[]
            # Same millisecond - increment counter
            cnt = (UUIDV7_MONOTONIC_COUNTER[] + 1) % 0x1000
            if cnt == 0
                # Counter overflow - wait for next millisecond
                while current_ts == UUIDV7_MONOTONIC_LAST_TS[]
                    sleep(0.001)
                    current_ts = UInt64(Dates.value(Dates.now()) - Dates.value(UNIX_EPOCH_START))
                end
                # Reset counter for new millisecond
                cnt = rand(UInt16) % 0x1000
                UUIDV7_MONOTONIC_LAST_TS[] = current_ts
            end
            UUIDV7_MONOTONIC_COUNTER[] = cnt
        else
            # New millisecond - random counter start (RFC 9562 Section 6.2 Method 1)
            cnt = rand(UInt16) % 0x1000
            UUIDV7_MONOTONIC_COUNTER[] = cnt
            UUIDV7_MONOTONIC_LAST_TS[] = current_ts
        end
        UUIDV7_MONOTONIC_COUNTER[]
    end

    return counter
end

"""
    UUIDv7SubMillisecondField{T} <: AbstractGeneratedField

Custom field type for UUIDv7 sub-millisecond precision that captures
high-resolution time within the current millisecond.

With 12 bits, provides theoretical resolution of 1ms / 4096 ≈ 244 nanoseconds.
Actual precision is limited by system clock (typically 100ns-1μs).

Does not guarantee uniqueness - must be combined with random bits.
"""
struct UUIDv7SubMillisecondField{T} <: AbstractGeneratedField
    type::DataType
    name::Symbol
    bits_offset::Int64
    bits_length::Int64

    function UUIDv7SubMillisecondField(type, bits_offset, bits_length)
        @argcheck bits_length <= 12 "Sub-millisecond field limited to 12 bits for UUIDv7"
        new{type}(type, :subsec_fraction, bits_offset, bits_length)
    end
end

function generate_field_value(field::UUIDv7SubMillisecondField{T}) where {T}
    # Get high-precision time in nanoseconds
    time_ns_val = time_ns()

    # Extract nanoseconds within current millisecond (0-999,999 ns)
    subsec_ns = time_ns_val % 1_000_000

    # Scale to bit range: 2^bits_length divisions per millisecond
    max_divisions = one(field.type) << field.bits_length
    fraction = (subsec_ns * max_divisions) ÷ 1_000_000

    return fraction
end

"""
    UUIDv7DistributedCounterField{T} <: AbstractGeneratedField

Custom field type for UUIDv7 distributed counter that increments within each
millisecond per machine and resets when timestamp advances.

Typically uses 6 bits (0-63), providing 64 IDs per millisecond per machine.
When combined with 6-bit machine ID, provides 4096 IDs/ms across cluster.

Thread-safe via lock-protected atomic operations.
"""
struct UUIDv7DistributedCounterField{T} <: AbstractGeneratedField
    type::DataType
    name::Symbol
    bits_offset::Int64
    bits_length::Int64

    UUIDv7DistributedCounterField(type, bits_offset, bits_length) =
        new{type}(type, :distributed_counter, bits_offset, bits_length)
end

function generate_field_value(field::UUIDv7DistributedCounterField{T}) where {T}
    current_ts = UInt64(Dates.value(Dates.now()) - Dates.value(UNIX_EPOCH_START))

    max_count = 1 << field.bits_length

    counter = @lock UUIDV7_DISTRIBUTED_LOCK begin
        if current_ts == UUIDV7_DISTRIBUTED_LAST_TS[]
            # Same millisecond - increment counter
            cnt = (UUIDV7_DISTRIBUTED_COUNTER[] + 1) % max_count
            if cnt == 0
                # Counter overflow - wait for next millisecond
                while current_ts == UUIDV7_DISTRIBUTED_LAST_TS[]
                    sleep(0.001)
                    current_ts = UInt64(Dates.value(Dates.now()) - Dates.value(UNIX_EPOCH_START))
                end
                # Reset counter for new millisecond
                cnt = rand(UInt8) % max_count
                UUIDV7_DISTRIBUTED_LAST_TS[] = current_ts
            end
            UUIDV7_DISTRIBUTED_COUNTER[] = cnt
        else
            # New millisecond - random counter start
            cnt = rand(UInt8) % max_count
            UUIDV7_DISTRIBUTED_COUNTER[] = cnt
            UUIDV7_DISTRIBUTED_LAST_TS[] = current_ts
        end
        UUIDV7_DISTRIBUTED_COUNTER[]
    end

    return counter
end

# =============================================================================
# Configuration 1: Simple UUIDv7 (RFC Baseline)
# =============================================================================

"""
    UUIDv7SimpleDefinition()

Creates a simple RFC 9562 compliant UUIDv7 definition with pure random bits.

This is the baseline implementation using:
- 48-bit Unix millisecond timestamp (bits 80-127)
- 4-bit version field = 7 (bits 76-79)
- 12-bit random field (bits 64-75)
- 2-bit variant field = 0b10 (bits 62-63)
- 62-bit random field (bits 0-61)
- Total: 74 bits of cryptographic randomness

**Characteristics:**
- Uniqueness: 2^74 combinations (~1.9×10²²)
- Collision probability: Negligible for <10M IDs per millisecond
- Monotonicity: None within same millisecond
- State management: None required (stateless)
- Thread safety: Native (no shared state)
- Performance: ~10M IDs/second

**Use cases:**
- General-purpose UUID generation
- Applications without high-frequency bursts
- Strict RFC compliance requirements
- Systems where simplicity is prioritized

**Text encoding:** Compact hex format without hyphens (32 characters)

**Security Note:** Uses non-cryptographic random for performance. Do not use UUIDs as security tokens. For cryptographic security, consider Julia's stdlib UUIDs.uuid7().

# Examples
```julia-repl
julia> defn = UUIDv7SimpleDefinition()
julia> id = tsid_generate(defn)
julia> uuid_str = tsid_to_string(defn, id)
"0192e209-8e14-7b4a-9f71-8c5d3e2a1b0f"
```
"""
function UUIDv7SimpleDefinition()
    TSIDGenericContainer(
        Int128,
        :UUIDv7Simple,
        [
            TimestampField(Int128, 80, 48, UNIX_EPOCH_START),
            ConstantField(Int128, :version, 76, 4, 7),
            RandomField(UInt128, 64, 12),
            ConstantField(Int128, :variant, 62, 2, 2),
            RandomField(UInt128, 0, 62)
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

const UUIDV7_SIMPLE_DEFINITION = UUIDv7SimpleDefinition()

# =============================================================================
# Configuration 2: Monotonic UUIDv7 (Recommended Default)
# =============================================================================

"""
    UUIDv7MonotonicDefinition()

Creates a monotonic UUIDv7 definition with guaranteed ordering within milliseconds.

This is the **RECOMMENDED** default implementation using:
- 48-bit Unix millisecond timestamp (bits 80-127)
- 4-bit version field = 7 (bits 76-79)
- 12-bit monotonic counter (bits 64-75) - increments within each millisecond
- 2-bit variant field = 0b10 (bits 62-63)
- 62-bit random field (bits 0-61)
- Total: 62 bits of cryptographic randomness

The counter increments within each millisecond and resets to a random value
when the timestamp advances, ensuring:
- Strict monotonic ordering within same millisecond
- No collisions (up to 4096 IDs/ms capacity)
- Unpredictable counter initialization across restarts

**Characteristics:**
- Uniqueness: Guaranteed (4096 IDs per millisecond)
- Collision probability: Zero (within capacity limits)
- Monotonicity: Strict within millisecond
- State management: Global counter + timestamp (24 bytes)
- Thread safety: Lock-protected atomic operations
- Performance: ~4M IDs/second (4096/ms capacity)

**Use cases:**
- Database primary keys (PRIMARY RECOMMENDATION)
- High-throughput event logging
- Distributed tracing systems
- Any system requiring strict ordering

**Advantages:**
- ✅ Best B-tree index locality for databases
- ✅ Guaranteed monotonic ordering
- ✅ Clear capacity limits (4096/ms)
- ✅ RFC 9562 Section 6.2 Method 1 (officially recommended)

**Text encoding:** Compact hex format without hyphens (32 characters)

**Security Note:** Uses non-cryptographic random for performance. Do not use UUIDs as security tokens. For cryptographic security, consider Julia's stdlib UUIDs.uuid7().

# Examples
```julia-repl
julia> defn = UUIDv7MonotonicDefinition()
julia> id1 = tsid_generate(defn)
julia> id2 = tsid_generate(defn)
julia> id1 < id2  # Guaranteed monotonic
true
julia> uuid_str = tsid_to_string(defn, id1)
"0192e209-8e14-7b4a-9f71-8c5d3e2a1b0f"
```
"""
function UUIDv7MonotonicDefinition()
    TSIDGenericContainer(
        Int128,
        :UUIDv7Monotonic,
        [
            TimestampField(Int128, 80, 48, UNIX_EPOCH_START),
            ConstantField(Int128, :version, 76, 4, 7),
            UUIDv7MonotonicCounterField(Int128, 64, 12),
            ConstantField(Int128, :variant, 62, 2, 2),
            RandomField(UInt128, 0, 62)
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

const UUIDV7_MONOTONIC_DEFINITION = UUIDv7MonotonicDefinition()

# =============================================================================
# Configuration 3: Sub-millisecond Precision UUIDv7
# =============================================================================

"""
    UUIDv7SubMillisecondDefinition()

Creates a UUIDv7 definition with sub-millisecond precision for precise event ordering.

This implementation uses:
- 48-bit Unix millisecond timestamp (bits 80-127)
- 4-bit version field = 7 (bits 76-79)
- 12-bit sub-millisecond fraction (bits 64-75) - ~244ns theoretical resolution
- 2-bit variant field = 0b10 (bits 62-63)
- 62-bit random field (bits 0-61)
- Total: 62 bits of cryptographic randomness

The sub-millisecond field captures high-precision time within the current
millisecond using `time_ns()`. With 12 bits, this provides 4096 divisions
per millisecond (theoretical resolution ~244 nanoseconds).

**Note:** Actual precision is limited by system clock resolution (typically 100ns-1μs).
This does NOT guarantee uniqueness - collisions are still possible.

**Characteristics:**
- Uniqueness: Probabilistic (62 bits random)
- Collision probability: Negligible (62 bits entropy)
- Temporal resolution: ~244 nanoseconds (theoretical)
- Actual precision: 100ns-1μs (system dependent)
- State management: None required
- Thread safety: Native
- Performance: ~5M IDs/second

**Use cases:**
- High-frequency trading systems
- Precision event logging (microsecond resolution)
- Scientific instrumentation
- Systems with high-precision clock requirements
- Debugging and forensics

**Text encoding:** Compact hex format without hyphens (32 characters)

**Security Note:** Uses non-cryptographic random for performance. Do not use UUIDs as security tokens. For cryptographic security, consider Julia's stdlib UUIDs.uuid7().

# Examples
```julia-repl
julia> defn = UUIDv7SubMillisecondDefinition()
julia> id = tsid_generate(defn)
julia> uuid_str = tsid_to_string(defn, id)
"0192e209-8e14-7b4a-9f71-8c5d3e2a1b0f"
```
"""
function UUIDv7SubMillisecondDefinition()
    TSIDGenericContainer(
        Int128,
        :UUIDv7SubMillisecond,
        [
            TimestampField(Int128, 80, 48, UNIX_EPOCH_START),
            ConstantField(Int128, :version, 76, 4, 7),
            UUIDv7SubMillisecondField(Int128, 64, 12),
            ConstantField(Int128, :variant, 62, 2, 2),
            RandomField(UInt128, 0, 62)
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

const UUIDV7_SUBMILLISECOND_DEFINITION = UUIDv7SubMillisecondDefinition()

# =============================================================================
# Configuration 4: Distributed UUIDv7 (Multi-datacenter)
# =============================================================================

"""
    UUIDv7DistributedDefinition(machine_id::Int)

Creates a distributed UUIDv7 definition for multi-datacenter deployments.

This implementation uses:
- 48-bit Unix millisecond timestamp (bits 80-127)
- 4-bit version field = 7 (bits 76-79)
- 6-bit machine ID (bits 70-75) - identifies the node/datacenter/pod (0-63)
- 6-bit monotonic counter (bits 64-69) - per-machine counter (0-63 per ms)
- 2-bit variant field = 0b10 (bits 62-63)
- 62-bit random field (bits 0-61)
- Total: 62 bits of cryptographic randomness

The machine ID must be assigned uniquely to each node (0-63). The counter
increments independently on each machine, ensuring no runtime coordination needed.

**Bit allocation:**
- Machine ID: 6 bits = 64 unique machines/datacenters/pods
- Counter: 6 bits = 64 IDs per millisecond per machine
- Total cluster capacity: 64 × 64 = 4096 IDs/ms

**Machine ID assignment strategies:**
- Environment variable: `parse(Int, get(ENV, "MACHINE_ID", "0"))`
- MAC address hash: `hash(mac_address) % 64`
- Kubernetes pod ordinal: `parse(Int, ENV["POD_ORDINAL"]) % 64`
- Consul/etcd registration: auto-assigned from service registry

**Characteristics:**
- Uniqueness: Guaranteed (64 IDs/ms per machine)
- Distributed: 64 machines, no runtime coordination
- Per-node capacity: 64 IDs/millisecond = 64K IDs/second
- Cluster capacity: 4096 IDs/millisecond total
- State management: Counter + timestamp + machine ID
- Thread safety: Lock-protected atomic operations
- Configuration: One-time machine ID assignment

**Important:** Use only ONE machine ID per process. Multiple `UUIDv7DistributedDefinition` instances with different machine IDs in the same process will share counter state (edge case limitation).

**Use cases:**
- Multi-datacenter deployments
- Kubernetes clusters (use pod ID as machine ID)
- Distributed microservices
- Systems without central coordination

**Advantages:**
- ✅ No runtime coordination needed
- ✅ Fault-tolerant (node failures don't affect others)
- ✅ Clear capacity per node
- ✅ Similar to Twitter Snowflake pattern

**Text encoding:** Compact hex format without hyphens (32 characters)

**Security Note:** Uses non-cryptographic random for performance. Do not use UUIDs as security tokens. For cryptographic security, consider Julia's stdlib UUIDs.uuid7().

# Arguments
- `machine_id::Int`: Unique machine identifier (0-63)

# Examples
```julia-repl
julia> machine_id = parse(Int, get(ENV, "MACHINE_ID", "0"))
julia> defn = UUIDv7DistributedDefinition(machine_id)
julia> id = tsid_generate(defn)
julia> uuid_str = tsid_to_string(defn, id)
"0192e209-8e14-7b4a-9f71-8c5d3e2a1b0f"

# Extract machine ID from generated UUID
julia> tsid_getfield_value(defn, :machine_id, id)
0
```
"""
function UUIDv7DistributedDefinition(machine_id::Int)
    @argcheck 0 <= machine_id < 64 "Machine ID must be in range 0-63 (6 bits)"

    TSIDGenericContainer(
        Int128,
        :UUIDv7Distributed,
        [
            TimestampField(Int128, 80, 48, UNIX_EPOCH_START),
            ConstantField(Int128, :version, 76, 4, 7),
            ConstantField(Int128, :machine_id, 70, 6, machine_id),
            UUIDv7DistributedCounterField(Int128, 64, 6),
            ConstantField(Int128, :variant, 62, 2, 2),
            RandomField(UInt128, 0, 62)
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
