# `MteSdr.swift`

## `MteSdr` Initializer (default MKE)

```swift
public convenience init(_ sdrDir: String) throws
```

Initializer using default MKE encoder and decoder and the given SDR directory.

**`sdrDir`**: the SDR directory.

## `MteSdr` Initializer (provided MKE)

```swift
public init(_ enc: MteMkeEnc, _ dec: MteMkeDec, _ sdrDir: String) throws
```

Initializer using provided MKE encoder and decoder and the given SDR directory. The encoder and decoder provided to this object cannot be used outside this object as this object will change their states. The encoder and decoder must have been created with matching options.

**`enc`**: the MKE encoder.\
**`dec`**: the MKE decoder.\
**`sdrDir`**: the SDR directory.

## `MteSdr.getEncoder`

```swift
public func getEncoder() -> MteMkeEnc
```

Returns the MKE encoder in use. This should only be used for information.

## `MteSdr.getDecoder`

```swift
public func getDecoder() -> MteMkeDec
```

Returns the MKE decoder in use. This should only be used for information.

## `MteSdr.initSdr`

```swift
public func initSdr(_ entropy: [UInt8], _ nonce: UInt64) throws
```

Initializes the SDR with the entropy and nonce to use. Throws an exception if the SDR cannot be created.

**`entropy`**: the entropy to use.\
**`nonce`**: the nonce to use.

## `MteSdr.readData`

```swift
public func readData(_ name: String) throws -> ArraySlice<UInt8>
```

Reads from storage or memory as data. If the same `name` exists in memory and on storage, the memory version is read. Throws an exception on I/O error.

**`name`**: the filename.

## `MteSdr.readString`

```swift
public func readString(_ name: String) throws -> String
```

Reads from storage or memory as a string. If the same `name` exists in memory and on storage, the memory version is read. Throws an exception on I/O error.

**`name`**: the filename.

## `MteSdr.write` (data)

```swift
public func write(_ name: String, _ data: [UInt8], toMemory: Bool = false) throws
```

Writes the given data to storage or memory. If the `name` matches the name of a previously written file, this will overwrite it. If `toMemory` is `true`, the data is saved to memory and not written to permanent storage; there are no restrictions on the contents of the `name` argument. If `toMemory` is `false`, the data is saved to permanent storage in the SDR directory set in the initializer; the `name` argument must be a valid filename. Throws an exception on I/O error.

**`name`**: the filename.\
**`data`**: the data to store.\
**`toMemory`**: `true` to save to memory or `false` to save to storage.

## `MteSdr.write` (string)

```swift
public func write(_ name: String, _ str: String, toMemory: Bool = false) throws
```

Writes the given string to storage or memory. If the `name` matches the name of a previously written file, this will overwrite it. If `toMemory` is `true`, the string is saved to memory and not written to permanent storage; there are no restrictions on the contents of the `name` argument. If `toMemory` is `false`, the string is saved to permanent storage in the SDR directory set in the initializer; the `name` argument must be a valid filename. Throws an exception on I/O error.

**`name`**: the filename.\
**`str`**: the string to store.\
**`toMemory`**: `true` to save to memory or `false` to save to storage.

## `MteSdr.remove`

```swift
public func remove(_ name: String) throws
```

Removes an SDR item. If the same name exists in memory and on storage, the memory version is removed. It is not an error to remove an item that does not exist. An exception is thrown if the file exists and cannot be removed.

**`name`**: the filename.

## `MteSdr.removeSdr`

```swift
public func removeSdr() throws
```

Removes the SDR. All memory and storage items are removed. This object is not usable until a new call to [`initSdr()`](#mtesdrinitsdr). It is not an error to remove an SDR that does not exist. An exception is thrown if any file in the SDR cannot be removed.

## `MteSdr.dirExists`

```swift
internal func dirExists(_ dir: String) -> Bool
```

Returns `true` if the directory exists, `false` if not. The `FileManager.default` API is used. Override to provide an alternate implementation.

**`dir`**: the directory name.

## `MteSdr.fileExists`

```swift
internal func fileExists(_ dir: String, _ file: String) -> Bool
```

Returns `true` if the `file` exists in `dir`, `false` if not. The `FileManager.default` API is used. Override to provide an alternate implementation.

**`dir`**: the directory name.\
**`file`**: the filename.

## `MteSdr.listFiles`

```swift
internal func listFiles(_ dir: String) throws -> [String]
```

Returns a list of file basenames in a directory. Throws an exception on failure. The `FileManager.default` API is used. Override to provide an alternate implementation.

**`dir`**: the directory name.

## `MteSdr.createDir`

```swift
internal func createDir(_ dir: String) throws
```

Creates a directory, including any intermediate directories as necessary. Throws an exception on failure. The `FileManager.default` API is used. Override to provide an alternate implementation.

**`dir`**: the directory name.

## `MteSdr.readFile`

```swift
internal func readFile(_ dir: String, _ file: String) throws -> [UInt8]
```

Reads a file. Returns the file contents. Throws an exception on failure. The `Data` API is used. Override to provide an alternate implementation.

**`dir`**: the directory name.\
**`file`**: the filename.

## `MteSdr.writeFile`

```swift
internal func writeFile(_ dir: String, _ file: String, _ contents: [UInt8]) throws
```

Writes a file. Throws an exception on failure. The `Data` API is used. Override to provide an alternate implementation.

**`dir`**: the directory name.\
**`file`**: the filename.\
**`contents`**: the contents of the file to write.

## `MteSdr.removeDir`

```swift
internal func removeDir(_ dir: String) throws
```

Removes a directory. Throws an exception on failure. The `FileManager.default` API is used. Override to provide an alternate implementation.

**`dir`**: the directory name.

## `MteSdr.removeFile`

```swift
internal func removeFile(_ dir: String, _ file: String) throws
```

Removes a file. Throws an exception on failure. The `FileManager.default` API is used. Override to provide an alternate implementation.

**`dir`**: the directory name.\
**`file`**: the filename.

## `MteSdr.getTimestamp`

```swift
internal func getTimestamp() -> UInt64
```

Returns the timestamp, byte swapped to increase the entropy in the upper bytes. The `Date().timeIntervalSince1970` function is used. Override to provide an alternate implementation. It is recommended to byte swap the value so the most-changing part of the timestamp is in the upper bytes of the `UInt64`.
