# Swift Language Interface

## Overview

### Encoder

The basic flow for an encoder is to create it, use it to encode, and destroy it.

To create, use an `MteMkeEnc` initializer to create an encoder object and one of the `MteMkeEnc.instantiate()` overloads to instantiate it.

To encode, use any of the `MteMkeEnc.encode()` or `MteMkeEnc.encodeB64()` overloads.

To destroy, cause the `MteMkeEnc` deinitializer to be invoked (e.g., by removing the last strong reference to the object).

### Decoder

The basic flow for a decoder is to create it, use it to decode, get additional information about decoding, and destroy it.

To create, use an `MteMkeDec` initializer to create a decoder object and one of the `MteMkeDec.instantiate()` overloads to instantiate it.

To decode, use `MteMkeDec.decode()`, `MteMkeDec.decodeB64()`, `MteMkeDec.decodeStr()`, or `MteMkeDec.decodeStrB64()`.

To get additional information, use `MteMkeDec.getEncTs()`, `MteMkeDec.getDecTs()`, and `MteMkeDec.getMsgSkipped()`, depending on which verifiers are enabled.

To destroy, cause the `MteMkeDec` deinitializer to be invoked (e.g., by removing the last strong reference to the object).

### Chunk Encrypt

The chunk encrypt follows the flow of an encoder, but instead of using an encode method, use `MteMkeEnc.startEncrypt()` to start a chunk session, `MteMkeEnc.encryptChunk()` repeatedly to encrypt each chunk, then `MteMkeEnc.finishEncrypt()` to finish the session.

### Chunk Decrypt

The chunk encrypt follows the flow of a decoder, but instead of using a decode method, use `MteMkeDec.startDecrypt()` to start a chunk session, `MteMkeDec.decryptChunk()` repeatedly to decrypt each chunk, then `MteMkeEnc.finishDecrypt()` to finish the session.

## Files

The MTE Managed-Key Encryption Add-On uses the core source files (other than `MteEnc.swift` and `MteDec.swift`) documented in the [MTE Developer's Guide](../../../DevGuide.md), as well as the following:

|File|Description|
|----|-----------|
|[**`MteMkeDec.swift`**](./MteMkeDec.md)|MteMkeDec class.|
|[**`MteMkeEnc.swift`**](./MteMkeEnc.md)|MteMkeEnc class.|
