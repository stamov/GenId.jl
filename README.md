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

* 128-bit [UUIDv7](https://datatracker.ietf.org/doc/html/draft-peabody-dispatch-new-uuid-format#old_var_table) proposal/variant with machine id;
* 128-bit [Nano ID](https://github.com/ai/nanoid) using modified Base 64 text encoding;
* 128-bit [ULID](https://github.com/ulid/spec) using [Crockford Base 32](https://www.crockford.com/base32.html);
* 128-bit [XID](https://github.com/rs/xid) using modified Base 64 text encoding;
* 128-bit [Firebase Push ID](https://github.com/arturictus/firebase_pushid) using modified Base 64 text encoding;
* 64-bit [Snowflake ID](https://github.com/twitter-archive/snowflake) using [Crockford Base 32](https://www.crockford.com/base32.html);
* 64-bit [Instagram ID](https://instagram-engineering.com/sharding-ids-at-instagram-1cf5a71e5a5c) using [Crockford Base 32](https://www.crockford.com/base32.html);

## Background

In distributed and/or IOT systems, the latency for acquiring unique IDs (e.g. for primary/technical keys, sequences in databases, queue middleware etc.) between different nodes/threads and a single coordinator (database/service etc.) is sometimes higher than desirable. In such contexts Universally Unique IDentifiers ([UUIDs](https://en.wikipedia.org/wiki/Universally_unique_identifier)) can be used as they offer some uniqueness guarantees across number of machines/threads without round-trips to a central authority.

Different flavors of UUIDs have different trade-offs around performance, security, number of bytes used, uniqueness guarantees, (de-)serialization choices etc.

Julia currently offers implementations of UUID v1, v4 and v5 (see [UUIDs in the Standard Library](https://docs.julialang.org/en/v1/stdlib/UUIDs)). While these provide industry standard algorithms and representations of the IDs (see [RFC 4122](https://www.ietf.org/rfc/rfc4122.txt)), they are not always ideal for usage in databases as they can introduce unwanted side effects like index fragmentation/write amplification or require some configuration of the clients generating them in advance.

There are number of new UUID proposals (see [New UUID Formats](https://www.ietf.org/archive/id/draft-peabody-dispatch-new-uuid-format-01.html)) which try to address under different trade-offs some of these shortcomings. Below are few examples:

* [Brief history of UUIDs](https://segment.com/blog/a-brief-history-of-the-uuid/);
* [The best UUID type for database keys](https://vladmihalcea.com/uuid-database-primary-key/);
* [The primary key dillema: IDs vs UUIDs and some practical solutions](https://fillumina.wordpress.com/2023/02/06/the-primary-key-dilemma-id-vs-uuid-and-some-practical-solutions/);
* [How to not use TSID factories](https://fillumina.wordpress.com/2023/01/19/how-to-not-use-tsid-factories/)

As well about some security constraints/implications:

* [In GUID we trust](https://www.intruder.io/research/in-guid-we-trust)
* [Example of a vulnerabilty](https://infosecwriteups.com/how-this-easy-vulnerability-resulted-in-a-20-000-bug-bounty-from-gitlab-d9dc9312c10a)
* [Another example of a vulerabity](https://infosecwriteups.com/bugbounty-how-i-was-able-to-compromise-any-user-account-via-reset-password-functionality-a11bb5f863b3)

## Features of the library

* Support for 64 and 128 signed and unsigned Integers;
* Support for fields representing widely used UUID components like machine id, random number, timestamp etc.;
* Ability to declaratively combine them in a single Integer with custom offsets and bit lengths;
* Custom implementations of Base 32, Crockford Base 32 and Base 64 text encoding schemes to allow for phonetic sorting for UUIDs having a timestamp component (e.g. to use the IDs as keys in a database);
* The text encodings are output in big endian;
* Allows to get back field values from UUIDs;
* Ability for the user to define own fields and schemes.
  
## Usage

Add the package to your project

```julia
julia> Pkg.add("GenId")
```

and import it.

```julia
using GenId, Dates
```

## Specific UUIDs implemented

### Snowflake ID

See https://en.wikipedia.org/wiki/Snowflake_ID

```julia
# SnowflakeIdDefinition(epoch_start_dt::DateTime, machine_id::Int64)
# 41 bits timestamp (ms), 10 bits machine id, 12 bits sequence numbers per machine
julia> iddef = SnowflakeIdDefinition(DateTime(2020, 1, 1, 0, 0, 0, 0), 1)
...

julia> iddef.name == :SnowflakeIdDefinition
true

julia> tsid_generate(iddef)
489485826766409729

julia> tsid_generate_string(iddef)
"DJR0RGDG0401"

# en-/decoded using Crockford Base 32
julia> tsid_to_string(iddef, 489485826766409729)
"DJR0RGDG0401"

julia> tsid_int_from_string(iddef, "DJR0RGDG0401")
489485826766409729

```

### Firebase PushID

See https://github.com/arturictus/firebase_pushid

Uses modified Base 64 text encoding.

```julia
# FirebasePushIdDefinition()
# 48 bits timestamp (ms), 72 randomness
julia> iddef = FirebasePushIdDefinition()
...

julia> iddef.name == :FirebasePushIdDefinition
true

julia> tsid_generate(iddef)
301430602692632926610578560781911544

julia> tsid_generate_string(iddef)
"EWsj5l65EXH2G1Qfc0Nu"

julia> tsid_to_string(iddef, 301430602692632926610578560781911544)
"EWsj5l65EXH2G1Qfc0Nu"

julia> tsid_int_from_string(iddef, "EWsj5l65EXH2G1Qfc0Nu")
301430602692632926610578560781911544
```

### Generic 64-bit UUID

Define an UUID structure

```julia

# The machine id for the current process unique in the infrastructure for the specific application (e.g. machine id in a cluster or VPC etc.).
# Can come from a configuration file, environment variable, last digits of an IP address etc.
machine_id = 1 

# the actual UUID definition
iddef = TsIdDefinition(
    # Data type used for storage of the ID
    Int64; 
    # Number of bits used for the timestamp section.
    bits_time=41, 
    # Number of bits used for the machine section.
    bits_group_1=10, 
    # Number of bits for the tail section.
    # Can be a random number or a local machine/thread specific sequence.
    bits_tail=12, 
    # Increment tail bits globally (independent of thread ids) for the node (machine/server)
    tail_algorithm=:machine_increment,
    # Use group_1 as the machine_id
    group_1=machine_id, 
    # Start of the epoch for this UUID scheme.
    # Time before that can't be represented.
    epoch_start_dt=DateTime(2020, 1, 1, 0, 0, 0, 0), 
    # End of the epoch for this UUID scheme.
    # Time after that can't be represented.
    epoch_end_dt=DateTime(2070, 12, 31, 23, 59, 59, 999)
)
# The sum of the desired bits must match the word size of the specified data type (e.g. 41+10+12=63, which (currently) are the number of bits used in a Int64 type).
# Start and end of the epoch of the ID must fit in the desired number of bits for time.

# or

iddef = SnowflakeIdDefinition(
  # Start of the epoch for this UUID scheme.
  SOME_EPOCH_START_2020, 
  # the machine_id
  1
)
```

Generate an ID using the ID definition:

```julia
julia> tsid_generate(iddef)
489485826766409729

# the ID is produced in the integer type of desired size
julia> typeof(489485826766409729)
Int64
```

And convert it if necessary to a used friendly text:

```julia
julia> tsid_to_string(489485826766409729)
"DJR0RGDG0401"
```

Or use a lower level function to customize the output:

```julia
julia> crockford32_encode_int64(489485826766409729, with_checksum=true)
"DJR0RGDG04014"
```

Once you have an ID, you can extract back its components:

```julia
julia> tsid_timestamp(iddef, 489485826766409729)
2023-09-12T17:21:55.308

julia> typeof(tsid_timestamp(iddef, 489485826766409729))
DateTime

julia> tsid_machine_id(iddef, 489485826766409729)
1

julia> tsid_machine_tail(iddef, 489485826766409729)
1
```

One can also decode it from a text representation:

```julia
julia> tsid_from_string(iddef, "DJR0RGDG0401")
489485826766409729

julia> crockford32_decode_int64("DJR0RGDG0401")
489485826766409729

julia> crockford32_decode_int64("DJR0-RGDG-0401")
489485826766409729

julia> crockford32_decode_int64("DJR0-RGDG-0401-4", with_checksum=true)
489485826766409729
```

## FAQ

### What is the status of the package?

Used in production.

Few unpolished nuances around (un-)signed integers and (un-)signed fields at first position.

### Why variations as Ints instead of using wrapper types?

A design choice and not a necessity, between trade-offs at this moment. 

A wrapper type would help distinguish between UUIDs and other integer in an application which is useful. Lack of a wrapper allows for transparent passing around UUIDs between an application and databases/drivers without explicit (de-)serialization, while errors around UUIDs used as keys are enought profound for a system, to discover them rather early then late. But, a wrapper type is planned, not just for higher type safety, but also for easier support of larger than UInt128 UUIDs (e.g. KSUID)

### Why modified Base 32/64 encoding?

Stock Base 32/64 are not correctly sortable under standard ASCII or UTF variants (esp. under big endian schemes). The library uses encodings where at first come ASCII numbers, then capital letters, then small letters and finally punctuation characters, which allows for lexicographic sorting of encoded strings. E.g. in a standard (as per [RFC 4648](https://datatracker.ietf.org/doc/html/rfc4648) and earlier [RFC 3548](https://datatracker.ietf.org/doc/html/rfc3548)), characters in the encoding table of the Base 64 encoding are ordered like "ABCDE....abcde...01223...+/", while we use "0123...ABCD...abcd...+-", which is in line with integer codes in ASCII/UTF variants.

### Why Crockford Base 32 encoding?

* More human readable and less error prone to dictation than some others (e.g. Base32, Base64, Base58 etc.), while still compressing a bit over Hex encoding for example (each character in Crockford Base 32 corresponds to 5 bits of input);
* Simple, efficient;
* Support in other languages (see [Crockford 32 on Github](https://github.com/search?q=crockford+32&type=repositories&s=stars&o=desc)).

### Future plans

* Add a wrapper type, which will allow for:
  * Typed UUIDs instead of flavors of Ints only;
  * Instead of run-time interpretation of the UUID definitions, compile them with macros at compile time for faster execution;
  * If there is a way to automatically marshall UUIDs from a UUID wrapper type to databases using [DBInterface.jl](https://github.com/JuliaDatabases/DBInterface.jl), will be implemented;
  * Support basic IO over streams (see [CodecBase.jl](https://github.com/JuliaIO/CodecBase.jl) and [TranscodingStreams.jl](https://github.com/JuliaIO/TranscodingStreams.jl));
  * Provide support functions for [StructTypes](https://github.com/JuliaData/StructTypes.jl).
* Replace several methods with macros for higher performance

## License

This library is Open Source software released under the LGPL 3.0+ license.

---
Enjoy! :smiley:
