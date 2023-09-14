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
 
# About

In distributed systems, sometimes the latency for acquiring unique IDs (e.g. for primary/technical keys, sequences) between different nodes/threads and a single coordinator (database/service etc.) is too high under some circumstances. In such contexts Universally Unique IDentifiers (UUIDs) can be used.

This library provides few algorithms to generate some of them and supports user friendly text representations.

# Background

Julia currently offers implementations UUID v1, v4 and v5 (see [UUIDs in Standard Library](https://docs.julialang.org/en/v1/stdlib/UUIDs)). While these provide industry standard algorithms and representations of the IDs (see [RFC 4122](https://www.ietf.org/rfc/rfc4122.txt)), they are not always ideal for usage in databases as they could induce some difficulties like index fragmentation/write amplification.

There are number of new UUID proposals (see [New UUID Formats](https://www.ietf.org/archive/id/draft-peabody-dispatch-new-uuid-format-01.html)).

Additional reading:
* [The best UUID type for database keys](https://vladmihalcea.com/uuid-database-primary-key/);
* [The primary key dillema: IDs vs UUIDs and some practical solutions](https://fillumina.wordpress.com/2023/02/06/the-primary-key-dilemma-id-vs-uuid-and-some-practical-solutions/);
* [How to not use TSID factories](https://fillumina.wordpress.com/2023/01/19/how-to-not-use-tsid-factories/)

Also for some security implications:
* https://www.intruder.io/research/in-guid-we-trust
* https://infosecwriteups.com/how-this-easy-vulnerability-resulted-in-a-20-000-bug-bounty-from-gitlab-d9dc9312c10a
* https://infosecwriteups.com/bugbounty-how-i-was-able-to-compromise-any-user-account-via-reset-password-functionality-a11bb5f863b3
This library implements few of these starting with [Snowflake](https://github.com/twitter-archive/snowflake) alikes and using [Crockford Base 32](https://www.crockford.com/base32.html) for textual representation.

# Features

Currently implemented TsIds allow for:

* Support 64 bit types (Int64/UInt64) which are shorter than UUIDs, ULIDs, KSUIDs etc.
  * these can be used as traditional int primary keys in databases (sqllite, postgresql etc.) instead of sequences, with low probability of conflict depending on bit sizes in the ID definition;
  * if stored as strings, they use 13 (without) or 14 characters (with checksums);
  * relatively fast - about 150ns per 64-bit generated id on an M1 with a single group,  field and random or sequential tails, which is faster than some popular libraries for other languages
* Support 128 bit types for rest of the UUID zoo;
* Default TsIds are using signed integers to cover most database tech out of the box;
* Using Crockford Base 32 for textual representation makes them somewhat more readable when displayed to end users;
* Using Crockford Base 32 makes them URL safe (e.g. when used in REST APIs);
* When using Crockford Base 32, they are case insensitive and support hyphens in the encoding which increases readability for end users;
* Sorted monotonically by generation time;

# Usage

Add the package to your project

```julia
julia>]
pkg> add GenId, Dates
```
and import it.
```julia
using GenId, Dates
```

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
julia> tsid_from_string("DJR0RGDG0401")
489485826766409729

julia> crockford32_decode_int64("DJR0RGDG0401")
489485826766409729

julia> crockford32_decode_int64("DJR0-RGDG-0401")
489485826766409729

julia> crockford32_decode_int64("DJR0-RGDG-0401-4", with_checksum=true)
489485826766409729
```

# Specific UUIDs implemented

#### Snowflake ID
see https://en.wikipedia.org/wiki/Snowflake_ID

```julia
# SnowflakeIdDefinition(epoch_start_dt::DateTime, machine_id::Int64)
# 41 bits timestamp (ms), 10 bits machine id, 12 bits sequence numbers per machine
julia> iddef = SnowflakeIdDefinition(DateTime(2020, 1, 1, 0, 0, 0, 0), 1)
...

julia> iddef.name == :SnowflakeIdDefinition
true

julia> tsid_generate(iddef)
489485826766409729

julia> tsid_to_string(489485826766409729)
"DJR0RGDG0401"
```

# FAQ

##### What is the status of the package?

64 bit implementation is used internally in production. 128-bit support nearly finished. But public API might still change.

##### Why variations as Ints instead of using wrapper types?

Just a design choice between trade-offs at the moment, mainly constrained by available time for development.
##### Why using Crockford Base 32?

* More readable than some others (e.g. Base32, Base64, Base58 etc.), while still compressing a bit over Hex encoding for example (each character in Crockford Base 32 corresponds to 5 bits of input);
* Simple, efficient;
* Support in other languages (see [Crockford 32 on Github](https://github.com/search?q=crockford+32&type=repositories&s=stars&o=desc)).

##### Future plans
* Add a wrapper type, which will allow for:
  * Typed UUIDs instead of flavors of Ints only;
  * If there is a way to automatically marshall UUIDs from a UUID wrapper type to databases using [DBInterface.jl](https://github.com/JuliaDatabases/DBInterface.jl), will be implemented;
  * Support basic IO over streams (see [CodecBase.jl](https://github.com/JuliaIO/CodecBase.jl) and [TranscodingStreams.jl](https://github.com/JuliaIO/TranscodingStreams.jl));
  * Provide support functions for [StructTypes](https://github.com/JuliaData/StructTypes.jl).
* Add support for 128 bit specific UUIDs (e.g. ULID + some of the official RFC proposals) - high priority;
* Add few more encodings and support declarative grouping through hyphens in textual representations - very low priority.

# License

This library is Open Source software released under the LGPL 3.0+ license.

---
Enjoy! :smiley:
