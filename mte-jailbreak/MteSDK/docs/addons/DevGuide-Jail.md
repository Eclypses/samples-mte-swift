# MTE Jailbreak Detection Developer's Guide

***MTE Version 3.0***

## Introduction

The Jailbreak Detection Add-On is used in conjunction with the core MTE technology or any add-ons to aid in detecting jailbroken/rooted devices.

A jailbroken (iOS) or rooted (Android) device is a device that has software installed on it not approved by the device vendor (e.g., via an app store). The jailbreak/root process involves purposely removing some security built in to the device's operating system, and therefore makes these devices more susceptible to attacks. App vendors may want to limit or remove the ability of compromised devices to interact with their servers.

The Jailbreak Detection Add-On works by taking a seed nonce and mutating it. The mutations that occur depend on the results of the jailbreak/root checks performed. If a device is communicating to a server (defined as any other endpoint the device is communicating with, which is typically a server), that server will start from the same seed nonce and simulate the same jailbreak/root checks the device is doing. Since the MTE technology depends on paired nodes that are in sync, if the server and device mutate the nonce the same way, they will be able to communicate. However, if any jailbreak/root check indicates the device is jailbroken/rooted, the device's nonce mutation will end up different, and therefore the device and server will not be in sync. When the device and server are not in sync, they will fail to communicate successfully (with extremely high probability if the token size is sufficiently large), which allows the *server* to detect that the *device* is jailbroken/rooted.

Most jailbreak/root detection schemes are written to work solely on the device, which makes them susceptible to counter-attacks where the jailbreak/root system can modify the results or simply bypass the check and the app can't tell. The Jailbreak Detection Add-On offloads the actual detection of the jailbreak/root to the server, so the device can't simply "return false" to a jailbreak/root check function. Note that nonce mutation occurs whether the device is jailbroken/rooted or not, so it cannot just be skipped. The mutation is just different depending on the results of the checks performed.

It is up to the app developer to decide how to handle the result of the detection. The Jailbreak Detection Add-On does not do anything to the app, and the MTE code running on the device doesn't even know that anything is or isn't wrong; it simply does the checks and modifies the nonce.

As with all MTE technology, a paired encoder and decoder need to be in sync. The entropy, nonce, and personalization string must all be the same on both sides. Since the Jailbreak Detection Add-On mutates a seed nonce, that mutation must be done the same way on the encoder (device) and decoder (server). The encoder (device) mutator must correspond to the type of device being checked. Each type of device (or simulator) has its own jailbreak/root detection logic which is not compatible with any other device (or simulator) type since the checks performed are highly specific to the hardware and operating system. The decoder (server) mutator must match the type of device (or simulator) being communicated with. Most systems will have servers that communicate with multiple types of devices (and simulators), so you must have a way of knowing which type you are communicating with and pair them appropriately.

**Example**: iPhone (ARM64) encoder communicating with Linux (x86\_64) decoder: Both should use the iOS ARM64 device mutator.
**Example**: iPhone Simulator (x86\_64) encoder communicating with Linux (x86\_64) decoder: Both should use the iOS x86\_64 simulator mutator.

On an iOS or Android device, if you choose a mutator that does not match the actual platform, it will fail to communicate as if it is jailbroken. Those devices cannot do simulation of the mutation like other platforms can; they can only do the actual checks that correspond to their hardware and operating system.

The actual detection of a problem occurs in the decode operation on the server, and is detected in an implied way by the decoder returning a "token does not exist" error when attempting to decode. This is a result of the decoder not being in sync with the encoder due to different nonce mutation. This error is general in the sense that it can imply other problems, so it is assumed that your jailbreak detection system has already verified valid communication before doing the jailbreak detection to eliminate the other possible reasons.

One possible approach is to first instantiate the encoder and decoder with the entropy, nonce seed, and personalization string without the jailbreak/root detection, send a message and verify correct decoding. If that is successful, redo the same process with the same inputs, but with jailbreak/root detection enabled and verify correct decoding again. If it now gives the "token does not exist" error, the jailbreak/root detection has identified a problem.

The jailbreak/root nonce mutation is implemented in a set of C functions (one for each supported hardware/operating system combination), and each language interface provides an easier way to use them in the respective language via the nonce callback plugin architecture.

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

All SDK packages that include the MTE Jailbreak Detection Add-On will include the MTE Jailbreak Detection Add-On library and the associated MTE Jailbreak Detection Add-On language interfaces will also be present.

# Options

Refer to [the main developer's guide](../DevGuide.md#options).

The Jailbreak Detection Add-On requires the ability to mutate a seed nonce, so only DRBGs that accept a nonce can be used. In particular, the `NODF` DRBGs are not usable because they do not accept a nonce.

# Status

Refer to [the main developer's guide](../DevGuide.md#status).

## Language Interfaces

The following language interfaces are available:

* [C](./jail/c/api.md)
* [C++](./jail/cpp/api.md)
* [C#](./jail/cs/api.md)
* [Go](./jail/go/api.md)
* [Java](./jail/java/api.md)
* [Objective-C](./jail/objc/api.md)
* [Python](./jail/py/api.md)
* [Swift](./jail/swift/api.md)
* [WASM/JS](./jail/wasm/api.md)
