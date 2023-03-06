# Swift Language Interface

## Overview

The basic flow is to create the SDR, initialize it, then use it to read and write files. Files in the SDR and the SDR itself can be removed. The SDR class can be derived from to change the storage and timestamp behavior.

To create, use an `MteSdr` initializer.

To initialize, call `MteSdr.initSdr()`.

To read files, use `MteSdr.readData()` or `MteSdr.readString()`. To write files, use `MteSdr.write()`.

To remove files from the SDR, use `MteSdr.remove()`.

To remove the entire SDR, use `MteSdr.removeSdr()`.

To change the storage and/or timestamp behavior, override the internal methods.

## Files

The MTE Secure Data Replacement Add-On uses the MTE Managed-Key Encryption Add-On source files documented in the [MTE Manged-Key Encryption Add-On Developer's Guide](../../DevGuide-Mke.md), as well as the following:

|File|Description|
|----|-----------|
|[**`MteSdr.swift`**](./MteSdr.md)|MteSdr class.|
