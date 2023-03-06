# `MteMkeDec.swift`

## `MteMkeDec` Initializer (default options)

```swift
public convenience init(_ tWindow: UInt64 = 0, _ sWindow: Int = 0) throws
```

Initializer using default options, timestamp window, and sequence window.

**`tWindow`**: the timestamp window. If the timestamp verifier is not enabled, this argument is ignored.\
**`sWindow`**: the sequence window. If the sequence verifier is not enabled, this argument is ignored.

## `MteMkeDec` Initializer (runtime options)

```swift
public init(_ drbg: mte_drbgs, _ tokBytes: Int, _ verifiers: mte_verifiers, _ cipher: mte_ciphers, _ hash: mte_hashes, _ tWindow: UInt64, _ sWindow: Int) throws
```

Initializer taking the DRBG algorithm, token size in bytes, verifiers algorithm, cipher algorithm, hash algorithm, timestamp window, and sequence window.

**Buildtime options**: the `drbg`, `tokBytes`, `byteValMin`, `byteValCount`, and `verifiers` arguments must match the buildtime-chosen options.

**`drbg`**: the MTE-provided DRBG. Do not pass `mte_drbgs_none`.\
**`tokBytes`**: the token size in bytes.\
**`verifiers`**: the verifiers.\
**`cipher`**: the MTE-provided cipher. Do not pass `mte_ciphers_none`.\
**`hash`**: the MTE-provided hash. Do not pass `mte_hashes_none`.\
**`tWindow`**: the timestamp window. If the timestamp verifier is not enabled, this argument is ignored.\
**`sWindow`**: the sequence window. If the sequence verifier is not enabled, this argument is ignored.

## `MteMkeDec` Deinitializer

```swift
deinit
```

Deallocate. The [`uninstantiate()`](#mtemkedecuninstantiate) method is called.

## `MteMkeDec.instantiate` (`[UInt8]`)

```swift
public func instantiate(_ ps: [UInt8]) -> mte_status
```

Instantiates the decoder given the personalization string. Returns the status.

**`ps`**: personalization string.

## `MteMkeDec.instantiate` (`String`)

```swift
public func instantiate(_ ps: String) -> mte_status
```

Calls [`instantiate()`](#mtemkedecinstantiate-uint8) with the string as an array of UTF-8 encoded bytes.

**`ps`**: personalization string.

## `MteMkeDec.getReseedCounter`

```swift
public func getReseedCounter() -> UInt64
```

Returns the decoder's DRBG reseed counter.

## `MteMkeDec.saveState`

```swift
public func saveState() -> [UInt8]?
```

Returns the saved state in raw form. Returns `nil` on error.

## `MteMkeDec.saveStateB64`

```swift
public func saveStateB64() -> String?
```

Returns the saved state in Base64-encoded form. Returns `nil` on error.

## `MteMkeDec.restoreState`

```swift
public func restoreState(_ saved: [UInt8]) -> mte_status
```

Restores the decoder state from the given buffer in raw form. Returns the status.

**`saved`**: the buffer to restore the state from.

## `MteMkeDec.restoreStateB64`

```swift
public func restoreStateB64(_ saved: String) -> mte_status
```

Restores the decoder state from the given buffer in Base64-encoded form. Returns the status.

**`saved`**: the buffer to restore the state from.

## `MteMkeDec.getBuffBytes`

```swift
public func getBuffBytes(_ encoded: [UInt8], _ encOff: Int, _ encBytes: Int) -> Int
```

Returns the decode buffer size in bytes given the raw encoded message size in bytes.

**`encoded`**: buffer containing the encoded message.\
**`encOff`**: offset to the start of the encoded message.\
**`encBytes`**: the encoded message size in bytes.

## `MteMkeDec.getBuffBytesB64`

```swift
public func getBuffBytesB64(_ encoded: [UInt8], _ encOff: Int, _ encBytes: Int) -> Int
```

Returns the decode buffer size in bytes given the [Base64](../../../../DevGuide.md#terms-and-abbreviations)-encoded message size in bytes.

**`encoded`**: buffer containing the encoded message.\
**`encOff`**: offset to the start of the encoded message.\
**`encBytes`**: the encoded message size in bytes.

## `MteMkeDec.decode`

```swift
public func decode(_ encoded: [UInt8]) -> (decoded: ArraySlice<UInt8>, status: mte_status)
```

Decodes the given raw encoded data. Returns the decoded data and `status`. The decoded version is valid only if `!statusIsError(status)`.

**`encoded`**: the encoded data to decode.

## `MteMkeDec.decodeB64`

```swift
public func decodeB64(_ encoded: String) -> (decoded: ArraySlice<UInt8>, status: mte_status)
```

Decodes the given Base64-encoded encoded data. Returns the decoded data and `status`. The decoded version is valid only if `!statusIsError(status)`.

**`encoded`**: the encoded data to decode.

## `MteMkeDec.decodeStr`

```swift
public func decodeStr(_ encoded: [UInt8]) -> (str: String, status: mte_status)
```

Decodes the given raw encoded data. Returns the decoded data up to the length of decoding or first null byte, whichever comes first, as a string and the status. The decoded version is valid only if `!statusIsError(status)`. For interoperability, it is assumed the string is UTF-8 encoded.

**`encoded`**: the encoded data to decode.

## `MteMkeDec.decodeStrB64`

```swift
public func decodeStrB64(_ encoded: String) -> (str: String, status: mte_status)
```

Decodes the given Base64-encoded encoded data. Returns the decoded data up to the length of decoding or first null byte, whichever comes first, as a string and the status. The decoded version is valid only if `!statusIsError(status)`. For interoperability, it is assumed the string is UTF-8 encoded.

**`encoded`**: the encoded data to decode.

## `MteMkeDec.startDecrypt`

```swift
public func startDecrypt() -> mte_status
```

Starts a [chunk-based](./api.md#chunk-decrypt) decryption session. Returns the status.

## `MteMkeDec.decryptChunk`

```swift
public func decryptChunk(_ encrypted: [UInt8]) -> (data: ArraySlice<UInt8>, status: mte_status)
```

Decrypts a chunk of data in a [chunk-based](./api.md#chunk-decrypt) decryption session. The `encrypted` data is used as input and some amount of decrypted data is returned along with the status. The amount decrypted may be less than the input size.

**`encrypted`**: the encrypted data to decrypt.

## `MteMkeDec.decryptChunk` (external buffers)

```swift
public func decryptChunk(_ encrypted: [UInt8], _ encOff: Int, _ encBytes: Int, _ decrypted: inout [UInt8], _ decOff: Int) -> Int
```

Decrypts a chunk of data starting at `encOff` and of length `encBytes` in the `encrypted` buffer in a [chunk-based](./api.md#chunk-decrypt) decryption session. Some decrypted data is written to the `decrypted` buffer starting at `decOff`. The amount decrypted may be less than the input size and is returned. Returns `-1` on error.

**`encrypted`**: the encrypted data to decrypt.\
**`encOff`**: offset to the start of the encrypted data.\
**`encBytes`**: length of the encrypted data in bytes.\
**`decrypted`**: buffer to hold decrypted data.\
**`decOff`**: offset to start writing decrypted data.

## `MteMkeDec.finishDecrypt`

```swift
public func finishDecrypt() -> (data: ArraySlice<UInt8>, status: mte_status)
```

Finishes the [chunk-based](./api.md#chunk-decrypt) decryption session. Returns the final decrypted data and status.

**`status`**: the status.

## `MteMkeDec.getEncTs`

```swift
public func getEncTs() -> UInt64
```

Returns the encode timestamp from the most recent decode. If the timestamp verifier is not enabled, `0` is returned.

## `MteMkeDec.getDecTs`

```swift
public func getDecTs() -> UInt64
```

Returns the decode timestamp from the most recent decode. If the timestamp verifier is not enabled, `0` is returned.

## `MteMkeDec.getMsgSkipped`

```swift
public func getMsgSkipped() -> UInt32
```

If the sequence window is non-negative, returns the messages skipped from the most recent decode; otherwise it returns the number of messages ahead of the base sequence from the most recent decode. If the sequence verifier is not enabled, `0` is returned.

## `MteMkeDec.uninstantiate`

```swift
public func uninstantiate() -> mte_status
```

Uninstantiates the decoder. The decoder's DRBG state is zeroized. Returns the status. The object must not be used until instantiated again.
