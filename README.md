# GenId

GenId offers few algorithms to generate mostly non-conflicting and time-ordered IDs (mostly for databases/workflows) without a central coordinator.

[![Project Status: Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://stamov.github.io/GenId.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://stamov.github.io/GenId.jl/dev/)
[![Build Status](https://github.com/stamov/GenId.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/stamov/GenId.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/stamov/GenId.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/stamov/GenId.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![current status](https://img.shields.io/badge/Julia%20support-v1.6%20and%20up-dark%20green)](https://github.com/stamov/GenId.jl/blob/main/Project.toml)

## About

A tiny library making it easy to generate most of the [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier) flavors zoo.

At the lower level it provides a facility to easy combine user defined bit-fields with different semantics (e.g. random numbers, machine id, timestamp etc.) inside Integers. Combining them allows to construct specific UUID generators/parsers in just few lines of code. It also implements widely used (de-)serialization schemes.

Finally it offers example implementations for the following specific UUID schemes used in the industry:

* 128-bit [UUIDv7 (RFC 9562)](https://datatracker.ietf.org/doc/rfc9562/) with 4 configurations: Simple (random), Monotonic (counter-based), Sub-millisecond (high precision), and Distributed (multi-node);
* 128-bit [ULID](https://github.com/ulid/spec) using [Crockford Base 32](https://www.crockford.com/base32.html);
* 128-bit [Nano ID](https://github.com/ai/nanoid) using modified Base 64 text encoding;
* 128-bit [XID](https://github.com/rs/xid) using modified Base 64 text encoding;
* 128-bit [Firebase Push ID](https://github.com/arturictus/firebase_pushid) using modified Base 64 text encoding;
* 64-bit [Snowflake ID](https://github.com/twitter-archive/snowflake) using [Crockford Base 32](https://www.crockford.com/base32.html);
* 64-bit [Instagram ID](https://instagram-engineering.com/sharding-ids-at-instagram-1cf5a71e5a5c) using [Crockford Base 32](https://www.crockford.com/base32.html);



## Features of the library

* Support for 64- and 128-bit UUIDs;
* Small DSL for defining the structure & semantic of a UUID (no syntax/but data oriented through data definitions)
* Support for fields representing widely used UUID components like machine id, random number, timestamp etc.;
* Ability to declaratively combine them in a single Integer with custom offsets and bit lengths;
* Custom implementations of Base 16 (Hex), Base 32, Crockford Base 32 and Base 64 text encoding schemes to allow for phonetic sorting for UUIDs having a timestamp component (e.g. to use the IDs as keys in a database);
* The text encodings are produced/parsed back in big endian byte order;
* Allows to get back field values from UUIDs;
* Ability to use own text encoding dictionaries with declarative case sensitivity for the simple ones;
* Currently all UUID examples mask the highest bit, to allow transparent storage in databases which don't have large unsigned integer types.

## Usage

Add the package to your project:

```julia
julia> Pkg.add("GenId")
```

and import it:

```julia
using GenId, Dates
```

### Quick Start: Pre-built ID Types

GenId provides several pre-built ID generators for common use cases. Choose based on your requirements:

| ID Type | Size | Timestamp? | Use Case |
|---------|------|------------|----------|
| **UUIDv7** | 128-bit | ✅ ms | RFC 9562 standard, 4 standard + 4 secure configurations |
| **ULID** | 128-bit | ✅ ms | General purpose, lexicographically sortable |
| **Snowflake ID** | 64-bit | ✅ ms | Compact, Twitter-style distributed IDs |
| **Instagram ID** | 64-bit | ✅ ms | Database sharding with shard IDs |
| **XID** | 128-bit | ✅ sec | Process-aware IDs, Go compatible |
| **Firebase Push ID** | 128-bit | ✅ ms | Firebase-compatible with high randomness |
| **Nano ID** | 128-bit | ❌ | Pure random, URL-safe (⚠️ not cryptographically secure) |

## Specific UUID Implementations

### UUIDv7 (RFC 9562 Standard)

[UUIDv7](https://datatracker.ietf.org/doc/rfc9562/) is the latest UUID standard (RFC 9562, published August 2024) designed for database-friendly, time-ordered identifiers. GenId implements all four recommended configurations from the RFC specification.

**Why UUIDv7?**
- ✅ Official IETF standard (RFC 9562)
- ✅ Native support in modern databases (PostgreSQL 17+, upcoming MySQL releases)
- ✅ Lexicographically sortable with millisecond timestamp precision
- ✅ 128-bit for strong uniqueness guarantees
- ✅ Multiple configurations for different use cases

#### Configuration 1: Simple (Random-based)

Best for: Single-node systems, high randomness requirements, no coordination needed.

```julia
# Use pre-built constant
julia> defn = UUIDV7_SIMPLE_DEFINITION
# Or create new instance
julia> defn = UUIDv7SimpleDefinition()

# Generate IDs
julia> id = tsid_generate(defn)
132988090416862009116372004746509426

julia> id_str = tsid_generate_string(defn)
"00199CD1AFB0A7003B975725DE886A56"

# Extract timestamp
julia> timestamp = tsid_getfield_value(defn, :timestamp, id)
2025-10-10T...

# Round-trip encoding
julia> decoded = tsid_int_from_string(defn, id_str)
132988090416862009116372004746509426

# Properties:
# - 48 bits timestamp (millisecond precision, Unix epoch)
# - 4 bits version field (always 7)
# - 12 bits random data
# - 2 bits variant field (RFC 4122)
# - 62 bits random data
# - Hex encoding (32 characters)
# - No coordination required
```

#### Configuration 2: Monotonic (Counter-based)

Best for: High-throughput single-node ID generation, guaranteed monotonic ordering within same millisecond.

```julia
# Use pre-built constant
julia> defn = UUIDV7_MONOTONIC_DEFINITION
# Or create new instance
julia> defn = UUIDv7MonotonicDefinition()

# Reset counter to known state (optional)
julia> reset_uuidv7_monotonic_counter(0)

# Generate IDs - guaranteed monotonically increasing
julia> id1 = tsid_generate(defn)
julia> id2 = tsid_generate(defn)
julia> @assert id2 > id1  # Always true

# Extract timestamp and counter
julia> timestamp = tsid_getfield_value(defn, :timestamp, id1)
julia> counter = tsid_getfield_value(defn, :monotonic_counter, id1)

# Properties:
# - 48 bits timestamp (millisecond precision)
# - 4 bits version field (always 7)
# - 12 bits monotonic counter (0-4095 per millisecond)
# - 2 bits variant field
# - 62 bits random data
# - Thread-safe counter with automatic reset on timestamp change
# - Guarantees strict monotonic ordering
# - Capacity: 4,096 IDs per millisecond before waiting
```

#### Configuration 3: Sub-millisecond (High Precision)

Best for: High-precision timestamps, applications needing sub-millisecond resolution.

```julia
# Use pre-built constant
julia> defn = UUIDV7_SUBMILLISECOND_DEFINITION
# Or create new instance
julia> defn = UUIDv7SubMillisecondDefinition()

# Generate IDs with sub-millisecond precision
julia> id = tsid_generate(defn)

julia> id_str = tsid_generate_string(defn)
"00199CD1DB52F700383046B34A20D1B3"

# Extract fields
julia> timestamp = tsid_getfield_value(defn, :timestamp, id)

# Properties:
# - 48 bits timestamp (millisecond precision)
# - 4 bits version field (always 7)
# - 12 bits sub-millisecond fraction (~244 microsecond precision)
# - 2 bits variant field
# - 62 bits random data
# - Higher temporal resolution than simple configuration
# - No coordination required
```

#### Configuration 4: Distributed (Multi-node)

Best for: Distributed systems with multiple nodes, explicit machine ID assignment, guaranteed uniqueness across nodes.

```julia
# Create with machine ID (0-63)
julia> defn = UUIDv7DistributedDefinition(5)  # Machine ID = 5

# Reset counter to known state (optional)
julia> reset_uuidv7_distributed_counter(0)

# Generate IDs
julia> id = tsid_generate(defn)

julia> id_str = tsid_generate_string(defn)

# Extract all fields
julia> timestamp = tsid_getfield_value(defn, :timestamp, id)
julia> machine_id = tsid_getfield_value(defn, :machine_id, id)
5
julia> counter = tsid_getfield_value(defn, :distributed_counter, id)

# Verify machine ID in generated ID
julia> extracted_mid = (id >> 70) & 0x3f
5

# Properties:
# - 48 bits timestamp (millisecond precision)
# - 4 bits version field (always 7)
# - 6 bits machine ID (0-63, supports 64 nodes)
# - 6 bits monotonic counter (0-63 per millisecond per node)
# - 2 bits variant field
# - 62 bits random data
# - Explicit node identification
# - Thread-safe counter per machine
# - Capacity: 64 IDs per millisecond per node
# - Validation: machine_id must be 0-63
```

#### Choosing the Right UUIDv7 Configuration

| Configuration | Best For | Pros | Cons |
|---------------|----------|------|------|
| **Simple** | Single node, low throughput | High randomness, no coordination | No monotonic guarantee in same ms |
| **Monotonic** | Single node, high throughput | Guaranteed ordering, 4K IDs/ms | Single point of contention |
| **Sub-millisecond** | High-precision timestamps | Sub-ms resolution | No monotonic guarantee |
| **Distributed** | Multi-node systems | Explicit node IDs, scalable | Requires machine ID coordination |

#### Cryptographically Secure UUIDv7 Variants

**Security Warning**: The standard UUIDv7 configurations above use non-cryptographic random (`rand()`) for performance. While suitable for database primary keys and distributed IDs, they **should not** be used for:
- Security tokens or session identifiers
- Authentication systems
- Password reset tokens
- API keys or access tokens
- Any security-sensitive application

RFC 9562 Section 6.9 **recommends** using cryptographically secure pseudo-random number generators (CSPRNG) for the random bits in UUIDv7. GenId provides secure variants that use `RandomDevice()` (backed by `/dev/urandom` on Unix or `CryptGenRandom` on Windows) for cryptographically unpredictable random values.

##### Secure Configuration 1: Simple (Cryptographic Random)

Best for: Security tokens, session IDs, authentication systems.

```julia
# Use pre-built constant
julia> defn = UUIDV7_SECURE_SIMPLE_DEFINITION
# Or create new instance
julia> defn = UUIDv7SecureSimpleDefinition()

# Generate cryptographically secure IDs
julia> token = tsid_generate(defn)
julia> token_str = tsid_to_string(defn, token)

# Properties:
# - Identical structure to UUIDv7SimpleDefinition
# - All 74 random bits use RandomDevice() (cryptographically secure)
# - ~2-3x slower than non-secure simple configuration
# - Unpredictable even with knowledge of previous IDs
# - Suitable for security-sensitive applications
```

##### Secure Configuration 2: Monotonic (Cryptographic Random Payload)

Best for: Security-sensitive database primary keys requiring ordering.

```julia
julia> defn = UUIDV7_SECURE_MONOTONIC_DEFINITION
julia> defn = UUIDv7SecureMonotonicDefinition()

# Reset counter to known state (optional)
julia> reset_uuidv7_monotonic_counter(0)

julia> id = tsid_generate(defn)

# Properties:
# - Counter still uses rand() (predictable by design for monotonicity)
# - 62-bit random payload uses RandomDevice() (cryptographically secure)
# - ~1.5-2x slower than non-secure monotonic configuration
# - Maintains strict ordering while securing random bits
# - Use for security-sensitive tables requiring monotonic ordering
```

##### Secure Configuration 3: Sub-millisecond (Cryptographic Random)

Best for: High-precision security logging, audit trails.

```julia
julia> defn = UUIDV7_SECURE_SUBMILLISECOND_DEFINITION
julia> defn = UUIDv7SecureSubMillisecondDefinition()

julia> id = tsid_generate(defn)

# Properties:
# - Sub-millisecond fraction still uses time_ns() (temporal, not random)
# - 62-bit random payload uses RandomDevice() (cryptographically secure)
# - ~2x slower than non-secure sub-millisecond configuration
# - High temporal precision with cryptographic security
```

##### Secure Configuration 4: Distributed (Cryptographic Random)

Best for: Multi-node authentication systems, distributed security-sensitive applications.

```julia
# Create with machine ID (0-63)
julia> machine_id = parse(Int, get(ENV, "MACHINE_ID", "0"))
julia> defn = UUIDv7SecureDistributedDefinition(machine_id)

julia> id = tsid_generate(defn)

# Extract fields
julia> machine_id = tsid_getfield_value(defn, :machine_id, id)
julia> timestamp = tsid_getfield_value(defn, :timestamp, id)

# Properties:
# - Machine ID and counter are predictable (structural data)
# - 62-bit random payload uses RandomDevice() (cryptographically secure)
# - ~2x slower than non-secure distributed configuration
# - Explicit node identification with secure random bits
# - Validation: machine_id must be 0-63
```

##### Security Configuration Comparison

| Configuration | Random Source | Performance Impact | Use For |
|---------------|---------------|-------------------|---------|
| **Standard** | `rand()` | Baseline (fastest) | Database keys, non-sensitive IDs |
| **Secure Simple** | `RandomDevice()` | ~2-3x slower | Security tokens, session IDs |
| **Secure Monotonic** | `RandomDevice()` | ~1.5-2x slower | Secure database keys with ordering |
| **Secure Sub-ms** | `RandomDevice()` | ~2x slower | Secure high-precision timestamps |
| **Secure Distributed** | `RandomDevice()` | ~2x slower | Multi-node security systems |

**Important Security Notes:**
- Cryptographic security applies **only to random bits**
- Timestamps, machine IDs, and counters are **always predictable** by design
- For maximum security, use `UUIDv7SecureSimpleDefinition()` (no predictable counter)
- Never use UUIDs as sole authentication mechanism—always combine with proper authentication
- Secure configurations are ~2x slower—benchmark before using in high-throughput paths (>100K IDs/sec)

**Field Types for Custom IDs:**
- **`RandomField(type, offset, bits)`** - Non-cryptographic random using `rand()` (fast, NOT secure)
- **`CryptographicRandomField(type, offset, bits)`** - Cryptographic random using `RandomDevice()` (secure, slower)

```julia
# Example: Custom secure ID
custom_secure_id = TSIDGenericContainer(
    Int128,
    :SecureCustomID,
    [
        TimestampField(Int128, 80, 48, UNIX_EPOCH_START),
        CryptographicRandomField(UInt128, 0, 80)  # Cryptographically secure
    ],
    make_basic_coder(algorithm=:base_16, bits_per_character=4,
                     dictionary="0123456789abcdef", pad_char='0', use_full_with=true)
)
```

#### UUIDv7 RFC 9562 Compliance

All configurations (standard and secure) comply with RFC 9562 Section 5.7:
- ✅ Version field (bits 48-51) set to `0111` (7)
- ✅ Variant field (bits 64-65) set to `10` (RFC 4122)
- ✅ 48-bit Unix timestamp in milliseconds (bits 0-47)
- ✅ Monotonically increasing within same node
- ✅ Lexicographically sortable when hex-encoded

Secure configurations additionally comply with RFC 9562 Section 6.9 recommendation:
- ✅ Random bits generated using cryptographically secure RNG (CSPRNG)

### ULID (Recommended for Most Use Cases)

[Universally Unique Lexicographically Sortable Identifier](https://github.com/ulid/spec) - 128-bit with millisecond timestamp and 80 bits of randomness.

```julia
# Use pre-built constant for convenience
julia> iddef = ULID_DEFINITION

# Generate IDs
julia> id = tsid_generate(iddef)
170141183460469231731687303715884105727

julia> id_str = tsid_generate_string(iddef)
"7ZZZZZZZZZZZZZZZZZZZZZZZZZ"

# Extract timestamp
julia> timestamp = tsid_getfield_value(iddef, :timestamp, id)
2025-10-09T...

# Decode from string
julia> decoded = tsid_int_from_string(iddef, id_str)
170141183460469231731687303715884105727

# Properties:
# - 48 bits timestamp (millisecond precision, Unix epoch)
# - 80 bits randomness
# - Lexicographically sortable when encoded
# - Crockford Base32 encoding
```

### Snowflake ID

[Twitter Snowflake](https://en.wikipedia.org/wiki/Snowflake_ID) - Compact 64-bit distributed ID with timestamp, machine ID, and sequence counter.

```julia
# SnowflakeIdDefinition(epoch_start_dt::DateTime, machine_id::Int64)
julia> iddef = SnowflakeIdDefinition(DateTime(2020, 1, 1, 0, 0, 0, 0), 1)

julia> id = tsid_generate(iddef)
489485826766409729

julia> id_str = tsid_generate_string(iddef)
"0DJR0RGDG0401"

# Extract fields
julia> timestamp = tsid_getfield_value(iddef, :timestamp, id)
2023-09-12T17:21:55.308

julia> machine = tsid_getfield_value(iddef, :machine_id, id)
1

julia> sequence = tsid_getfield_value(iddef, :machine_sequence, id)
1

# Text encoding (Crockford Base 32)
julia> encoded = tsid_to_string(iddef, id)
"0DJR0RGDG0401"

julia> decoded = tsid_int_from_string(iddef, encoded)
489485826766409729

# Properties:
# - 41 bits timestamp (millisecond precision, custom epoch)
# - 10 bits machine ID (0-1,023)
# - 12 bits sequence counter (0-4,095 per ms)
# - Crockford Base32 encoding
```

### Instagram ID

[Instagram's distributed ID scheme](https://instagram-engineering.com/sharding-ids-at-instagram-1cf5a71e5a5c) - 64-bit optimized for database sharding.

```julia
julia> iddef = InstagramIdDefinition(DateTime(2020, 1, 1), 42)

julia> id = tsid_generate(iddef)

# Note: Instagram uses "shard_id" instead of "machine_id"
julia> timestamp = tsid_getfield_value(iddef, :timestamp, id)
julia> shard = tsid_getfield_value(iddef, :shard_id, id)
42
julia> sequence = tsid_getfield_value(iddef, :machine_sequence, id)

# Properties:
# - 41 bits timestamp (millisecond precision)
# - 13 bits shard ID (0-8,191) for database sharding
# - 10 bits sequence counter (0-1,023)
# - Crockford Base32 encoding
```

### XID

[Go xid-compatible](https://github.com/rs/xid) - 128-bit process-aware IDs with machine and process identification.

```julia
julia> iddef = XIdDefinition(42)  # machine_id

julia> id = tsid_generate(iddef)
julia> id_str = tsid_generate_string(iddef)  # 20 characters

# Extract all fields
julia> timestamp = tsid_getfield_value(iddef, :timestamp, id)
julia> machine = tsid_getfield_value(iddef, :machine_id, id)
42
julia> process = tsid_getfield_value(iddef, :process_id, id)  # OS process ID
julia> sequence = tsid_getfield_value(iddef, :machine_sequence, id)

# Properties:
# - 32 bits timestamp (second precision, Unix epoch)
# - 24 bits machine ID (0-16,777,215)
# - 16 bits process ID (from getpid())
# - 24 bits sequence counter (0-16,777,215)
# - Custom base32-hex encoding
# - Compatible with Go github.com/rs/xid
```

### Firebase Push ID

[Firebase Push ID](https://github.com/arturictus/firebase_pushid) - 128-bit with high randomness for Firebase real-time database.

```julia
# Use pre-built constant
julia> iddef = FIREBASE_PUSHID_DEFINITION

julia> id = tsid_generate(iddef)
301430602692632926610578560781911544

julia> id_str = tsid_generate_string(iddef)
"DVqh4j54DWG1F0Pda-Ms"

julia> timestamp = tsid_getfield_value(iddef, :timestamp, id)

# Text encoding/decoding
julia> encoded = tsid_to_string(iddef, id)
"DVqh4j54DWG1F0Pda-Ms"

julia> decoded = tsid_int_from_string(iddef, encoded)
301430602692632926610578560781911544

# Properties:
# - 48 bits timestamp (millisecond precision)
# - 72 bits randomness (high entropy)
# - Modified Base64 encoding with custom alphabet
# - 20 character strings
# - Firebase-compatible
```



### Insecure Nano ID

[Nano ID](https://github.com/ai/nanoid)-inspired format - 128-bit pure random IDs with URL-safe alphabet.

```julia
julia> iddef = InsecureNanoIdDefinition()

julia> id = tsid_generate(iddef)
julia> id_str = tsid_generate_string(iddef)  # 21 characters, URL-safe

# Round-trip encoding
julia> decoded = tsid_int_from_string(iddef, id_str)

# Properties:
# - 122 bits randomness (no timestamp)
# - Custom URL-safe alphabet
# - 21 character strings
# - ⚠️ WARNING: Uses non-cryptographic random (rand())
# - DO NOT use for security-sensitive applications
# - For secure random IDs, use RandomField with cryptographic RNG
```

### Extracting Field Values

All ID types support unified field extraction using `tsid_getfield_value()`:

```julia
# Generic syntax
value = tsid_getfield_value(iddef, :field_name, id)

# Common field names by ID type:
# - UUIDv7 Simple:             :timestamp
# - UUIDv7 Monotonic:          :timestamp, :monotonic_counter
# - UUIDv7 Sub-ms:             :timestamp
# - UUIDv7 Distributed:        :timestamp, :machine_id, :distributed_counter
# - UUIDv7 Secure Simple:      :timestamp (same as Simple)
# - UUIDv7 Secure Monotonic:   :timestamp, :monotonic_counter (same as Monotonic)
# - UUIDv7 Secure Sub-ms:      :timestamp (same as Sub-ms)
# - UUIDv7 Secure Distributed: :timestamp, :machine_id, :distributed_counter (same as Distributed)
# - Snowflake ID:              :timestamp, :machine_id, :machine_sequence
# - Instagram ID:              :timestamp, :shard_id, :machine_sequence
# - XID:                       :timestamp, :machine_id, :process_id, :machine_sequence
# - ULID:                      :timestamp
# - Firebase:                  :timestamp
# - Nano ID:                   (no extractable fields - pure random)

# Returns appropriate type for each field:
# - :timestamp        → DateTime
# - :machine_id       → Int64
# - :shard_id         → Int64
# - :process_id       → Int64
# - :machine_sequence → Int64
```

### Low-Level Encoding Functions

For direct integer encoding without ID definitions:

```julia
# Crockford Base32 encoding
julia> crockford32_encode_int64(489485826766409729)
"DJR0RGDG0401"

julia> crockford32_encode_int64(489485826766409729; with_checksum=true)
"DJR0RGDG04014"

# Crockford Base32 decoding (supports dashes)
julia> crockford32_decode_int64("DJR0RGDG0401")
489485826766409729

julia> crockford32_decode_int64("DJR0-RGDG-0401")
489485826766409729

julia> crockford32_decode_int64("DJR0-RGDG-0401-4"; with_checksum=true)
489485826766409729

# For 128-bit integers
julia> crockford32_encode_int128(value)
julia> crockford32_decode_int128(string)
```

## Advanced: Custom ID Definitions

For advanced use cases, you can define custom ID structures using `TSIDGenericContainer` and field types.

### Custom ID Example

```julia
using GenId, Dates

# Define custom ID structure
custom_id = TSIDGenericContainer(
    Int128,                    # Storage type (Int64, Int128, UInt64, UInt128)
    :MyCustomID,               # Name for identification
    [
        # Fields listed from MSB to LSB (left to right in bit layout)
        TimestampField(
            Int64,              # Field value type
            80,                 # Bit offset from right (rightmost = 0)
            47,                 # Number of bits
            DateTime(2025, 1, 1) # Epoch start
        ),
        ConstantField(
            UInt64,
            :datacenter_id,     # Field name for extraction
            70,                 # Bit offset
            10,                 # Number of bits
            5                   # Constant value
        ),
        RandomField(
            UInt64,
            40,                 # Bit offset
            30                  # Number of bits (cryptographic random)
        ),
        MachineSequenceField(
            Int64,
            0,                  # Bit offset (rightmost position)
            40                  # Number of bits (thread-safe counter)
        )
    ],
    make_crockford_base_32_coder(
        pad_char='0',
        has_checksum=true,      # Add checksum character
        use_full_with=true,     # Pad to full width
        separator_char='-'      # Separators ignored on decode
    )
)

# Use the custom ID
julia> id = tsid_generate(custom_id)
julia> id_str = tsid_to_string(custom_id, id)
julia> datacenter = tsid_getfield_value(custom_id, :datacenter_id, id)
5
```

### Available Field Types

- **`TimestampField(type, offset, bits, epoch_start)`** - Millisecond timestamp relative to custom epoch
- **`ConstantField(type, name, offset, bits, value)`** - Fixed value (machine ID, datacenter ID, etc.)
- **`RandomField(type, offset, bits)`** - Non-cryptographic random bits using `rand()` (fast, NOT secure)
- **`CryptographicRandomField(type, offset, bits)`** - Cryptographic random bits using `RandomDevice()` (secure, ~2-5x slower)
- **`MachineSequenceField(type, offset, bits)`** - Thread-safe monotonic counter
- **`ProcessIdField(type, offset, bits)`** - OS process ID from `getpid()`

### Custom Text Encoders

```julia
# Crockford Base32 with custom options
coder1 = make_crockford_base_32_coder(
    pad_char='0',
    separator_char='-',
    has_checksum=true,      # Modulo-37 checksum
    use_full_with=false,    # Trim leading pad characters
    max_string_length=typemax(Int64)
)

# Custom Base64 encoder
coder2 = make_basic_coder(
    algorithm=:base_64,
    bits_per_character=6,
    dictionary="-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz",
    pad_char='0',
    use_full_with=false,
    max_string_length=22,
    case_sensitive=true
)

# Custom Base32 encoder
coder3 = make_basic_coder(
    algorithm=:base_32,
    bits_per_character=5,
    dictionary="234567ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    pad_char='2',
    use_full_with=true
)

# Use in custom ID definition
custom_id = TSIDGenericContainer(Int128, :MyID, fields, coder2)
```

## Background

In distributed systems and IoT environments, acquiring unique IDs from a central coordinator (database or service) introduces latency that can impact performance. This roundtrip latency becomes problematic when generating primary keys, database sequences, or queue identifiers across multiple nodes and threads. [Universally Unique Identifiers (UUIDs)](https://en.wikipedia.org/wiki/Universally_unique_identifier) address this by providing uniqueness guarantees across machines and threads without requiring coordination with a central authority.

**The Time-Ordering Advantage**

Time-ordered UUIDs significantly improve database performance when used as primary keys or in indexes. Random UUIDs (like UUIDv4) cause write amplification and index fragmentation—each new insert lands at a random position in the B-tree index, forcing the database to split pages, rebalance trees, and scatter related data across disk. In contrast, time-ordered UUIDs with monotonically increasing prefixes append new records to the end of indexes, maintaining locality and minimizing page splits. This dramatically improves write throughput and reduces storage overhead while preserving distributed generation benefits.

**Trade-offs and Design Choices**

Different UUID flavors involve trade-offs around performance, security, size (64-bit vs 128-bit), uniqueness guarantees, and serialization formats.

Julia's standard library provides UUID v1, v4, and v7 implementations ([UUIDs in the Standard Library](https://docs.julialang.org/en/v1/stdlib/UUIDs/)). While these follow industry standards ([RFC 4122](https://www.ietf.org/rfc/rfc4122.txt) and [RFC 9562](https://datatracker.ietf.org/doc/rfc9562/)), the standard library UUIDv7 provides only one configuration. GenId extends this by offering four different UUIDv7 configurations (Simple, Monotonic, Sub-millisecond, and Distributed) to match different use cases, plus additional ID formats like ULID, Snowflake, and Firebase Push ID that may be better suited for specific database or distributed system requirements.

Several newer UUID proposals (see [New UUID Formats](https://www.ietf.org/archive/id/draft-peabody-dispatch-new-uuid-format-01.html)) address these limitations with different trade-offs. Below are some resources exploring these developments:

* [Brief history of UUIDs](https://segment.com/blog/a-brief-history-of-the-uuid/);
* [The best UUID type for database keys](https://vladmihalcea.com/uuid-database-primary-key/);
* [The primary key dillema: IDs vs UUIDs and some practical solutions](https://fillumina.wordpress.com/2023/02/06/the-primary-key-dilemma-id-vs-uuid-and-some-practical-solutions/);
* [How to not use TSID factories](https://fillumina.wordpress.com/2023/01/19/how-to-not-use-tsid-factories/)

As well about some security constraints/implications:

* [In GUID we trust](https://www.intruder.io/research/in-guid-we-trust)
* [Example of a vulnerabilty](https://infosecwriteups.com/how-this-easy-vulnerability-resulted-in-a-20-000-bug-bounty-from-gitlab-d9dc9312c10a)
* [Another example of a vulerabity](https://infosecwriteups.com/bugbounty-how-i-was-able-to-compromise-any-user-account-via-reset-password-functionality-a11bb5f863b3)


## FAQ

### What is the status of the package?

Used in production.

Currently we generate signed Integers only. Will be amended in the future.

### Why variations as Ints instead of using wrapper types?

A design choice and not a necessity, between trade-offs at this moment. 

A wrapper type would help distinguish between UUIDs and other integer in an application which is useful. Lack of a wrapper allows for transparent passing around UUIDs between an application and databases/drivers without explicit (de-)serialization, while errors around UUIDs used as keys are enought profound for a system, to discover them rather early then late. A parametrized wrapper type will be implemented in the future.

### Why modified Base 32/64 encoding?

Stock Base 32/64 are not correctly sortable under standard ASCII or UTF variants (even under big endian schemes). The library uses encodings where at first come ASCII numbers, then capital letters, then small letters and finally punctuation characters, which allows for lexicographic sorting of encoded strings. E.g. in a standard (as per [RFC 4648](https://datatracker.ietf.org/doc/html/rfc4648) and earlier [RFC 3548](https://datatracker.ietf.org/doc/html/rfc3548)), characters in the encoding table of the Base 64 encoding are ordered like "ABCDE....abcde...01223...+/", while we use "0123...ABCD...abcd...+-", which is in line with integer codes in ASCII/UTF variants.

### Why Crockford Base 32 encoding?

* More human readable and less error prone to dictation than some others (e.g. Base32, Base64, Base58 etc.), while still compressing a bit over Hex encoding for example (each character in Crockford Base 32 corresponds to 5 bits of input);
* Simple, efficient;
* Support in other languages (see [Crockford 32 on Github](https://github.com/search?q=crockford+32&type=repositories&s=stars&o=desc)).

### Future plans

* Add a wrapper type, which will allow for:
  * Typed UUIDs instead of flavors of Ints only;
  * Compile UUID definitions to minimal set of bit-shifts for calculations and (de-)encoding

## License

This library is Open Source software released under the MIT license.

---
Enjoy! :smiley:
