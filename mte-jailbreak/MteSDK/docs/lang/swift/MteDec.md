# `MteDec.swift`

## `MteDec` Initializer (default options)

```swift
public convenience init(_ tWindow: UInt64 = 0, _ sWindow: Int = 0) throws
```

Initializer using default options, [timestamp window](../../DevGuide.md#choosing-the-timestamp-window), and [sequence window](../../DevGuide.md#choosing-the-sequencing-window).

**`tWindow`**: the [timestamp window](../../DevGuide.md#choosing-the-timestamp-window). If the timestamp verifier is not enabled, this argument is ignored.\
**`sWindow`**: the [sequence window](../../DevGuide.md#choosing-the-sequencing-window). If the sequence verifier is not enabled, this argument is ignored.

## `MteDec` Initializer (runtime options)

```swift
public init(_ drbg: mte_drbgs, _ tokBytes: Int, _ verifiers: mte_verifiers, _ tWindow: UInt64, _ sWindow: Int) throws
```

Initializer taking the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm, token size in bytes, [verifiers](../c/mte_verifiers.md#mte_verifiers) algorithm, [timestamp window](../../DevGuide.md#choosing-the-timestamp-window), and [sequence window](../../DevGuide.md#choosing-the-sequencing-window).

**Buildtime options**: the `drbg`, `tokBytes`, and `verifiers` arguments must match the buildtime-chosen options.

**`drbg`**: the MTE-provided [DRBG](../c/mte_drbgs.md#mte_drbgs). Do not pass [`mte_drbgs_none`](../c/mte_drbgs.md#mtedrbgsnone).\
**`tokBytes`**: the token size in bytes.\
**`verifiers`**: the [verifiers](../c/mte_verifiers.md#mte_verifiers).\
**`tWindow`**: the [timestamp window](../../DevGuide.md#choosing-the-timestamp-window). If the timestamp verifier is not enabled, this argument is ignored.\
**`sWindow`**: the [sequence window](../../DevGuide.md#choosing-the-sequencing-window). If the sequence verifier is not enabled, this argument is ignored.

## `MteDec` Deinitializer

```swift
deinit
```

Deallocate. The [`uninstantiate()`](#mtedecuninstantiate) method is called.

## `MteDec.instantiate` (`[UInt8]`)

```swift
public func instantiate(_ ps: [UInt8]) -> mte_status
```

[Instantiates](../../DevGuide.md#terms-and-abbreviations) the decoder given the [personalization string](../../DevGuide.md#terms-and-abbreviations). Returns the [status](../c/mte_status.md#mte_status).

**`ps`**: [personalization string](../../DevGuide.md#terms-and-abbreviations).

## `MteDec.instantiate` (`String`)

```swift
public func instantiate(_ ps: String) -> mte_status
```

Calls [`instantiate()`](#mtedecinstantiate-uint8) with the string as an array of UTF-8 encoded bytes.

**`ps`**: [personalization string](../../DevGuide.md#terms-and-abbreviations).

## `MteDec.getReseedCounter`

```swift
public func getReseedCounter() -> UInt64
```

Returns the decoder's DRBG [reseed counter](../../DevGuide.md#terms-and-abbreviations).

## `MteDec.saveState`

```swift
public func saveState() -> [UInt8]?
```

Returns the saved state in raw form. Returns `nil` on error.

## `MteDec.saveStateB64`

```swift
public func saveStateB64() -> String?
```

Returns the saved state in [Base64](../../DevGuide.md#terms-and-abbreviations)-encoded form. Returns `nil` on error.

## `MteDec.restoreState`

```swift
public func restoreState(_ saved: [UInt8]) -> mte_status
```

Restores the decoder state from the given buffer in raw form. Returns the [status](../c/mte_status.md#mte_status).

**`saved`**: the buffer to restore the state from.

## `MteDec.restoreStateB64`

```swift
public func restoreStateB64(_ saved: String) -> mte_status
```

Restores the decoder state from the given buffer in [Base64](../../DevGuide.md#terms-and-abbreviations)-encoded form. Returns the [status](../c/mte_status.md#mte_status).

**`saved`**: the buffer to restore the state from.

## `MteDec.getBuffBytes`

```swift
public func getBuffBytes(_ encodedBytes: Int) -> Int
```

Returns the decode buffer size in bytes given the raw encoded message size in bytes.

**`encodedBytes`**: the encoded message size in bytes.

## `MteDec.getBuffBytesB64`

```swift
public func getBuffBytesB64(_ encodedBytes: Int) -> Int
```

Returns the decode buffer size in bytes given the [Base64](../../DevGuide.md#terms-and-abbreviations)-encoded message size in bytes.

**`encodedBytes`**: the encoded message size in bytes.

## `MteDec.decode`

```swift
public func decode(_ encoded: [UInt8]) -> (decoded: ArraySlice<UInt8>, status: mte_status)
```

Decodes the given raw encoded data. Returns the decoded data and [`status`](../c/mte_status.md#mte_status). The decoded version is valid only if `!`[`statusIsError`](./MteBase.md#mtebasestatusiserror)`(status)`.

**`encoded`**: the encoded data to decode.

## `MteDec.decodeB64`

```swift
public func decodeB64(_ encoded: String) -> (decoded: ArraySlice<UInt8>, status: mte_status)
```

Decodes the given [Base64](../../DevGuide.md#terms-and-abbreviations)-encoded encoded data. Returns the decoded data and [`status`](../c/mte_status.md#mte_status). The decoded version is valid only if `!`[`statusIsError`](./MteBase.md#mtebasestatusiserror)`(status)`.

**`encoded`**: the encoded data to decode.

## `MteDec.decodeStr`

```swift
public func decodeStr(_ encoded: [UInt8]) -> (str: String, status: mte_status)
```

Decodes the given raw encoded data. Returns the decoded data up to the length of decoding or first null byte, whichever comes first, as a string and the status. The decoded version is valid only if `!`[`statusIsError`](./MteBase.md#mtebasestatusiserror)`(status)`. For interoperability, it is assumed the string is UTF-8 encoded.

**`encoded`**: the encoded data to decode.

## `MteDec.decodeStrB64`

```swift
public func decodeStrB64(_ encoded: String) -> (str: String, status: mte_status)
```

Decodes the given [Base64](../../DevGuide.md#terms-and-abbreviations)-encoded encoded data. Returns the decoded data up to the length of decoding or first null byte, whichever comes first, as a string and the status. The decoded version is valid only if `!`[`statusIsError`](./MteBase.md#mtebasestatusiserror)`(status)`. For interoperability, it is assumed the string is UTF-8 encoded.

**`encoded`**: the encoded data to decode.

## `MteDec.decode` (external buffers)

```swift
public func decode(_ encoded: [UInt8], _ encOff: Int, _ encBytes: Int, _ decoded: inout [UInt8], _ decOff: Int) -> (decOff: Int, decBytes: Int, status: mte_status)
```

Decodes the given raw `encoded` version of the given length at the given offset to the given buffer at the given offset. Returns the offset of the decoded version, length of the decoded version, and [status](../c/mte_status.md#mte_status). The `decoded` buffer must have sufficient length remaining after the offset. Use [`getBuffBytes()`](#mtedecgetbuffbytes) to determine the buffer requirement.

**`encoded`**: buffer containing the encoded data.\
**`encOff`**: offset to the start of the encoded data.\
**`encBytes`**: length of the encoded data in bytes.\
**`decoded`**: buffer to hold the decoded data.\
**`decOff`**: the offset to the beginning of the usable buffer area.

## `MteDec.decodeB64` (external buffers)

```swift
public func decodeB64(_ encoded: [UInt8], _ encOff: Int, _ encBytes: Int, _ decoded: inout [UInt8], _ decOff: Int) -> (decOff: Int, decBytes: Int, status: mte_status)
```

Decodes the given [Base64](../../DevGuide.md#terms-and-abbreviations) `encoded` version of the given length at the given offset to the given buffer at the given offset. Returns the offset of the decoded version, length of the decoded version, and [status](../c/mte_status.md#mte_status). The `decoded` buffer must have sufficient length remaining after the offset. Use [`getBuffBytesB64()`](#mtedecgetbuffbytesb64) to determine the buffer requirement.

**`encoded`**: buffer containing the encoded data.\
**`encOff`**: offset to the start of the encoded data.\
**`encBytes`**: length of the encoded data in bytes.\
**`decoded`**: buffer to hold the decoded data.\
**`decOff`**: the offset to the beginning of the usable buffer area.

## `MteDec.getEncTs`

```swift
public func getEncTs() -> UInt64
```

Returns the encode timestamp from the most recent decode. If the [timestamp verifier](../../DevGuide.md#timestamp-verifier) is not enabled, `0` is returned.

## `MteDec.getDecTs`

```swift
public func getDecTs() -> UInt64
```

Returns the decode timestamp from the most recent decode. If the [timestamp verifier](../../DevGuide.md#timestamp-verifier) is not enabled, `0` is returned.

## `MteDec.getMsgSkipped`

```swift
public func getMsgSkipped() -> UInt32
```

If the [sequence window](../../DevGuide.md#choosing-the-sequencing-window) is non-negative, returns the messages skipped from the most recent decode; otherwise it returns the number of messages ahead of the base sequence from the most recent decode. If the [sequence verifier](../../DevGuide.md#sequencing-verifier) is not enabled, `0` is returned.

## `MteDec.uninstantiate`

```swift
public func uninstantiate() -> mte_status
```

[Uninstantiates](../../DevGuide.md#terms-and-abbreviations) the decoder. The decoder's [DRBG](../../DevGuide.md#terms-and-abbreviations) state is zeroized. Returns the [status](../c/mte_status.md#mte_status). The object must not be used until instantiated again.
