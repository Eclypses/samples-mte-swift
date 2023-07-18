# MTE Managed-Key Encryption Add-On Developer's Guide

***MTE Version 3.0***

## Introduction

The Managed-Key Encryption Add-On replaces the core encoder and decoder, which only do tokenization, with an encoder and decoder that combine standard encryption with tokenization. This allows much larger data to take advantage of the MTE technology without significantly increasing the data size.

Using the core MTE technology, the Managed-Key Encryption Add-On can generate a unique random encryption key for each piece of data, encrypt the data, then decrypt it without ever transmitting or sharing that key in any way. That key is then discarded and the next piece of data will use a new, unrelated key. The encrypted data is hashed and that hash is tokenized with the core MTE algorithm to provide a superior level of authentication.

The Managed-Key Encryption Add-On can be used in two different ways. The first, most common use is encoder/decoder mode. The other way to use the add-on is in chunk encrypt/decrypt mode. Both are described below. Regardless of which mode is used, the normal instantiation process must occur before using the encoder or decoder. The modes are not compatible with each other, so an encode must pair with a decode and a chunk encrypt must pair with a chunk decrypt.

## Encoder/Decoder Mode

This mode uses the Managed-Key Encryption Add-On just like a core encoder and decoder. The interface is almost identical to the core encoder and decoder interface. An encoder calls an encode function to encode an input and a decoder calls a decode function to decode that encoded version. Each encode call will use a different encryption key.

The encoder automatically pads inputs as necessary for the size, cipher, and mode of operation in use. The decoder automatically removes any added padding.

## Chunk Mode

This mode uses the Managed-Key Encryption Add-On to encrypt very large pieces of data that are not suitable for a single encode operation. The interface allows the data to be streamed through in chunks to keep memory usage reasonable. The interface requires a call to start a new chunk session, calls to encrypt/decrypt each chunk, then a call to finalize the session, which adds a tokenized hash for authentication. Each new session will use a different encryption key.

### Chunk Encrypt Process

1. Start the chunk session.
2. Encrypt each chunk. The chunks must be a multiple of the cipher's block size for the chosen mode of operation.
3. Finish the chunk session. Ensure a successful status.

Steps 2 and 3 produce outputs (the encrypted data and the tokenized hash with optional verifiers). The outputs from these steps, concatenated together in order, are the full result of the chunked encryption process. This concatenated output must be fed in full to the chunk decrypt process to succeed. A common mistake is to neglect to include the result of step 3 as part of the result.

### Chunk Decrypt Process

1. Start the chunk session.
2. Decrypt each chunk. The chunks can be any size, unlike the encryption process. The chunks must include all of the encrypted data in order as well as the tokenized hash produced in step 3 of the chunk encrypt process.
3. Finish the chunk session. Check the status to make sure the result is authentic and that any optional verifiers did not indicate problems.

After step 3, the normal informational functions like retrieving the timestamps (if the timestamp verifier is enabled) are available, just like in normal encoder/decoder mode.

# Terms and Abbreviations

Refer to [the main developer's guide](../DevGuide.md#terms-and-abbreviations).

# Prerequisites

Refer to [the main developer's guide](../DevGuide.md#prerequisites).

# Caveats

Refer to [the main developer's guide](../DevGuide.md#caveats).

# Architecture

Refer to [the main developer's guide](../DevGuide.md#architecture).

# SDK Structure

Refer to [the main developer's guide](../DevGuide.md#sdk-structure).

# Options

Refer to [the main developer's guide](../DevGuide.md#options). The Managed-Key Encryption Add-On adds some additional options. The options must be the same for a decoder to successfully decode what the encoder has encoded. The following table lists the options the Managed-Key Encryption Add-On adds to the core and whether they apply to encoders, decoders, or both. Subsequent subsections go in to further detail on the options.

|Option|Encoder/Decoder|Description|
|------|---------------|-----------|
|**Cipher**|E/D|The cipher. The choice will determine the security strength. The choices are:<br/>**`None`**: No MTE-provided cipher is selected. The SDK user must provide a cipher via an MTE-defined callback interface. This is intended for highly specialized use cases, and the SDK user must ensure the cipher is cryptographically secure.<br />**`AES-128-CBC`**: AES-128 using the Cipher Block Chaining mode of operation.<br />**`AES-128-CTR`**: AES-128 using the Counter mode of operation.<br />**`AES-128-ECB`**: AES-128 using the Electronic Code Book mode of operation.<br />**`AES-192-CBC`**: AES-192 using the Cipher Block Chaining mode of operation.<br />**`AES-192-CTR`**: AES-192 using the Counter mode of operation.<br />**`AES-192-ECB`**: AES-192 using the Electronic Code Book mode of operation.<br />**`AES-256-CBC`**: AES-256 using the Cipher Block Chaining mode of operation.<br />**`AES-256-CTR`**: AES-256 using the Counter mode of operation.<br/>**`AES-256-ECB`**: AES-256 using the Electronic Code Book mode of operation.|
|**Hash**|E/D|The hash. The choice will determine the authentication strength. The choices are:<br/>**`None`**: No MTE-provided hash is selected. The SDK user must provide a hash via an MTE-defined callback interface. This is intended for highly specialized use cases, and the SDK user must ensure the hash is cryptographically secure.<br />**`CRC-32`**: CRC-32. This is not cryptographically secure.<br />**`SHA-1`**: SHA-1. This is no longer considered cryptographically secure for hashing.<br />**`SHA-256`**: SHA-256.<br />**`SHA-512`**: SHA-512.|

## Choosing a Cipher

To choose a cipher, first determine the required security strength of your system or application. There may be multiple choices for that security strength. Next, determine if the DRBG is cipher-based and can use the same cipher as that may help decide between competing choices. For example, if you are using an AES-256 DRBG, you could choose any of the AES-256 options for the cipher, which will help reduce code size.

Next you need to determine the mode of operation to use with the cipher. Note that some modes of operation have strict limitations (e.g., ECB should only be used for encrypting a single block of data). If you are using chunk mode, you will be required to ensure the data is chunked to a multiple of the block size, which may necessitate a padding algorithm. If not using chunk mode, the Managed-Key Encryption Add-On will pad inputs if necessary, but is able to remove the padding, so the process is transparent.

Beyond those guidelines, it comes down to preferences for the organization.

## Choosing a Hash

To choose a hash, first determine the required security strength of your system or application. There may be multiple choices for that security strength. Next, determine if the DRBG is hash-based and can use the same hash as that may help decide between competing choices. For example, if you are using a SHA-256 DRBG, you could choose SHA-256 for the hash, which will help reduce code size.

Beyond those guidelines, it comes down to preferences for the organization.

# Status

Refer to [the main developer's guide](../DevGuide.md#status).

## Language Interfaces

The following language interfaces are available:

* [C](./mke/c/api.md)
* [C++](./mke/cpp/api.md)
* [C#](./mke/cs/api.md)
* [Go](./mke/go/api.md)
* [Java](./mke/java/api.md)
* [Objective-C](./mke/objc/api.md)
* [Python](./mke/py/api.md)
* [Swift](./mke/swift/api.md)
* [WASM/JS](./mke/wasm/api.md)
