# MTE Secure Data Replacement Add-On Developer's Guide

***MTE Version 3.0***

## Introduction

The MTE Secure Data Replacement Add-On uses the MTE Managed-Key Encryption Add-On to create a secure SDR in memory or on storage. This SDR can hold files securely without depending on the operating system or other mechanisms which may be prone to security flaws which are exploited by attackers. Due to the design of MTE, the information needed to unlock the SDR can be split and stored in separate locations, none of which are on the device where the SDR exists. This design protects the SDR against typical attacks on device operating systems.

The MTE Secure Data Replacement Add-On uses four pieces of information to encrypt files: entropy, nonce, the filename, and a timestamp. Without all four pieces of information, the encrypted files cannot be decrypted. The timestamp is stored with the file, and its only purpose is to ensure that the same file contents and name will encrypt differently each time they are encrypted. The filename is used as the personalization string, again to ensure that the same file contents encrypt differently in different files. The biggest keys to the security are the entropy and nonce. Refer to the [MTE Developer's Guide](../DevGuide.md) for more information about the entropy, nonce, and personalization string.

The MTE Secure Data Replacement Add-On is written to support both memory-only and permanent storage files. The memory-only files will disappear when the application exits or the SDR object is destroyed. The permanent storage files are persisted until explicitly removed. The memory-only feature makes storing small pieces of sensitive data securely extremely efficient and easy to use, so applications can avoid storing sensitive data in the clear in memory, helping to reduce the success of certain attack vectors.

By default, the MTE Secure Data Replacement Add-On's permanent storage uses the default filesystem API of the device. The classes are written with abstracted input/output (I/O), so it is possible to provide alternate storage APIs. Using this capability, the files could be written anywhere the developer chooses, including on remote devices or in databases.

By default the MTE Secure Data Replacement Add-On acquires a timestamp using a basic API. The classes are written with abstracted timestamp acquisition, so it is possible to provide an alternate timestamp source. A higher resolution timestamp source can be beneficial if files are written quickly because it introduces more variation.

There are many ways to design systems to use the MTE Secure Data Replacement Add-On to enhance security. All examples show uses of the SDR that would prevent a compromised device from compromising the secured data. Even if the operating system is compromised, the data is protected because nothing on the device has all of the information needed to decrypt the files. The following subsections describe some examples.

## Server-Controlled Entropy With PIN Nonce

In this example, the application communicates with a remote server. The application may be storing sensitive data on the device which should only be unlocked and used by the application.

To create the SDR, the server generates some entropy and sends it to the application (via secure means like PKI or using MTE) as well as storing it for later use. The application asks the user for a PIN (to be the nonce). This PIN does not have to be particularly strong because the security is ensured by the entropy, so the user experience is a good one. The PIN simply ensures that the entropy alone, if somehow captured, would not be enough to unlock the Secure Data Replacement Add-On. The SDR can now be created and files can be stored.

Once the SDR is created, later uses of the application will need to contact the server to get the saved entropy (securely) and prompt for the user's PIN in order to initialize and decrypt the persisted files successfully.

Variations of this example could allow for complete server control of the files by the server providing the nonce as well, which could be useful in a DRM scenario where the application wants complete control over the usability of the data, regardless of the user.

## Device Owner Entropy And Nonce

In this example, the application may not communicate with any server. The application may be storing personal data like photos which should only be unlocked when the device owner wants to use them.

To create the SDR, the application needs to acquire some entropy. This may be in the form of a password or biometrics or something similar. The application may also ask for a PIN (to be the nonce) for an extra level of security. The entropy and nonce must not be stored on the device. The SDR can now be created and files can be stored.

Once the SDR is created, later uses of the application will need to prompt again for the entropy and nonce sources in order to initialize and decrypt the persisted files successfully.

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

Refer to the [MTE Developer's Guide](../DevGuide.md) and [MTE Managed-Key Encryption Add-On Developer's Guide](./DevGuide-Mke.md) options. If you provide the MKE encoder and decoder to the SDR, the options must be the same for the encoder and decoder.

# Status

Refer to [the main developer's guide](../DevGuide.md#status).

## Language Interfaces

The following language interfaces are available:

* [Java](./sdr/java/api.md)
* [Swift](./sdr/swift/api.md)
* [WASM/JS](./sdr/wasm/api.md)
