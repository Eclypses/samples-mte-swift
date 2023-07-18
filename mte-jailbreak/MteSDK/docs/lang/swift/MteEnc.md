# `MteEnc.swift`

## `MteEnc` Initializer (default options)

```swift
public override convenience init() throws
```

Initializer using default options.

## `MteEnc` Initializer (runtime options)

```swift
public init(_ drbg: mte_drbgs, _ tokBytes: Int, _ verifiers: mte_verifiers) throws
```

Initializer taking the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm, token size in bytes, input byte range, and [verifiers](../c/mte_verifiers.md#mte_verifiers) algorithm.

**Buildtime options**: the `drbg`, `tokBytes`, and `verifiers` arguments must match the buildtime-chosen options.

**`drbg`**: the MTE-provided [DRBG](../c/mte_drbgs.md#mte_drbgs). Do not pass [`mte_drbgs_none`](../c/mte_drbgs.md#mtedrbgsnone).\
**`tokBytes`**: the token size in bytes.\
**`verifiers`**: the [verifiers](../c/mte_verifiers.md#mte_verifiers).

## `MteEnc` Deinitializer

```swift
deinit
```

Destructor. The [`uninstantiate()`](#mteencuninstantiate) method is called.

## `MteEnc.instantiate` (`[UInt8]`)

```swift
public func instantiate(_ ps: [UInt8]) -> mte_status
```

[Instantiates](../../DevGuide.md#terms-and-abbreviations) the encoder given the [personalization string](../../DevGuide.md#terms-and-abbreviations). Returns the [status](../c/mte_status.md#mte_status).

**`ps`**: [personalization string](../../DevGuide.md#terms-and-abbreviations).

## `MteEnc.instantiate` (`String`)

```swift
public func instantiate(_ ps: String) -> mte_status
```

Calls [`instantiate()`](#mteencinstantiate-uint8) with the string as an array of UTF-8 encoded bytes.

**`ps`**: [personalization string](../../DevGuide.md#terms-and-abbreviations).

## `MteEnc.getReseedCounter`

```swift
public func getReseedCounter() -> UInt64
```

Returns the encoder's DRBG [reseed counter](../../DevGuide.md#terms-and-abbreviations).

## `MteEnc.saveState`

```swift
public func saveState() -> [UInt8]?
```

Returns the saved state in raw form. Returns `nil` on error.

## `MteEnc.saveStateB64`

```swift
public func saveStateB64() -> String?
```

Returns the saved state in [Base64](../../DevGuide.md#terms-and-abbreviations)-encoded form. Returns `nil` on error.

## `MteEnc.restoreState`

```swift
public func restoreState(_ saved: [UInt8])
```

Restores the encoder state from the given buffer in raw form. Returns the [status](../c/mte_status.md#mte_status).

**`saved`**: the buffer to restore the state from.

## `MteEnc.restoreStateB64`

```swift
public func restoreStateB64(_ saved: String)
```

Restores the encoder state from the given buffer in [Base64](../../DevGuide.md#terms-and-abbreviations)-encoded form. Returns the [status](../c/mte_status.md#mte_status).

**`saved`**: the buffer to restore the state from.

## `MteEnc.getBuffBytes`

```swift
public func getBuffBytes(_ dataBytes: Int) -> Int
```

Returns the raw encode buffer size in bytes given the data size in bytes.

**`dataBytes`**: the data size in bytes.

## `MteEnc.getBuffBytesB64`

```swift
public func getBuffBytesB64(_ dataBytes: Int) -> Int
```

Returns the [Base64](../../DevGuide.md#terms-and-abbreviations) encode buffer size in bytes given the data size in bytes.

**`dataBytes`**: the data size in bytes.

## `MteEnc.encode` (`[UInt8]`)

```swift
public func encode(_ data: [UInt8]) -> (encoded: ArraySlice<UInt8>, status: mte_status)
```

Encodes the given data in raw form. Returns the encoded version and [`status`](../c/mte_status.md#mte_status). The encoded version is valid only if `status == `[`mte_status_success`](../c/mte_status.md#mtestatussuccess).

**`data`**: the data to encode.

## `MteEnc.encodeB64` (`[UInt8]`)

```swift
public func encodeB64(_ data: [UInt8]) -> (encoded: String, status: mte_status)
```

Encodes the given data in [Base64](../../DevGuide.md#terms-and-abbreviations)-encoded form. Returns the encoded version and [`status`](../c/mte_status.md#mte_status). The encoded version is valid only if `status == `[`mte_status_success`](../c/mte_status.md#mtestatussuccess).

**`data`**: the data to encode.

## `MteEnc.encode` (`String`)

```swift
public func encode(_ str: String) -> (encoded: ArraySlice<UInt8>, status: mte_status)
```

Calls [`encode()`](#mteencencode-uint8) with the string as an array of UTF-8 encoded bytes.

**`str`**: the string to encode.

## `MteEnc.encodeB64` (`String`)

```swift
public func encodeB64(_ str: String) -> (encoded: String, status: mte_status)
```

Calls [`encodeB64()`](#mteencencodeb64-uint8) with the string as an array of UTF-8 encoded bytes.

**`str`**: the string to encode.

## `MteEnc.encode` (external buffers)

```swift
public func encode(_ data: [UInt8], _ dataOff: Int, _ dataBytes: Int, _ encoded: inout [UInt8], _ encOff: Int) -> (encOff: Int, encBytes: Int, status: mte_status)
```

Encodes the given data of the given length at the given offset to the given buffer at the given offset in raw form. Returns the offset of the encoded version, length of the encoded version, and status. The `encoded` buffer must have sufficient length remaining after the offset. Use [`getBuffBytes()`](#mteencgetbuffbytes) to determine the buffer requirement.

**`data`**: buffer containing the data.\
**`dataOff`**: offset to the start of the data.\
**`dataBytes`**: length of the data in bytes.\
**`encoded`**: buffer to hold the encoded data.\
**`encOff`**: the offset to the beginning of the usable buffer area.

## `MteEnc.encodeB64` (external buffers)

```swift
public func encodeB64(_ data: [UInt8], _ dataOff: Int, _ dataBytes: Int, _ encoded: inout [UInt8], _ encOff: Int) -> (encOff: Int, encBytes: Int, status: mte_status)
```

Encodes the given data of the given length at the given offset to the given buffer at the given offset in Base64-encoded form. Returns the offset of the encoded version, length of the encoded version, and status. The `encoded` buffer must have sufficient length remaining after the offset. Use [`getBuffBytesB64()`](#mteencgetbuffbytesb64) to determine the buffer requirement.

**`data`**: buffer containing the data.\
**`dataOff`**: offset to the start of the data.\
**`dataBytes`**: length of the data in bytes.\
**`encoded`**: buffer to hold the encoded data.\
**`encOff`**: the offset to the beginning of the usable buffer area.

## `MteEnc.uninstantiate`

```swift
public func uninstantiate() -> mte_status
```

[Uninstantiates](../../DevGuide.md#terms-and-abbreviations) the encoder. The encoder's [DRBG](../../DevGuide.md#terms-and-abbreviations) state is zeroized. Returns the [status](../c/mte_status.md#mte_status). The object must not be used until instantiated again.
