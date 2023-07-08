---
title: "Encoding & Encrypting Shellcode: Security Through Obscurity"
author: fortyfour
date: 2023-07-07 16:10
categories: [Malware, Cryptography]
tags: [malware, evasion, developement, av, edr, shellcode, cryptography, injection, windows, linux, c]
mermaid: true
image: /assets/img/media/shellcode-e-and-e-header.png
---

This article will serve as an introduction into security through obscurity, by means of obfuscation in the context of evading antivirus (AV) and endpoint detection and response (EDR) systems. We will be looking at multiple different encoding methods, as well as a strong encryption algorithm known as AES-256-CBC to achieve this. Afterwards we will touch on how you can implement this technique in a real-world scenario, and how we can use it to evade AV/EDR systems.

---

<details>
  <summary><strong>Table of Contents</strong></summary>
<div markdown="1">

- [Introduction](#introduction)
- [Overview](#overview)
- [Understanding API Hooking and DLL Injection](#understanding-api-hooking-and-dll-injection)
- [Implementation](#implementation)
    - [Handling Command Line Arguments](#1-handling-command-line-arguments)
    - [Converting the Target Program Path](#2-converting-the-target-program-path)
    - [Initializing Process Creation Attributes](#3-initializing-process-creation-attributes)
    - [Configuring Process Mitigation Policy](#4-configuring-process-mitigation-policy)
    - [Creating the Target Process](#5-creating-the-target-process)
    - [Cleanup and Resource Deallocation](#6-cleanup-and-resource-deallocation)
    - [Profit???](#7-profit)
- [Conclusion](#conclusion)

</div>
</details>

## Introduction
In this article, we will explore a program written in C that demonstrates the process of encoding and encrypting shellcode. Shellcode refers to a small piece of code that is typically used in exploitation scenarios, such as buffer overflow attacks. The program utilizes various techniques to modify and protect the shellcode, making it more difficult to detect and analyze. We will dive into each step of the program, discussing the theory behind its operations and how they contribute to the overall security of the shellcode.

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

## Conclusion
This article provided a detailed explanation of the shellcode program's inner workings, step by step. It covered the encoding techniques applied to modify the shellcode and the encryption process to protect it. Understanding these techniques is essential for security professionals and researchers involved in analyzing and defending against malicious code. By utilizing encoding and encryption, the program demonstrates how to enhance the stealthiness and resilience of shellcode in various exploitation scenarios.