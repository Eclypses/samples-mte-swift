# Swift Language Interface

## Overview

### Encoder

The basic flow for an encoder is to create it, use it to encode, and destroy it.

To create, use an `MteFlenEnc` initializer to create an encoder object and one of the `MteFlenEnc.instantiate()` overloads to instantiate it.

To encode, use any of the `MteFlenEnc.encode()` or `MteFlenEnc.encodeB64()` overloads.

To destroy, cause the `MteFlenEnc` deinitializer to be invoked (e.g., by removing the last strong reference to the object).

## Files

The MTE Fixed-Length Add-On uses the core source files (other than `MteEnc.swift`) documented in the [MTE Developer's Guide](../../../DevGuide.md), as well as the following:

|File|Description|
|----|-----------|
|[**`MteFlenEnc.swift`**](./MteFlenEnc.md)|MteFlenEnc class.|
