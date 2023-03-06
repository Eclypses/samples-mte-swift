# Swift Language Interface

The Swift Language Interface wraps the C API to provide an object-oriented Swift interface and handle memory management. The C APIs are fully wrapped, so there is no need to use them directly. Only the C enumerations are reused without wrapping.

The [`mte_wrap`](../../DevGuide.md#lib) static library is required to use this language interface.

## Overview

### Encoder

The basic flow for an encoder is to create it, use it to encode, and destroy it.

To create, use an `MteEnc` initializer to create an encoder object and one of the `MteEnc.instantiate()` overloads to instantiate it.

To encode, use any of the `MteEnc.encode()` or `MteEnc.encodeB64()` overloads.

To destroy, cause the `MteEnc` deinitializer to be invoked (e.g., by removing the last strong reference to the object).

### Decoder

The basic flow for a decoder is to create it, use it to decode, get additional information about decoding, and destroy it.

To create, use an `MteDec` initializer to create a decoder object and one of the `MteDec.instantiate()` overloads to instantiate it.

To decode, use `MteDec.decode()`, `MteDec.decodeB64()`, `MteDec.decodeStr()`, or `MteDec.decodeStrB64()`.

To get additional information, use `MteDec.getEncTs()`, `MteDec.getDecTs()`, and `MteDec.getMsgSkipped()`, depending on which verifiers are enabled.

To destroy, cause the `MteDec` deinitializer to be invoked (e.g., by removing the last strong reference to the object).

## Files

The Swift Language Interface consists of source files defining the classes and methods and a bridging header. There are several source files your application may need to include, depending on which functionalities you are using. The Swift Language Interface is distributed as source, and is not compiled as part of any MTE library. The main source files are:

|File|Description|
|----|-----------|
|[**`MteBase.swift`**](./MteBase.md)|MteBase class.|
|[**`MteDec.swift`**](./MteDec.md)|MteDec class.|
|[**`MteEnc.swift`**](./MteEnc.md)|MteEnc class.|

The bridging header:

|File|Description|
|----|-----------|
|**`Bridging-Header.h`**|A template bridging header. Use this as a guide to determine what to add to your bridging header. It cannot be used directly - see the comments in the file for how to use it.|
