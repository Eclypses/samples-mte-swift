# Swift Language Interface

## Overview

The basic flow is to use the nonce mutator class as the nonce callback plugin for the encoder or decoder.

After creating the nonce mutator object, call `setAlgo()` to set the [jailbreak detection algorithm](./MteJail.md#mtejailalgo) to match the device or simulator being used, then set the object as the nonce callback plugin for the encoder or decoder. Call `setNonceSeed()` to set the nonce seed before calling `instantiate()` on the encoder or decoder.

## Files

The MTE Jailbreak Detection Add-On uses the core source files documented in the [MTE Developer's Guide](../../../DevGuide.md), as well as the following:

|File|Description|
|----|-----------|
|[**`MteJail.swift`**](./MteJail.md)|MteJail class.|
