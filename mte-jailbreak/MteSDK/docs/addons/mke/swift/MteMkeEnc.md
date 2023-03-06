# `MteMkeEnc.swift`

## `MteMkeEnc` Initializer (default options)

```swift
public override convenience init() throws
```

Initializer using default options.

## `MteMkeEnc` Initializer (runtime options)

```swift
public init(_ drbg: mte_drbgs, _ tokBytes: Int, _ verifiers: mte_verifiers, _ cipher: mte_ciphers, _ hash: mte_hashes) throws
```

Initializer taking the DRBG algorithm, token size in bytes, verifiers algorithm, cipher algorithm, and hash algorithm.

**Buildtime options**: the `drbg`, `tokBytes`, `verifiers`, `cipher`, and `hash` arguments must match the buildtime-chosen options.

**`drbg`**: the MTE-provided DRBG. Do not pass `mte_drbgs_none`.\
**`tokBytes`**: the token size in bytes.\
**`verifiers`**: the verifiers.\
**`cipher`**: the MTE-provided cipher. Do not pass `mte_ciphers.mte_ciphers_none`.\
**`hash`**: the MTE-provided hash. Do not pass `mte_hashes.mte_hashes_none`.

## `MteMkeEnc` Deinitializer

```swift
deinit
```

Destructor. The [`uninstantiate()`](#mtemkeencuninstantiate) method is called.

## `MteMkeEnc.instantiate` (`[UInt8]`)

```swift
public func instantiate(_ ps: [UInt8]) -> mte_status
```

Instantiates the encoder given the personalization string. Returns the status.

**`ps`**: personalization string.
### `MteMkeEnc.instantiate` (`String`)

```swift
public func instantiate(_ ps: String) -> mte_status
```

Calls [`instantiate()`](#mtemkeencinstantiate-uint8) with the string as an array of UTF-8 encoded bytes.

**`ps`**: personalization string.

## `MteMkeEnc.getReseedCounter`

```swift
public func getReseedCounter() -> UInt64
```

Returns the encoder's DRBG reseed counter.

## `MteMkeEnc.saveState`

```swift
public func saveState() -> [UInt8]?
```

Returns the saved state in raw form. Returns `nil` on error.

## `MteMkeEnc.saveStateB64`

```swift
public func saveStateB64() -> String?
```

Returns the saved state in Base64-encoded form. Returns `nil` on error.

## `MteMkeEnc.restoreState`

```swift
public func restoreState(_ saved: [UInt8]) -> mte_status
```

Restores the encoder state from the given buffer in raw form. Returns the status.

**`saved`**: the buffer to restore the state from.

## `MteMkeEnc.restoreStateB64`

```swift
public func restoreStateB64(_ saved: String) -> mte_status
```

Restores the encoder state from the given buffer in Base64-encoded form. Returns the status.

**`saved`**: the buffer to restore the state from.

## `MteMkeEnc.getBuffBytes`

```swift
public func getBuffBytes(_ dataBytes: Int) -> Int
```

Returns the raw encode buffer size in bytes given the data size in bytes.

**`dataBytes`**: the data size in bytes.

## `MteMkeEnc.getBuffBytesB64`

```swift
public func getBuffBytesB64(_ dataBytes: Int) -> Int
```

Returns the Base64 encode buffer size in bytes given the data size in bytes.

**`dataBytes`**: the data size in bytes.

## `MteMkeEnc.encode` (`[UInt8]`)

```swift
public func encode(_ data: [UInt8]) -> (encoded: ArraySlice<UInt8>, status: mte_status)
```

Encodes the given data in raw form. Returns the encoded version and `status`. The encoded version is valid only if `status == mte_status_success`.

**`data`**: the data to encode.

## `MteMkeEnc.encodeB64` (`[UInt8]`)

```swift
public func encodeB64(_ data: [UInt8]) -> (encoded: String, status: mte_status)
```

Encodes the given data in Base64-encoded form. Returns the encoded version and `status`. The encoded version is valid only if `status == mte_status_success`.

**`data`**: the data to encode.

## `MteMkeEnc.encode` (`String`)

```swift
public func encode(_ str: String) -> (encoded: ArraySlice<UInt8>, status: mte_status)
```

Calls [`encode()`](#mtemkeencencode-uint8) with the string as an array of UTF-8 encoded bytes.

**`str`**: the string to encode.

## `MteMkeEnc.encodeB64` (`String`)

```swift
public func encodeB64(_ str: String) -> (encoded: String, status: mte_status)
```

Calls [`encodeB64()`](#mtemkeencencodeb64-uint8) with the string as an array of UTF-8 encoded bytes.

**`str`**: the string to encode.

## `MteMkeEnc.encode` (external buffers)

```swift
public func encode(_ data: [UInt8], _ dataOff: Int, _ dataBytes: Int, _ encoded: inout [UInt8], _ encOff: Int) -> (encOff: Int, encBytes: Int, status: mte_status)
```

Encodes the given data of the given length at the given offset to the given buffer at the given offset in raw form. Returns the offset of the encoded version, length of the encoded version, and status. The `encoded` buffer must have sufficient length remaining after the offset. Use [`getBuffBytes()`](#mtemkeencgetbuffbytes) to determine the buffer requirement.

**`data`**: buffer containing the data.\
**`dataOff`**: offset to the start of the data.\
**`dataBytes`**: length of the data in bytes.\
**`encoded`**: buffer to hold the encoded data.\
**`encOff`**: the offset to the beginning of the usable buffer area.

## `MteMkeEnc.encodeB64` (external buffers)

```swift
public func encodeB64(_ data: [UInt8], _ dataOff: Int, _ dataBytes: Int, _ encoded: inout [UInt8], _ encOff: Int) -> (encOff: Int, encBytes: Int, status: mte_status)
```

Encodes the given data of the given length at the given offset to the given buffer at the given offset in Base64-encoded form. Returns the offset of the encoded version, length of the encoded version, and status. The `encoded` buffer must have sufficient length remaining after the offset. Use [`getBuffBytesB64()`](#mtemkeencgetbuffbytesb64) to determine the buffer requirement.

**`data`**: buffer containing the data.\
**`dataOff`**: offset to the start of the data.\
**`dataBytes`**: length of the data in bytes.\
**`encoded`**: buffer to hold the encoded data.\
**`encOff`**: the offset to the beginning of the usable buffer area.

## `MteMkeEnc.encryptFinishBytes`

```swift
public func encryptFinishBytes() -> Int
```

Returns the length of the result [`finishEncrypt()`](#mtemkeencfinishencrypt) will produce. Use this if you need to know that size before you can call it.

## `MteMkeEnc.startEncrypt`

```swift
public func startEncrypt() -> mte_status
```

Starts a [chunk-based](./api.md#chunk-encrypt) encryption session. Returns the status.

## `MteMkeEnc.encryptChunk`

```swift
public func encryptChunk(_ data: inout [UInt8]) -> mte_status
```

Encrypts a chunk of data in a [chunk-based](./api.md#chunk-encrypt) encryption session. The `data` is encrypted in place. The `data.count` must be a multiple of the cipher block size in the chosen mode of operation. Returns the status.

**`data`**: the data to encrypt.

## `MteMkeEnc.encryptChunk` (partial)

```swift
public func encryptChunk(_ data: inout [UInt8], _ off: Int, _ bytes: Int) -> mte_status
```

Encrypts a chunk of data in a [chunk-based](./api.md#chunk-encrypt) encryption session. The `data` is encrypted in place. The `data.count` must be a multiple of the cipher block size in the chosen mode of operation. Returns the status.

**`data`**: the data to encrypt.\
**`off`**: offset to the start of the data to encrypt.\
**`bytes`**: length of the data to encrypt in bytes.

## `MteMkeEnc.finishEncrypt`

```swift
public func finishEncrypt() -> (encoded: ArraySlice<UInt8>, status: mte_status)
```

Finishes the [chunk-based](./api.md#chunk-encrypt) encryption session. Returns the tokenized hash and status.

## `MteMkeEnc.uninstantiate`

```swift
public func uninstantiate() -> mte_status
```

Uninstantiates the encoder. The encoder's DRBG state is zeroized. Returns the status. The object must not be used until instantiated again.
