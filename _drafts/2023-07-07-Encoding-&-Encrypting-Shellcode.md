---
title: "Encoding & Encrypting Shellcode: Security Through Obscurity"
author: fortyfour
date: 2023-07-07 16:10
categories: [Malware, Cryptography]
tags: [malware, evasion, developement, av, edr, shellcode, cryptography, injection, windows, linux, c]
mermaid: true
image: /assets/img/media/shellcode-e-and-e-header.png
---

This article will serve as an introduction into security through obscurity, by means of obfuscation in the context of evading antivirus (AV) and endpoint detection and response (EDR) systems. We will be looking at multiple different encoding methods, a strong encryption algorithm known as AES-256-CBC, as well as various other tricks to achieve this. Afterwards we will touch on how you can implement this technique in a real-world scenario, and how we can use it to evade AV/EDR systems in your own payload.

---

<details>
  <summary><strong>Table of Contents</strong></summary>
<div markdown="1">

- [Introduction](#introduction)
- [Theory](#theory)
    - [Shellcode](#shellcode)
    - [detection](#detection)
        - [Signature-based Detection](#signature-based-detection)
        - [Heuristic-based Detection](#heuristic-based-detection)
        - [Behavior-based Detection](#behavior-based-detection)
    - [Encoding](#encoding)
        - [XOR Encoding](#xor-encoding)
        - [NOT Encoding](#not-encoding)
        - [Rotation Encoding](#rotation-encoding)
        - [Decrement Encoding](#decrement-encoding)
    - [Encryption](#encryption)
        - [AES-256-CBC](#aes-256-cbc)
- [Program Overview](#program-overview)
- [Reading and Sanitizing Shellcode](#reading-and-sanitizing-shellcode)
- [Encoding Techniques](#encoding-techniques)
    - [XOR Encoding](#xor-encoding-1)
    - [NOT Encoding](#not-encoding-1)
    - [Rotation Encoding](#rotation-encoding-1)
    - [Decrement Encoding](#decrement-encoding-1)
- [AES Encryption](#aes-encryption)
- [Printing Encoded/Encrypted Shellcode](#printing-encodedencrypted-shellcode)
- [Conclusion](#conclusion)

</div>
</details>

## Introduction
In this article, we will explore a program written in C that demonstrates the process of obfuscating shellcode in order to avoid detection by antivirus (AV) and endpoint detection and response (EDR) systems. Shellcode refers to a small piece of code that is typically used in exploitation scenarios, such as buffer overflow attacks or even process injection. The program utilizes various techniques to modify and protect the shellcode, making it more difficult to detect and analyze. We will dive into each step of the program, discussing the theory behind its operations and how they contribute to the overall security of the shellcode.

> After re-writing this entire program from scratch **7 times**, you would think that I would know what the heck I am actually doing but alas this is just the start of the [scrypt](https://github.com/9xN/scrypt) project. I will be updating this article, as well as, the repository as I continue to develop the program and learn new things. With plans to expand into creating fully undetected payloads with a built in shellcode execution process utilizing some of the other techniques I have written about in the past and plan to write in the future.
{: .prompt-warning }
## Theory

> This section might be a little dry for most readers, so if you are just here for the meat and potatos of the article, feel free to skip ahead to the [Program Overview](#program-overview) section.
{: .prompt-danger }

### Shellcode
> In hacking, a shellcode is a small piece of code used as the payload in the exploitation of a software vulnerability. It is called "shellcode" because it typically starts a command shell from which the attacker can control the compromised machine, but any piece of code that performs a similar task can be called shellcode. Because the function of a payload is not limited to merely spawning a shell, some have suggested that the name shellcode is insufficient. However, attempts at replacing the term have not gained wide acceptance. Shellcode is commonly written in machine code.
- [Wikipedia](https://en.wikipedia.org/wiki/Shellcode)
{: .prompt-info }

Shellcode is often used in combination with a vulnerability or security flaw in a target system. When the vulnerability is exploited, the shellcode is injected into the system's memory, and its execution allows the attacker to gain control and perform malicious actions.

### Detection

#### Signature-based Detection
Signature-based detection is a method of identifying and detecting malicious code or threats based on predefined patterns, known as signatures. These signatures are essentially unique fingerprints or characteristics of specific malware or attacks. The detection process involves comparing the signatures of files or network traffic against a database of known malicious signatures.

While signature-based detection can be effective in identifying known threats, it may struggle with detecting new or previously unseen malware. Attackers can evade detection by modifying or encrypting their code, making it difficult for signature-based systems to recognize the malicious patterns.

#### Heuristic-based Detection
Heuristic-based detection takes a more proactive approach to identifying malware by analyzing the behavior and characteristics of files or code. Instead of relying solely on predefined signatures, heuristic detection uses rules and algorithms to identify potentially malicious behavior or patterns that deviate from normal system activity.

This method is particularly useful in detecting new or unknown threats, as it doesn't rely on specific signatures. Heuristic-based detection looks for suspicious actions such as code injection, unauthorized system modifications, or abnormal network communication. However, it may also generate false positives if legitimate software exhibits behavior that matches the heuristics.

#### Behavior-based Detection
Behavior-based detection focuses on monitoring the runtime behavior of software or processes to identify potential threats. It involves analyzing the actions and interactions of programs, looking for patterns or activities that are indicative of malicious behavior.

By observing how a program accesses files, communicates over the network, or interacts with system resources, behavior-based detection systems can identify malicious activities that may not be detected by traditional signature-based approaches. This method is particularly effective against zero-day attacks or advanced persistent threats (APTs) that can evade other detection mechanisms.

### Encoding

#### XOR Encoding
XOR encoding (Exclusive OR encoding) is a simple method used to obfuscate or hide the content of a piece of code or data. It involves performing an XOR operation between the original content and a specific key or value. The resulting encoded data appears random and unintelligible without knowledge of the key.

To decode the XOR-encoded data, the same XOR operation is applied with the key, effectively reversing the encoding process and recovering the original content. XOR encoding is relatively simple and fast, but it is not a strong encryption method on its own and can be easily broken if the key is known.

#### NOT Encoding
NOT encoding, also known as bitwise negation, is a basic encoding technique that operates at the binary level. It involves flipping the bits of the original binary data, transforming each 0 into a 1 and vice versa.

This encoding method is straightforward and can be easily reversed by applying the NOT operation again to the encoded data. It is often used in combination with other encoding techniques to add an extra layer of obfuscation to the data.

#### Rotation Encoding
Rotation encoding, also known as the Caesar cipher, is a simple substitution cipher that shifts each character in the plaintext by a fixed number of positions in bytes forward in rotation. This fixed number is often referred to as the "key" or "rotation value."

Rotation encoding is a symmetric encoding scheme, meaning that applying the encoding process twice will result in the original content. However, it is a weak form of encoding and provides minimal security against determined attackers.

#### Decrement Encoding
Decrement encoding involves subtracting a fixed value from each character or byte in a piece of data. This method is commonly used to obfuscate or manipulate numeric values in code or data. By decrementing values, the encoded data appears different from the original content.

To decode the data, the inverse operation is applied by adding the fixed value back to each character or byte. Decrement encoding is a simple form of encoding and provides only minimal protection against casual inspection.

### Encryption

#### AES-256-CBC
AES-256-CBC is a widely used symmetric encryption algorithm. AES stands for Advanced Encryption Standard, and 256 refers to the key size in bits. CBC (Cipher Block Chaining) is a mode of operation that adds an extra layer of security by chaining together blocks of data.

AES-256-CBC is a symmetric encryption algorithm that operates on blocks of data. Let's break down how it works:

```mermaid
graph TD
  subgraph Encryption
    A[Initialize IV and Key]
    B[Plaintext]
    A -->|Generate IV and Key| C[IV]
    A -->|Generate IV and Key| D[Key]
    C -->|XOR with Plaintext| E[XOR]
    E -->|AES Encryption| F[Ciphertext]
    D -->|AES Encryption| F
    B -->|Padding| G[Padded Plaintext]
    G -->|Split into Blocks| H[Blocks]
    H -->|AES Encryption| I[Cipher Blocks]
    I -->|Concatenate| J[Ciphertext]
  end

  subgraph Decryption
    K[IV]
    D -->|Same Key as Encryption| L[Key]
    C -->|Same IV as Encryption| K
    F -->|AES Decryption| E
    L -->|AES Decryption| E
    E -->|XOR with IV| B[Decrypted Plaintext]
  end

  F -->|Ciphertext| K
  I -->|Cipher Blocks| L
```

$$ \text{Ciphertext} = \text{AES}_{256}\text{CBC}\left(\text{Plaintext}, \text{Key}, \text{IV}\right) $$

![](/assets/img/media/shellcodeobfuscation/cbc-encryption.png)

1. **Key Expansion**: AES-256-CBC uses a 256-bit secret key. The key expansion algorithm takes this key and generates a set of round keys that will be used during the encryption and decryption processes.

2. **Initialization Vector (IV)**: An Initialization Vector is a random value of the same block size (128 bits for AES) that is used to add randomness to the encryption process. The IV is typically different for each encryption operation.

3. **Padding**: If the plaintext message is not a multiple of the block size, padding is applied to ensure it can be divided into equal-sized blocks. PKCS7 padding is commonly used, where the padding bytes indicate the number of bytes added.

4. **Encryption**: The plaintext is divided into blocks of 128 bits. AES-256-CBC operates on each block independently. The process begins with the XOR operation between the plaintext block and the IV (or the previous ciphertext block in subsequent blocks).

5. **Encryption Rounds**: AES-256-CBC employs a series of encryption rounds. In each round, several transformations are applied to the data, including substitution, permutation, and mixing operations. These operations create confusion and diffusion, making it difficult for an attacker to analyze patterns in the encrypted data.

6. **Final Block Encryption**: For the final block, if padding was added, the padding bytes are encrypted along with the plaintext.

7. **Ciphertext**: The resulting ciphertext is the encrypted form of the plaintext. It is a series of blocks, where each block depends on the previous block due to the chaining process.

During decryption, the process is reversed:

$$ \text{Plaintext} = \text{AES}_{256}\text{CBC}^{-1}\left(\text{Ciphertext}, \text{Key}, \text{IV}\right) $$

![](/assets/img/media/shellcodeobfuscation/cbc-decryption.png)

1. **Key Expansion**: The same key expansion algorithm is used to generate the round keys.

2. **Decryption**: The ciphertext is divided into blocks, and the decryption process is applied to each block independently.

3. **Decryption Rounds**: AES-256-CBC uses the inverse transformations of the encryption rounds to decrypt the data. These inverse operations reverse the confusion and diffusion created during encrypti
4. **XOR Operation**: The IV or previous ciphertext block is XORed with the decrypted block to obtain the original plaintext block.

5. **Padding Removal**: If padding was added during encryption, it is removed to obtain the original plaintext message.

## Program Overview
The program begins by including necessary libraries and defining some utility functions and constants. These include functions for error handling, printing banners, reading shellcode from a file, and performing encoding and encryption operations. The constants define color codes for console output.

## Reading and Sanitizing Shellcode
The `readShellcodeFromFile` function reads the shellcode from a file specified as a command-line argument. It reads the file byte by byte, discarding unwanted characters like quotes and newlines. The resulting shellcode is stored in an allocated memory block and returned to the main function. Before proceeding, the program sanitizes the shellcode by removing any null bytes (0x00). This step is essential because null bytes can interfere with some encoding techniques.

## Encoding Techniques
The program applies a series of encoding techniques to modify the shellcode and make it harder to detect. The following encoding techniques are implemented:

### XOR Encoding
The `xor_encoding` function performs an XOR operation between the shellcode and a XOR key. Each byte of the shellcode is XORed with the corresponding byte from the key. The key is repeated cyclically if its length is smaller than the shellcode length. XOR encoding helps obfuscate the shellcode and is reversible with the same key.

### NOT Encoding
The `not_encoding` function performs a bitwise NOT operation on each byte of the shellcode. This operation complements the bits, effectively inverting them. NOT encoding helps to further obfuscate the shellcode.

### Rotation Encoding
The `rot_encoding` function performs a bitwise rotation operation on each byte of the shellcode. The rotation amount is determined randomly. The rotation operation shifts the bits in the byte, introducing entropy and increasing the complexity of the shellcode.

### Decrement Encoding
The `dec_encoding` function subtracts a random value from each byte of the shellcode. The decrement value is also chosen randomly. Decrement encoding alters the values of the shellcode, making it more challenging to recognize and analyze.

## AES Encryption
After applying the encoding techniques, the program proceeds to encrypt the shellcode using the AES (Advanced Encryption Standard) algorithm in CBC (Cipher Block Chaining) mode. The `encrypt_aes_cbc` function utilizes the OpenSSL library to perform the encryption. It takes the modified shellcode, an AES key, an initialization vector (IV), and an output buffer as input. The function encrypts the shellcode and stores the ciphertext in the output buffer.

## Printing Encoded/Encrypted Shellcode
Once the encryption process is complete, the program prints relevant information about the encoded and encrypted shellcode. It displays the original shellcode length, the ciphertext length, and the iterations performed. The program also prints the arrays representing the encoded/encrypted shellcode, the AES key, the IV, and the XOR key. These arrays can be copied into other programs for use.

## The Stub (descrypt)

## Conclusion
This article provided a detailed explanation of the shellcode program's inner workings, step by step. It covered the encoding techniques applied to modify the shellcode and the encryption process to protect it. Understanding these techniques is essential for security professionals and researchers involved in analyzing and defending against malicious code. By utilizing encoding and encryption, the program demonstrates how to enhance the stealthiness and resilience of shellcode in various exploitation scenarios.