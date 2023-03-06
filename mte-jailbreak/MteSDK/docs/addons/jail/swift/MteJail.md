# `MteJail.swift`

## `MteJail.Algo`

### `MteJail.Algo.aNone`

No choice made. No nonce mutation will be performed.

### `MteJail.Algo.aAndroidArm32Dev`

Android ARM32 device.

### `MteJail.Algo.aAndroidArm64Dev`

Android ARM64 device.

### `MteJail.Algo.aAndroidX86Sim`

Android x86 simulator.

### `MteJail.Algo.aAndroidX86_64Sim`

Android x86\_64 simulator.

### `MteJail.Algo.aIosArm64Dev`

iOS ARM64 device.

### `MteJail.Algo.aIosX86_64Sim`

iOS x86\_64 simulator.

## `MteJail.setAlgo`

```swift
public func setAlgo(_ algo: MteJail.Algo)
```

Sets the [jailbreak detection algorithm](#mtejailalgo) to pair with. Defaults to [`MteJail.Algo.aIosX86_64Sim`](#mtejailalgoaiosx8664sim) when building for the x86\_64 simulator target, [`MteJail.Algo.aIosArm64Dev`](#mtejailalgoaiosarm64dev) when building for the ARM64 device target, or [`MteJail.Algo.aNone`](#mtejailalgoanone) otherwise.

**`algo`**: the [jailbreak detection algorithm](#mtejailalgo).

## `MteJail.setNonceSeed`

```swift
public func setNonceSeed(_ seed: UInt64)
```

Sets the nonce seed.

**`seed`**: the nonce seed.

## `MteJail.nonceCallback`

```cpp
public func nonceCallback(_ minLength: Int, _ maxLength: Int, _ nonce: inout [UInt8], _ nBytes: inout Int)
```

The nonce callback. See `MteNonceCallback` for details.
