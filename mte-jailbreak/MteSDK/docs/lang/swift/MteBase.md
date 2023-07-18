# `MteBase.swift`

## `MteEntropyCallback.entropyCallback`

```swift
public protocol MteEntropyCallback {
  func entropyCallback(_ minEntropy: Int, _ minLength: Int, _ maxLength: UInt64, _ entropyInput: inout [UInt8], _ eiBytes: inout UInt64, _ entropyLong: inout UnsafeMutableRawPointer?) -> mte_status
}
```

Entropy callback. The behavior must match that of [`mte_drbg_get_entropy_input()`](../c/mte_drbg_defs.md#mtedrbggetentropyinput).

**`minEntropy`**: the minimum amount of [entropy](../../DevGuide.md#terms-and-abbreviations) the [DRBG](../c/mte_drbgs.md#mte_drbgs) requires (in bytes).\
**`minLength`**: the minimum length of the [entropy](../../DevGuide.md#terms-and-abbreviations) array (in bytes).\
**`maxLength`**: the maximum length of the [entropy](../../DevGuide.md#terms-and-abbreviations) array (in bytes).\
**`entropyInput`**: the [entropy](../../DevGuide.md#terms-and-abbreviations) input array. If at least `minLength` and no more than `eiBytes` is generated, copy the [entropy](../../DevGuide.md#terms-and-abbreviations) input to `entropyInput` and set `eiBytes` to the amount copied. If more than `eiBytes` is generated, set `entropyLong` to point at a buffer you provide which contains the [entropy](../../DevGuide.md#terms-and-abbreviations) array and set `eiBytes` to the length of [entropy](../../DevGuide.md#terms-and-abbreviations) in that array. It is also acceptable to set `entropyLong` to your buffer even if it is less than or equal to `eiBytes` instead of copying to the provided buffer. The provided array must remain valid until the instantiate call which triggered this callback completes. The [entropy](../../DevGuide.md#terms-and-abbreviations) input will be zeroized in the instantiate call when it is no longer needed.\
**`eiBytes`**: the [entropy](../../DevGuide.md#terms-and-abbreviations) size (in bytes). The caller sets `eiBytes` to the length of `entropyInput`. The callback must update `eiBytes` to the actual length of the [entropy](../../DevGuide.md#terms-and-abbreviations) array filled in or provided.
**`entropyLong`**: pointer to a provided buffer if the [entropy](../../DevGuide.md#terms-and-abbreviations) provided is longer than the provided buffer can hold.

## `MteNonceCallback.nonceCallback`

```swift
public protocol MteNonceCallback {
  func nonceCallback(_ minLength: Int, _ maxLength: Int, _ nonce: inout [UInt8], _ nBytes: inout Int)
}
```

Nonce callback. The behavior must match that of [`mte_drbg_get_nonce()`](../c/mte_drbg_defs.md#mtedrbggetnonce).

**`minLength`**: the minimum length of the [nonce](../../DevGuide.md#terms-and-abbreviations) array (in bytes).\
**`maxLength`**: the maximum length of the [nonce](../../DevGuide.md#terms-and-abbreviations) array (in bytes).\
**`nonce`**: the [nonce](../../DevGuide.md#terms-and-abbreviations) array provided by the caller. The provided array is of length `maxLength`. Copy your [nonce](../../DevGuide.md#terms-and-abbreviations) to this array and set `nBytes` to the amount copied.\
**`nBytes`**: the [nonce](../../DevGuide.md#terms-and-abbreviations) size (in bytes). The callback must update `nBytes` to the length of the [nonce](../../DevGuide.md#terms-and-abbreviations) array filled in.

## `MteTimestampCallback.timestampCallback`

```swift
public protocol MteTimestampCallback {
  func timestampCallback() -> UInt64
}
```

Timestamp callback. The behavior must match that of [`mte_verifier_get_timestamp64()`](../c/mte_verifier_defs.md#mteverifiergettimestamp64).

## `MteBase.getVersion`

```swift
public class func getVersion() -> String
```

Returns the MTE version number as a string in `major.minor.patch` format.

## `MteBase.getVersionMajor`

```swift
public class func getVersionMajor() -> Int
```

Returns the MTE major version number as an integer.

## `MteBase.getVersionMinor`

```swift
public class func getVersionMinor() -> Int
```

Returns the MTE minor version number as an integer.

## `MteBase.getVersionPatch`

```swift
public class func getVersionPatch() -> Int
```

Returns the MTE patch version number as an integer.

## `MteBase.initLicense`

```swift
public class func initLicense(_ company: String, _ license: String) -> Bool
```

Initializes with the company name and license code. Returns `true` if successful or `false` if not. If `true` is returned, MTE functions are usable; otherwise functions that return a [status](../c/mte_status.md#mte_status) will return an error status. This is only required for [licensed](../../DevGuide.md#sdk-structure) builds; for builds that don't require licensing, the arguments are ignored and success is always assumed.

**`company`**: the company name the license code is for.\
**`license`**: the license code.

## `MteBase.getStatusCount`

```swift
public class func getStatusCount() -> Int
```

Returns the count of status codes in the [`mte_status`](../c/mte_status.md#mte_status) enumeration.

## `MteBase.getStatusName`

```swift
public class func getStatusName(_ status: mte_status) -> String
```

Returns the enumeration name as a string for the given [status](../c/mte_status.md#mte_status).

**`status`**: the [status](../c/mte_status.md#mte_status) to return the name of.

## `MteBase.getStatusDescription`

```swift
public class func getStatusDescription(_ status: mte_status) -> String
```

Returns the description of the [status](../c/mte_status.md#mte_status).

**`status`**: the [status](../c/mte_status.md#mte_status) to return the description of.

## `MteBase.getStatusCode`

```swift
public class func getStatusCode(_ name: String) -> mte_status
```

Returns the [status](../c/mte_status.md#mte_status) enumerator for the given string name. If the name does not match a known name, a value equaling [`getStatusCount()`](#mtebasegetstatuscount) is returned.

**`name`**: the string name as returned by [`getStatusName()`](#mtebasegetstatusname).

## `MteBase.statusIsError`

```swift
public class func statusIsError(_ status: mte_status) -> Bool
```

Returns `false` if the [status](../c/mte_status.md#mte_status) code represents success or a warning; returns `true` if it is an error.

**`status`**: the [status](../c/mte_status.md#mte_status) to get the type of.

## `MteBase.hasRuntimeOpts`

```swift
public class func hasRuntimeOpts() -> Bool
```

Returns `true` if runtime options are available or `false` if not.

## `MteBase.getDefaultDrbg`

```swift
public class func getDefaultDrbg() -> mte_drbgs
```

Returns the default [DRBG](../c/mte_drbgs.md#mte_drbgs). If runtime options are not available, this is the only option available; otherwise it is a suitable default.

## `MteBase.getDefaultTokBytes`

```swift
public class func getDefaultTokBytes() -> Int
```

Returns the default token size. If runtime options are not available, this is the only option available; otherwise it is a suitable default.

## `MteBase.getDefaultVerifiers`

```swift
public class func getDefaultVerifiers() -> mte_verifiers
```

Returns the default [verifiers](../c/mte_verifiers.md#mte_verifiers). If runtime options are not available, this is the only option available; otherwise it is a suitable default.

## `MteBase.getDefaultCipher`

```swift
public class func getDefaultCipher() -> mte_ciphers
```

Returns the default [cipher](../c/mte_ciphers.md#mte_ciphers). If runtime options are not available, this is the only option available; otherwise it is a suitable default.

## `MteBase.getDefaultHash`

```swift
public class func getDefaultHash() -> mte_hashes
```

Returns the default [hash](../c/mte_hashes.md#mte_hashes). If runtime options are not available, this is the only option available; otherwise it is a suitable default.

## `MteBase.getDrbgsCount`

```swift
public class func getDrbgsCount() -> Int
```

Returns the count of DRBG algorithms in the [`mte_drbgs`](../c/mte_drbgs.md#mte_drbgs) enumeration.

**Buildtime options**: the count includes all DRBG choices, but only the buildtime-chosen option is usable.

## `MteBase.getDrbgsName`

```swift
public class func getDrbgsName(_ algo: mte_drbgs) -> String
```

Returns the enumeration name as a string for the given algorithm.

**Buildtime options**: returns an empty string for all choices except the buildtime-chosen option.

**`algo`**: the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm to return the name of.

## `MteBase.getDrbgsAlgo`

```swift
public class func getDrbgsAlgo(_ name: String) -> mte_drbgs
```

Returns the [DRBG](../c/mte_drbgs.md#mte_drbgs) enumerator for the given string name. If the name does not match a known name, a value equaling [`getDrbgsCount()`](#mtebasegetdrbgscount) is returned.

**Buildtime options**: the only known name is the buildtime-chosen option.

**`name`**: the string name as returned by [`getDrbgsName()`](#mtebasegetdrbgsname).

## `MteBase.getDrbgsSecStrengthBytes`

```swift
public class func getDrbgsSecStrengthBytes(_ algo: mte_drbgs) -> Int
```

Returns the [security strength](../../DevGuide.md#terms-and-abbreviations) (in bytes, not bits) for the given algorithm. This is a good token size to use.

**Buildtime options**: returns `0` for all choices except the buildtime-chosen option.

**`algo`**: the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm to return the [security strength](../../DevGuide.md#terms-and-abbreviations) of.

## `MteBase.getDrbgsPersonalMinBytes`

```swift
public class func getDrbgsPersonalMinBytes(_ algo: mte_drbgs) -> Int
```

Returns the minimum [personalization string](../../DevGuide.md#terms-and-abbreviations) length (in bytes) for the given algorithm.

**Buildtime options**: returns `0` for all choices except the buildtime-chosen option.

**`algo`**: the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm to return the minimum [personalization string](../../DevGuide.md#terms-and-abbreviations) length of.

## `MteBase.getDrbgsPersonalMaxBytes`

```swift
public class func getDrbgsPersonalMaxBytes(_ algo: mte_drbgs) -> UInt64
```

Returns the maximum [personalization string](../../DevGuide.md#terms-and-abbreviations) length (in bytes) for the given algorithm.

**Buildtime options**: returns `0` for all choices except the buildtime-chosen option.

**`algo`**: the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm to return the maximum [personalization string](../../DevGuide.md#terms-and-abbreviations) length of.

## `MteBase.getDrbgsEntropyMinBytes`

```swift
public class func getDrbgsEntropyMinBytes(_ algo: mte_drbgs) -> Int
```

Returns the minimum [entropy](../../DevGuide.md#terms-and-abbreviations) size (in bytes) for the given algorithm.

**Buildtime options**: returns `0` for all choices except the buildtime-chosen option.

**`algo`**: the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm to return the minimum [entropy](../../DevGuide.md#terms-and-abbreviations) length of.

## `MteBase.getDrbgsEntropyMaxBytes`

```swift
public class func getDrbgsEntropyMaxBytes(_ algo: mte_drbgs) -> UInt64
```

Returns the maximum [entropy](../../DevGuide.md#terms-and-abbreviations) size (in bytes) for the given algorithm.

**Buildtime options**: returns `0` for all choices except the buildtime-chosen option.

**`algo`**: the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm to return the maximum [entropy](../../DevGuide.md#terms-and-abbreviations) length of.

## `MteBase.getDrbgsNonceMinBytes`

```swift
public class func getDrbgsNonceMinBytes(_ algo: mte_drbgs) -> Int
```

Returns the minimum [nonce](../../DevGuide.md#terms-and-abbreviations) size (in bytes) for the given algorithm.

**Buildtime options**: returns `0` for all choices except the buildtime-chosen option.

**`algo`**: the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm to return the minimum [nonce](../../DevGuide.md#terms-and-abbreviations) length of.

## `MteBase.getDrbgsNonceMaxBytes`

```swift
public class func getDrbgsNonceMaxBytes(_ algo: mte_drbgs) -> Int
```

Returns the maximum [nonce](../../DevGuide.md#terms-and-abbreviations) size (in bytes) for the given algorithm.

**Buildtime options**: returns `0` for all choices except the buildtime-chosen option.

**`algo`**: the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm to return the maximum [nonce](../../DevGuide.md#terms-and-abbreviations) length of.

## `MteBase.getDrbgsReseedInterval`

```swift
public class func getDrbgsReseedInterval(_ algo: mte_drbgs) -> UInt64
```

Returns the [reseed interval](../../DevGuide.md#terms-and-abbreviations) for the given algorithm.

**Buildtime options**: returns `0` for all choices except the buildtime-chosen option.

**`algo`**: the [DRBG](../c/mte_drbgs.md#mte_drbgs) algorithm to return the [reseed interval](../../DevGuide.md#terms-and-abbreviations) of.

## `MteBase.setIncrInstError`

```swift
public class func setIncrInstError(_ flag: Bool)
```

Sets the [increment DRBG](../c/mte_drbgs.md#mtedrbgsincrement) to return an error during instantiation and uninstantiation (if `true`) or not (if `false`). This is useful for testing error handling. The flag is `false` until set with this.

**`flag`**: the desired error setting.

## `MteBase.setIncrGenError`

```swift
public class func setIncrGenError(_ flag: Bool, _ after: Int)
```

Sets the [increment DRBG](../c/mte_drbgs.md#mtedrbgsincrement) to produce an error after the given number of values have been generated (if flag is `true`) or turn off errors (if flag is `false`) other than the reseed error, which is always produced when the seed interval is reached. The flag is `false` until set with this.

**`flag`**: the desired error setting.\
**`after`**: the number of values to generate before triggering the error.

## `MteBase.getVerifiersCount`

```swift
public class func getVerifiersCount() -> Int
```

Returns the count of verifier algorithms in the [`mte_verifiers`](../c/mte_verifiers.md#mte_verifiers) enumeration.

**Buildtime options**: the count includes all verifier choices, but only the buildtime-chosen option is usable.

## `MteBase.getVerifiersName`

```swift
public class func getVerifiersName(_ algo: mte_verifiers) -> String
```

Returns the enumeration name as a string for the given algorithm.

**Buildtime options**: returns an empty string for all choices except the buildtime-chosen option.

**`algo`**: the [verifiers](../c/mte_verifiers.md#mte_verifiers) algorithm to return the name of.

## `MteBase.getVerifiersAlgo`

```swift
public class func getVerifiersAlgo(_ name: String) -> mte_verifiers
```

Returns the [verifiers](../c/mte_verifiers.md#mte_verifiers) enumerator for the given string name. If the name does not match a known name, a value equaling [`getVerifiersCount()`](#mtebasegetverifierscount) is returned.

**Buildtime options**: the only known name is the buildtime-chosen option.

**`name`**: the string name as returned by [`getVerifiersName()`](#mtebasegetverifiersname).

## `MteBase.getCiphersCount`

```swift
public class func getCiphersCount() -> Int
```

Returns the count of cipher algorithms in the [`mte_ciphers`](../c/mte_ciphers.md#mte_ciphers) enumeration.

**Buildtime options**: the count includes all cipher choices, but only the buildtime-chosen option is usable.

## `MteBase.getCiphersName`

```swift
public class func getCiphersName(_ algo: mte_ciphers) -> String
```

Returns the enumeration name as a string for the given algorithm.

**Buildtime options**: returns an empty string for all choices except the buildtime-chosen option.

**`algo`**: the [cipher](../c/mte_ciphers.md#mte_ciphers) algorithm to return the name of.

## `MteBase.getCiphersAlgo`

```swift
public class func getCiphersAlgo(_ name: String) -> mte_ciphers
```

Returns the [cipher](../c/mte_ciphers.md#mte_ciphers) enumerator for the given string name. If the name does not match a known name, a value equaling [`getCiphersCount()`](#mtebasegetcipherscount) is returned.

**Buildtime options**: the only known name is the buildtime-chosen option.

**`name`**: the string name as returned by [`getCiphersName()`](#mtebasegetciphersname).

## `MteBase.getCiphersBlockBytes`

```swift
public class func getCiphersBlockBytes(_ algo: mte_ciphers) -> Int
```

Returns the block size (in bytes) for the given algorithm.

**Buildtime options**: returns `0` for all choices except the buildtime-chosen option.

**`algo`**: the [cipher](../c/mte_ciphers.md#mte_ciphers) algorithm to return the block size of.

## `MteBase.getHashesCount`

```swift
public class func getHashesCount() -> Int
```

Returns the count of hash algorithms in the [`mte_hashes`](../c/mte_hashes.md#mte_hashes) enumeration.

**Buildtime options**: the count includes all hash choices, but only the buildtime-chosen option is usable.

## `MteBase.getHashesName`

```swift
public class func getHashesName(_ algo: mte_hashes) -> String
```

Returns the enumeration name as a string for the given algorithm.

**Buildtime options**: returns an empty string for all choices except the buildtime-chosen option.

**`algo`**: the [hash](../c/mte_hashes.md#mte_hashes) algorithm to return the name of.

## `MteBase.getHashesAlgo`

```swift
public class func getHashesAlgo(_ name: String) -> mte_hashes
```

Returns the [hash](../c/mte_hashes.md#mte_hashes) enumerator for the given string name. If the name does not match a known name, a value equaling [`getHashesCount()`](#mtebasegethashescount) is returned.

**Buildtime options**: the only known name is the buildtime-chosen option.

**`name`**: the string name as returned by [`getHashesName()`](#mtebasegethashesname).

## `MteBase` Initializer

```swift
public init()
```

Initializer. There is no reason to construct an object of this type directly; instead derived classes will be constructed.

## `MteBase.getDrbg`

```swift
public func getDrbg() -> mte_drbgs
```

Returns the [DRBG](../c/mte_drbgs.md#mte_drbgs) in use.

## `MteBase.getTokBytes`

```swift
public func getTokBytes() -> Int
```

Returns the token size in use.

## `MteBase.getVerifiers`

```swift
public func getVerifiers() -> mte_verifiers
```

Returns the [verifiers](../c/mte_verifiers.md#mte_verifiers) in use.

## `MteBase.getCipher`

```swift
public func getCipher() -> mte_ciphers
```

Returns the [cipher](../c/mte_ciphers.md#mte_ciphers) in use.

## `MteBase.getHash`

```swift
public func getHash() -> mte_hashes
```

Returns the [hash](../c/mte_hashes.md#mte_hashes) in use.

## `MteBase.setEntropyCallback`

```swift
public func setEntropyCallback(_ cb: MteEntropyCallback)
```

Sets the [entropy](../../DevGuide.md#terms-and-abbreviations) callback. If not `nil`, it is called to get [entropy](../../DevGuide.md#terms-and-abbreviations). If `nil`, the [entropy](../../DevGuide.md#terms-and-abbreviations) set with [`setEntropy()`](#mtebasesetentropy) is used.

## `MteBase.setEntropy`

```swift
public func setEntropy(_ entropyInput: [UInt8])
```

Sets the [entropy](../../DevGuide.md#terms-and-abbreviations) input value. This must be done before calling an instantiation method that will trigger the [entropy](../../DevGuide.md#terms-and-abbreviations) callback. The value must be the correct length for the [DRBG](../c/mte_drbgs.md#mte_drbgs).

The value is zeroized when used, so you must reset it before each instantiation.

If an [entropy](../../DevGuide.md#terms-and-abbreviations) callback is provided, this value is ignored. Defaults to `nil`.

**`entropyInput`**: the [entropy](../../DevGuide.md#terms-and-abbreviations).

## `MteBase.setNonceCallback`

```swift
public func setNonceCallback(_ cb: MteNonceCallback)
```

Sets the [nonce](../../DevGuide.md#terms-and-abbreviations) callback. If not `nil`, it is called to get the [nonce](../../DevGuide.md#terms-and-abbreviations). If `nil`, the [nonce](../../DevGuide.md#terms-and-abbreviations) set with [`setNonce()`](#mtebasesetnonce-uint8) is used.

## `MteBase.setNonce` (`[UInt8]`)

```swift
public func setNonce(_ nonce: [UInt8])
```

Sets the [nonce](../../DevGuide.md#terms-and-abbreviations) value. This must be done before calling an instantiation method that will trigger the [nonce](../../DevGuide.md#terms-and-abbreviations) callback. The value must be the correct length for the [DRBG](../c/mte_drbgs.md#mte_drbgs). If a [nonce](../../DevGuide.md#terms-and-abbreviations) callback is provided, this value is ignored. Defaults to `nil`.

**`nonce`**: the [nonce](../../DevGuide.md#terms-and-abbreviations).

## `MteBase.setNonce` (`UInt64`)

```swift
public func setNonce(_ nonce: UInt64)
```

Calls [`setNonce()`](#mtebasesetnonce-uint8) with the provided [nonce](../../DevGuide.md#terms-and-abbreviations) value converted to an array of bytes in little endian format. The array will be no less than the minimum length and no more than the maximum length the [DRBG](../c/mte_drbgs.md#mte_drbgs) requires; if the maximum is less than 8 bytes the least significant bytes are used; if the minimum is more than 8 bytes it will be padded with zeros up to the minimum length required. Note that this makes the [nonce](../../DevGuide.md#terms-and-abbreviations) non-approved in some configurations.

**`nonce`**: the [nonce](../../DevGuide.md#terms-and-abbreviations) integer.

## `MteBase.setTimestampCallback`

```swift
public func setTimestampCallback(_ cb: MteTimestampCallback)
```

Sets the timestampcallback. If not `nil`, it is called to get the timestamp. If `nil`, `0` is used.
