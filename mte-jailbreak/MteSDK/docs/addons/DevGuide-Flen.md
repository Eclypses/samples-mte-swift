# MTE Fixed-Length Add-On Developer's Guide

***MTE Version 3.0***

## Introduction

The Fixed-Length Add-On is a replacement for the core encoder that ensures all messages are encoded to a fixed length. If the input is too long, it is truncated to the fixed length; if the input is too short, it is padded up to the fixed length. The padding consists of bytes with value `0` ("null bytes"). The null bytes are appended to the input data up to the fixed length.

The core encoder is used by the fixed length encoder, so it is important to understand the core encoder first. Refer to the _MTE Core Developer's Guide_.

The core decoder is used with the fixed length encoder. No length information is transmitted, so it is up to the decoding application to have a way to know what is valid. In many cases, this add-on is used to encode variable-length strings, and null bytes are used for padding, and therefore indicate the end of the string. If you are not encoding strings, it is up to you to use appropriate logic to determine the valid decoded length.

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

# Options

The MTE Fixed-Length Add-On uses the [options in the main developer's guide](../DevGuide.md#options), as well as the following:

|Option|Description|
|------|-----------|
|**Fixed Length**|The desired *input* fixed length. Inputs longer than this are truncated to this length; inputs shorter than this are padded to this length. The result will be fixed-length messages, but that length depends on the other options chosen.|

## Choosing the Fixed Length

To choose the fixed length, determine the maximum allowed input size. You may need to consider adding a length to the data if the padding cannot imply the valid length, and this may increase the fixed length necessary.

# Status

Refer to [the main developer's guide](../DevGuide.md#status).

## Language Interfaces

The following language interfaces are available:

* [C](./flen/c/api.md)
* [C++](./flen/cpp/api.md)
* [C#](./flen/cs/api.md)
* [Go](./flen/go/api.md)
* [Java](./flen/java/api.md)
* [Objective-C](./flen/objc/api.md)
* [Python](./flen/py/api.md)
* [Swift](./flen/swift/api.md)
* [WASM/JS](./flen/wasm/api.md)
