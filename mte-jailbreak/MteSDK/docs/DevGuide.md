# MTE Core Developer's Guide

***MTE Version 3.0***

## Introduction

Eclypses has developed a secure and proprietary protocol for safely communicating data between connected devices. Using the Eclypses MicroToken Exchange (MTE) library to substitute sensitive data with MicroTokens is one of the easiest ways to ensure all data transmitted in your system is secure to a quantum-resistant level. It does this by creating random substitute values known as MicroTokens that replace each byte of a sensitive data item. These MicroTokens are never derived from the data they are substituting or related to any other MicroToken, they are instead produced by NIST-approved Deterministic Random Bit Generators (DRBG).

The MTE library allows you to send the same data multiple times while ensuring each transmission packet is unique and impenetrable. The MTE is simple to integrate into your applications that currently run on your systems and requires no architectural changes. The library is meant to be compiled into your existing application that already sends and/or receives data. Before sending data, you simply encode it first with MTE, then send the encoded version. After receiving data, you simply decode it before using it.

The MTE library is written in C, but support is provided for numerous languages through the use of language interface code provided as part of the SDK. The language interface code is meant to be included in your application and built as part of it. It is important to always use the language interface code that comes with the version of the SDK in use as things change and the language interface source code must be in sync with the compiled library. The language interfaces are documented separately.

There are optional add-on libraries that use the core MTE, and these are documented in their own guides.

## Terms and Abbreviations

Following are terms and abbreviations used throughout the document:

|Term|Definition|
|----|----------|
|**AES**|Advanced Encryption Standard. This is a cryptographic module that provides symmetric encryption and decryption of data. FIPS 197 defines the AES algorithm. FIPS 140-3 defines a procedure for certifying implementations of approved cryptographic modules like AES.|
|**Base64**| An encoding of binary data that uses only a subset of ASCII that is compatible with email transport and strings.|
|**Buildtime Options**|The SDK is built with only a single option set for DRBG, verifiers, etc.|
|**Decode**|To transform tokens back to the original data.|
|**Denial Of Service (DOS)**|An attack based on overwhelming the attacked device.|
|**DRBG**|Deterministic Random Bit Generator. This is a cryptographic module that produces statistically random bits. NIST SP 800-90a defines approved DRBG algorithms. FIPS 140-3 defines a procedure for certifying implementations of approved cryptographic modules like DRBGs.|
|**Encode**|To transform input data to a replacement set of tokens. |
|**Entropy**|A measure of randomness. Cryptographically secure DRBGs must be supplied with sufficient entropy to ensure their cryptographic strength. If the entropy can be predicted in any way, the security of anything that uses the DRBG is lost.|
|**FIPS**|Federal Information Processing Standard|
|**Inherent Authentication**|The ability of MTE to authenticate an encoded message by verifying that each token is valid in the current state.|
|**Instantiate**|To initialize a DRBG with the entropy, nonce, and [personalization string](#terms-and-abbreviations) to create its initial state and make it ready to produce random bits. Also refers to encoders and decoders initializing, since their primary initialization is to prepare the DRBG.|
|**Message**|The output from MTE's encode operation.|
|**MTE**|MicroToken Exchange|
|**NIST**|National Institute of Standards and Technology|
|**Nonce**|A short non-repeating value used to add unpredictability to DRBG instantiations.|
|**PAA**|Processor Algorithm Accelerator. Certain hardware has special capabilities to accelerate certain algorithms.|
|**Personalization String**|An additional input to a DRBG instantiation to add unpredictability to the DRBG state and output.|
|**Replay**|An attack based on resending a previously-sent message.|
|**Reseed Counter**|A counter inside the DRBG that indicates how many times it has been used since seeding. When the reseed counter reaches the [reseed interval](#terms-and-abbreviations), the DRBG will stop functioning in order to protect security.|
|**Reseed Interval**|The number of times a DRBG can be used before it must be seeded again. If the DRBG is used that many times, it will enter an error state.|
|**Resilience**|The level of effort required to successfully attack a cryptographic operation, taking [security strength](#terms-and-abbreviations) and other factors into account.|
|**Runtime Options**|The SDK is built with all options available for DRBG, verifiers, etc. and the desired options are selected at runtime.|
|**Security Strength**|A measure of expected effort required to attack a cryptographic operation.|
|**SHA**|Secure Hash Algorithm. This is a cryptographic module that provides secure hash digests of pieces of data. FIPS 180-4 defines the SHA algorithms. FIPS 140-3 defines a procedure for certifying implementations of approved cryptographic modules like SHA.|
|**Token**|A random value used as a substitute for a byte of real data.|
|**Uninstantiate**|To destroy a DRBG’s internal state so it can no longer produce random bits. This takes the form of zeroization and is a security measure.|
|**Zeroization**|Overwriting a buffer or state with zeros to ensure the value is not readable.|

## Prerequisites

The following are required to use the MTE library:

* Access to the source code of the applications that will be encoding and decoding. The source code will need to be modified to add calls to MTE, and the applications will need to be rebuilt to link with the MTE library.

* A method for creating and sharing [entropy](#terms-and-abbreviations) securely, as well as methods for sharing the [nonce](#terms-and-abbreviations) and [personalization string](#terms-and-abbreviations) if used. The encoder and decoder must be instantiated with the same three inputs in order to encode and decode successfully.

* If buildtime option libraries have been provided, the options chosen must be the same on the encoder and decoder sides. If runtime option libraries have been provided, the encoder and decoder must use the same sets of options. Methods are provided to help you choose the correct options.

* If the timestamp verifier is used, the encoder and decoder must both provide accurate timestamps.

## Caveats

The MTE technology was designed to fit in a wide range of systems with some having extremely limited resources. For this reason, it can be built with or without numerous features. Throughout this document, wherever the type of build can affect the behavior of the technology, there will be a caveat of one of the following types:

* **Buildtime options**: this caveat applies when the build is done with a fixed set of options to reduce the footprint greatly and typically involves requiring function arguments to match the buildtime options since the choices are built in and no longer changeable at runtime.

## Architecture

### General

The MTE library is written in C and built in a freestanding (versus hosted) environment where possible (some architectures or library types do not allow this). This means the library has no external dependencies (and on non-freestanding architectures/libraries, only dependencies introduced by the architecture/library). Even the standard C library is not a dependency, so the MTE library can be used in device drivers and on microcontrollers that do not have C library availability. As a result, the library has an extremely small footprint in library/code size, memory usage, and stack space.

The C API provides all the functionality of the library and should be used in resource-constrained applications to achieve the smallest footprint.

The C API includes a lot of implementation details in the header files. This must be considered changeable detail and should not be used. Only definitions, structures, and functions documented in this guide are part of the public API and will not be changed without notice. The use of comments in definitions or data structures (e.g., `/* ... */`) in this guide indicates information or members that are specifically not documented and are changeable detail and should not be used.

The core API consists of three sets of interfaces: base, encoder, and decoder. The base interface provides basic functions that are not specific to an encoder or decoder. The encoder interfaces manage creating, instantiating, encoding, and uninstantiating encoders, among other tasks. The decoder interfaces manage creating, instantiating, decoding, retrieving decode information, and uninstantiating decoders, among other tasks.

The library is thread-safe as long as no two threads use the same state structure (or object in object-oriented language interfaces) at the same time.

For maximum performance it is desirable to have buffers aligned at least to the size of the largest integer supported by the compiler. This can be 128-bit (16 byte) alignment for some compilers on 64-bit operating systems. Every function that takes a generic array or buffer will work regardless of alignment; it may just run faster if aligned properly.

All structures are designed to naturally align when declared and allocated normally. Forcing a structure out of alignment will result in hardware exceptions on some platforms. On platforms where it is allowed, performance will suffer if it is done. In particular, when 128-bit support is required, structures with 128-bit integers must align on 16 byte boundaries.

### Cryptographic Modules

The cryptographic modules have multiple internal implementations to optimize for size and speed. The fast crypto option results in a larger library size, but runs the fastest; the small crypto implementation is optimized for small library size over speed. See the [SDK Structure](#sdk-structure) section to determine which option you have.

On most hardware architectures the fast crypto option is faster but larger than the small option. Some hardware architectures have multiple fast crypto implementations that can take advantage of optional features of the architecture. In FIPS 140-3 terminology, these are Processor Algorithm Accelerator (PAA) implementations. The accelerated implementation is always optional, so if the architecture feature is not present, the library still works.

#### Fast Crypto On x86\_64

The x86\_64 architecture has various optional feature sets that can be used to speed up many cryptographic algorithms. The architecture is designed to allow unprivileged code to probe the feature set, and the MTE cryptographic modules do this to automatically choose the optimal implementation without user intervention.

#### Fast Crypto On ARM64

The ARM64 architecture has many optional feature sets that can be used to speed up almost all of the cryptographic algorithms used in MTE. The architecture does not allow unprivileged code to probe the feature set availability; only privileged code like the operating system can do this. Unless disabled, MTE on ARM64 architectures automatically detects the feature set and enables the optimal implementation without user intervention. It is also possible to provide a callback to the initialization function that allows extended detection if the built-in detection fails or is disabled.

#### Fast Crypto On ESP32

The ESP32 microcontroller has AES and SHA peripheral modules, but there is no control over their use across tasks. The MTE library can be built to use the modules if you know there will not be any conflicts with other tasks. If there are conflicts, the MTE library must be built with the PAA support off.

#### Fast Crypto on PIC24

The PIC24 microcontroller has AES and CRC peripheral modules. The MTE library can be built to use the modules if you know there will not be any conflicts. If there are conflicts, the MTE library must be built with the PAA support off.

## SDK Structure

The name of the SDK package is structured to tell you how it was built. It is broken into parts separated by dashes using the following pattern:

`mte-OS-ARCH-RM-OPTS-ADDONS-LIC-PAA-FSC-VER.ext`

where the parts are:

|Part|Description|
|----|-----------|
|**mte**|This is the MTE SDK.|
|**OS**|The operating system. As a special case, iOS may have its own additional `-BC` suffix if bitcode is enabled.|
|**ARCH**|The hardware architecture.|
|**RM**|`R` = Release (built for speed), `M` = [Minimum size release](#minimum-size-release-build) (built for speed, but with the smallest code size).|
|**OPTS**|`RT` = runtime options. If buildtime options are selected, a dash-separated list of DRBG, verifiers, token size, cipher, and hash.|
|**ADDONS**|A dash-separated list of add-on libraries.|
|**LIC**|Present if this build requires a valid license key.|
|**PAA**|Present if this build requires PAA.|
|**FSC**|`FC` = Fast Crypto, `SC` = Small Crypto.|
|**VER**|The MTE SDK version.|
|**ext**|The extension appropriate for the package type.|

If your SDK contains `-Trial`, it is a trial mode build, which has no security due to its use of fake DRBG, cipher, and hash algorithms, and is not approved for any production use.

The SDK, when unpacked, contains a subset of the following (depending on the architecture):

|Folder|Description|
|------|-----------|
|demo|Demo apps.|
|docs|Documentation, including the release notes and developer guides.|
|include|C header files; also used by the C++, Go, Objective-C, and Swift language interfaces.|
|lib|MTE static, dynamic, and/or JNI libraries, in subfolders if multiple architectures are packaged together.|
|license|The end user license.|
|src|Language interface source code.|

### Demos
The demos directory in the SDK contains a `ReadMe.txt` overview of the available demos. Each demo contains a `ReadMe.txt` that explains how to assemble, build, and run the demo. The WASM demos contain both browser and Node.js demo and ReadMe files.

### Lib

The set of libraries in the SDK depends on the platform and add-ons chosen, so your SDK may only have a subset of these (and iOS is delivered as an XCFRAMEWORK instead). Following are the dynamic libraries:

|Library|Description|
|-------|-----------|
|**`mte`**|MTE dynamic library. This contains all core and add-on functions. If using a dynamic library (other than with a JVM language), this is the only library you need. Some language interfaces (like C# and Python) require you to use the dynamic library. Some language interfaces (like Go) do not allow you to use the dynamic library.|
|**`mtejni`**|MTE JNI dynamic library for loading in a JVM. If you are using a JVM language like Java, Kotlin, or Scala, this is the only library you need.|

On macOS, the dynamic library may trigger a security warning if downloaded over the internet. Use `xattr` to remove the extended attributes on the dynamic library to get rid of this warning.

Following are the static libraries, in order from no dependencies to dependent on earlier libraries:

|Library|Description|
|-------|-----------|
|**`mte_mteb`**|MTE base library. This contains core functions shared by all MTE parts and will always need to be linked in (last if ordering is required).|
|**`mte_mtee`**|MTE encoder library. This contains encoder-specific functions and will need to be linked in to any application that creates an encoder. It is dependent on `mte_mteb`.|
|**`mte_mted`**|MTE decoder library. This contains decoder-specific functions and will need to be linked in to any application that creates a decoder. It is dependent on `mte_mteb`.|
|**`mte_flen`**|Fixed-Length Add-On library. This contains the Fixed-Length Add-On encoder-specific functions and will need to be linked in to any application that creates a Fixed-Length Add-On encoder. It is dependent on `mte_mtee` and `mte_mteb`.|
|**`mte_jail`**| Jailbreak Add-On library. This contains the jailbreak detection support functions and will need to be linked in to any application that uses jailbreak detection or communicates with an app using jailbreak detection. It is dependent on `mte_mteb`.|
|**`mte_mkee`**|Managed-Key Encryption Add-On encoder library. This contains Managed-Key Encryption encoder-specific functions and will need to be linked in to any application that creates an Managed-Key Encryption encoder. It is dependent on `mte_mtee` and `mte_mteb`.|
|**`mte_mked`**|Managed-Key Encryption Add-On decoder library. This contains Managed-Key Encryption decoder-specific functions and will need to be linked in to any application that creates an Managed-Key Encryption decoder. It is dependent on `mte_mted` and `mte_mteb`.|
|**`mte_wrap`**|Wrapper library needed by some language interfaces. It is dependent on all of the above. Refer to the MTE language interface documentation for your language to determine if this library is required for your project.|

## Options

The MTE technology is designed to be very flexible to meet the needs of a wide range of use cases. To create an encoder or decoder, a set of options must be provided to control the behavior. Some options are specific to encoders, and some to decoders, but most are common to both. The common options must be the same for a decoder to successfully decode what the encoder has encoded. The following table lists the options and whether they apply to encoders, decoders, or both. Subsequent subsections go in to further detail on the options.

|Option|Encoder/Decoder|Description|
|------|---------------|-----------|
|**DRBG**|E/D|The deterministic random bit generator. The choice will determine the maximum [security strength](#terms-and-abbreviations). The choices are:<br/>**`None`**: No MTE-provided DRBG is selected. The SDK user must provide a DRBG via an MTE-defined callback interface. This is intended for highly specialized use cases, and the SDK user must ensure the DRBG is cryptographically secure.<br/>**`Increment`**: This is a fake DRBG which simply increments a counter to produce the next random value. **It offers no security and must never be used in anything other than a test environment.** This DRBG lets the SDK user purposely cause DRBG errors to allow for testing error handling that would be otherwise difficult to do with real DRBGs.<br/>**`CTR-AES-128-DF`**: NIST SP 800-90a DRBG based on AES-128 with a derivation function, allowing a wide range of [entropy](#terms-and-abbreviations), [nonce](#terms-and-abbreviations), and personalization inputs. It has 128-bit [security strength](#terms-and-abbreviations).<br/>**`CTR-AES-128-NODF`**: NIST SP 800-90a DRBG based on AES-128 with no derivation function, specifying a precise [entropy](#terms-and-abbreviations) and personalization size. A [nonce](#terms-and-abbreviations) is not allowed. It has 128-bit [security strength](#terms-and-abbreviations). It is slightly more efficient than the `-DF` algorithm, but harder to use. The Jailbreak Detection Add-On cannot be used with this DRBG since it does not allow a [nonce](#terms-and-abbreviations).<br/>**`CTR-AES-192-DF`**: NIST SP 800-90a DRBG based on AES-192 with a derivation function, allowing a wide range of [entropy](#terms-and-abbreviations), [nonce](#terms-and-abbreviations), and personalization inputs. It has 192-bit [security strength](#terms-and-abbreviations).<br/>**`CTR-AES-192-NODF`**: NIST SP 800-90a DRBG based on AES-192 with no derivation function, specifying a precise [entropy](#terms-and-abbreviations) and personalization size. A [nonce](#terms-and-abbreviations) is not allowed. It has 192-bit [security strength](#terms-and-abbreviations). It is slightly more efficient than the `-DF` algorithm, but harder to use. The Jailbreak Detection Add-On cannot be used with this DRBG since it does not allow a [nonce](#terms-and-abbreviations).<br/>**`CTR-AES-256-DF`**: NIST SP 800-90a DRBG based on AES-256 with a derivation function, allowing a wide range of [entropy](#terms-and-abbreviations), [nonce](#terms-and-abbreviations), and personalization inputs. It has 256-bit [security strength](#terms-and-abbreviations).<br/>**`CTR-AES-256-NODF`**: NIST SP 800-90a DRBG based on AES-256 with no derivation function, specifying a precise [entropy](#terms-and-abbreviations) and personalization size. A [nonce](#terms-and-abbreviations) is not allowed. It has 256-bit [security strength](#terms-and-abbreviations). It is slightly more efficient than the `-DF` algorithm, but harder to use. The Jailbreak Detection Add-On cannot be used with this DRBG since it does not allow a [nonce](#terms-and-abbreviations).<br/>**`HASH-SHA-1`**: NIST SP 800-90a DRBG based on SHA-1, allowing a wide range of [entropy](#terms-and-abbreviations), [nonce](#terms-and-abbreviations), and personalization inputs. It has 128-bit [security strength](#terms-and-abbreviations).<br/>**`HASH-SHA-256`**: NIST SP 800-90a DRBG based on SHA-256, allowing a wide range of [entropy](#terms-and-abbreviations), [nonce](#terms-and-abbreviations), and personalization inputs. It has 256-bit [security strength](#terms-and-abbreviations).<br/>**`HASH-SHA-512`**: NIST SP 800-90a DRBG based on SHA-512, allowing a wide range of [entropy](#terms-and-abbreviations), [nonce](#terms-and-abbreviations), and personalization inputs. It has at least 256-bit [security strength](#terms-and-abbreviations).|
|**Token Size**|E/D|The token size determines the resilience of the MTE technology. Smaller token sizes are less resilient and larger tokens are more resilient. The token size indicates the resulting encoded message size as a multiplier since each input byte is replaced by a token, so choosing tokens that are very large will result in much larger data to transmit. As a practical matter, the token size should not exceed the [security strength](#terms-and-abbreviations) of the DRBG chosen, as no additional security will result. The token size must be at least two bytes, though tokens that small offer lower authentication probabilities than larger tokens.|
|**Verifiers**|E/D|MTE offers a set of verifiers that augment the data being sent for additional authentication and resiliency. Any combination of verifiers (including none) may be used:<br/>**`CRC-32`**: A CRC-32 checksum is calculated on the input data (and timestamp if enabled) and sent with the encoded data. The decoder will compare the encoded checksum with the checksum after decoding to ensure accuracy.<br/>**`Timestamp`**: A timestamp is recorded by the encoder and sent with the encoded data. The decoder gets the timestamp at decode time and compares against the encode timestamp. If the time difference is not within the set window, a warning is returned.<br/>**`Sequencing`**: A sequence number is appended to each encoding. Depending on the sequencing window set in the decoder, the sequence number may be verified, missing messages may be skipped, or asynchronous processing of messages may occur. |
|**Timestamp Window**|D|The timestamp window is only used if the timestamp verifier is enabled. It determines the allowed difference in timestamps before a warning is issued.|
|**Sequencing Window**|D|The sequencing window is only used if the sequencing verifier is enabled. It determines the sequencing handling mode as well as the window within which catch-up is allowed to occur.|

### Choosing a DRBG

To choose a DRBG, first determine the required [security strength](#terms-and-abbreviations) of your system or application. There may be multiple choices for that [security strength](#terms-and-abbreviations). Next, determine if you will be using any add-ons that may help decide between competing choices. For example, if you are using Managed-Key Encryption with AES-256 and SHA-1, you may choose an AES-256 DRBG as well, which will help reduce code size compared to adding SHA-256 for a SHA-256 DRBG. Beyond those guidelines, it comes down to preferences for the organization.

If any add-ons will be used, there may be restrictions on which DRBGs can be used. For example, the Jailbreak Detection Add-On cannot use any of the `NODF` DRBGs because they do not accept a [nonce](#terms-and-abbreviations) value and the jailbreak/root detection works by mutating the [nonce](#terms-and-abbreviations).

### Choosing the Token Size

To choose the token size, first consider any limitations of the environment of the application or communication protocol. If there are no limitations, the best security will come from choosing a token size that matches that [security strength](#terms-and-abbreviations). For example, if the SHA-1 DRBG is chosen, 128-bit [security strength](#terms-and-abbreviations) is in effect, so 128/8 = 16 byte token size should be chosen. This will result in inherent authentication failing to detect tampering with a probability of approximately 1 in 2^120 per token. Choosing a smaller token size like 2 bytes would result in an inherent authentication failing to detect tampering with a probability of approximately 1 in 2^8 per token, which is clearly much easier to attack.

### Choosing the Verifiers

To choose verifiers, first determine if resources are constrained. If so, the overhead of verifiers may outweigh the potential benefits or not even be possible due to communication path limitations on size.

#### CRC-32 Verifier

The CRC-32 verifier should be enabled when additional authentication is desired. This is not cryptographic hashing but will detect most accidental corruption. Enabling this verifier adds 4 bytes multiplied by the token size to each message.

#### Timestamp Verifier

The timestamp verifier should be enabled when it is important to track elapsed time between encoding and decoding. This may be used in real-time systems. The timekeeping system on the encode and decode hardware must be relatively accurate for this to work properly, so the timestamp verifier should not be used if accurate time is not available.

The MTE technology does not define the meaning of the timestamp. It can be whatever resolution is appropriate for your system. The MTE technology does not retrieve the timestamp itself; rather a callback is invoked to allow the SDK user's code to get whatever timestamp it wants to use. The MTE technology simply records a 64-bit number during encoding and compares it during decoding. It is up to the SDK user to ensure that the encoder and decoder use the same resolution timestamp and set the timestamp window according to that resolution.

Enabling this verifier adds 8 bytes multiplied by the token size to each message.

#### Sequencing Verifier

The sequencing verifier should be enabled when lossy or out-of-order communication is possible. The verifier has three different modes of operation, determined by the sequence window setting in the decoder.

##### Verification-Only

In verification-only mode, which is enabled by setting the sequence window to `0`, the sequence number is checked before decoding is attempted and if it is not the expected number, no decode is attempted and an error is returned. This may be useful in cases where missing data is not acceptable (e.g., real-time commands to a robot) and needs to be detected.

##### Forward-Only

In forward-only mode, which is enabled by setting the sequence window to a positive number, the sequence number is checked before decoding and if it is ahead of the expected number and within the window, a catch-up algorithm is invoked to skip over the missing messages in order to successfully decode the current message. This may be useful in cases where missing data is acceptable (e.g., streaming video dropping some frames) and the desire is to just get what comes through.

If the catch-up still results in a decode failure, the state is rolled back as if the decode had not been attempted, with the assumption that the message was corrupt.

If the sequence number was outside the window, an error is returned before attempting to decode.

This mode requires that all messages are the same length, so MTE can know how to get back in sync. There are many ways to ensure this, including add-ons like Fixed-Length and Managed-Key Encryption, or the SDK user may have their own way of knowing the input is always the same length. The Fixed-Length Add-On always produces messages of the same length. The Managed-Key Encryption Add-On always produces fixed-length (for sequencing purposes) messages while at the same time allowing variable-length data.

##### Async

In async mode, which is enabled by setting the sequence window to a negative number, the sequence number is checked before decoding and if it is ahead of the expected number and within the window, a catch-up algorithm is invoked to skip ahead to the current message, and the state is always rolled back to allow messages to be decoded out of order, as long as they are within the window. This is useful in any situation where out-of-order processing may occur (e.g., a web server handling async requests from a browser).

If the sequence number was outside the window, an error is returned before attempting to decode.

This mode requires that all messages are the same length, so MTE can know how to get back in sync. There are many ways to ensure this, including add-ons like Fixed-Length and Managed-Key Encryption, or the SDK user may have their own way of knowing the input is always the same length. The Fixed-Length Add-On always produces messages of the same length. The Managed-Key Encryption Add-On always produces fixed-length (for sequencing purposes) messages while at the same time allowing variable-length data.

### Choosing the Timestamp Window

The timestamp window determines the maximum absolute value of the difference in timestamps if the [timestamp verifier](#timestamp-verifier) is enabled. The timestamp window must be at the same resolution as the timestamps, which are up to the SDK user to provide. It should be set to whatever is appropriate for the system or application. Even if the timestamp window is exceeded, the MTE decoder will return the decoded data. The timestamp window applies in both directions, so as long as the absolute value of the difference between the decode timestamp and encode timestamp is within the window, no warning is produced. This is to allow for inaccurate clock synchronization.

### Choosing the Sequencing Window

The sequence window determines how much effort MTE will put in to catching up if the [sequencing verifier](#sequencing-verifier) is enabled. The bigger the window, the more missing messages can be skipped. However, a very large window opens up the possibility of a denial of service (DOS) attack because the decoder could be expending large amounts of CPU time trying to catch up to an unreasonably large number of lost messages.

The sequence window is taken as a signed integer argument to various functions. Assuming the function argument is named `window`, it is interpreted as follows:

* If `window == 0`, [verification-only mode](#verification-only) is enabled. Any message out of sequence is flagged as an error before attempting decode.
* If `window > 0`, [forward-only mode](#forward-only) is enabled. Any message that comes out of sequence within `window` messages will be decoded and the state is advanced so the sequence number received is now the base sequence number; any messages that come in before the new base sequence number are flagged as an error before attempting to decode.
* If `-63 <= window <= -1`, [async mode](#async) is enabled. Any message that comes out of sequence within `abs(window)` messages will be decoded, but the state is not advanced, so an earlier message can be decoded later. If a message comes out of sequence more than `abs(window)` ahead but no more than `2*abs(window)` ahead, the message will be decoded and the state is advanced so the sequence number received is now only `abs(window)` ahead; any messages that come in before the base sequence number are flagged as an error before attempting to decode.

## Minimum Size Release Build

The minimum size release build (which should be combined with the small crypto option) is designed to provide the full functionality of MTE in the smallest library size possible. The MTE library is already quite small, but in specialized applications, resources may be extremely constrained. This is accomplished as follows:

* Where possible, using compiler options designed to optimize for small code size.
* Choosing smaller algorithm variations internally. Small crypto chooses the smallest algorithms for the underlying crypto; the minimum size release build chooses MTE-specific algorithms that are smaller.
* Omitting enumeration to/from string functions and associated strings. The string functions will return null, an error, or similar, depending on the language interface used.
* Omitting Base64 support. The Base64 functions will return an error.
* Omitting developer error checks. MTE error checks are still present.

The above strategies make the resulting libraries significantly smaller. It is believed that the extremely resource-constrained devices which require this type of build would not use the string and Base64 functionality due to their size and use cases, so we feel this is an acceptable tradeoff. In cases where the application would want Base64, it is probably already doing Base64 itself, and that can still be applied to the "raw" MTE output without adding code overhead.

The developer error checks are internal checks made that MTE is being used correctly. Once the application is properly written, these checks serve no purpose, so the minimum size release build omits them to save space. It is highly recommended that initial development is done with a normal release build to let the library detect usage problems, then switch to the minimum size release build for production use.

Note that the minimum size release build is fully compatible with any other MTE build (of the same major version), so in a client/server scenario where the client is a resource-constrained device and the server is a normal server-class computer, the client can use the minimum size release build while the server uses the more efficient but bigger release build.

## Status

Most of the key functions of MTE encoders and decoders return a status that indicates a successful operation or an error or warning of some kind. Each language interface has an enumeration (or similar) to represent the status values and there are helper functions that can convert to/from status enumerations and string values and descriptions. The enumeration and enumerator names vary slightly in each language interface due to language requirements and conventions, but the string names returned are consistent. It is extremely important to check the status returned from any function that can return a status. A complete loss of security is possible if the status is ignored or not handled properly. Many errors in encoding or decoding are often the result of not catching an earlier error, so checking all status codes can help debug those problems.

## Language Interfaces

The following language interfaces are available:

* [C](./lang/c/api.md)
* [C++](./lang/cpp/api.md)
* [C#](./lang/cs/api.md)
* [Go](./lang/go/api.md)
* [Java](./lang/java/api.md)
* [Objective-C](./lang/objc/api.md)
* [Python](./lang/py/api.md)
* [Swift](./lang/swift/api.md)
* [WASM/JS](./lang/wasm/api.md)
