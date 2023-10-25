---
title: "List of Process Injection Techniques"
author: fortyfour
date: 2023-10-24 16:15
categories: [Process Injection]
tags: [malware, evasion, developement, process injection, av, edr, shellcode, injection, windows, linux, c]
mermaid: true
image: /assets/img/media/process-injection-header.jpg
---

This list will serve as an introduction into many different kinds of process injection techniques. I will be adding links to articles that I have written about the techniques that I have learned about. 

---

<details>
  <summary><strong>Table of Contents</strong></summary>
<div markdown="1">

- [Reflective DLL Injection](#reflective-dll-injection)
  - [Introduction](#introduction)
  - [Conclusion](#conclusion)
- [Thread Hijacking](#thread-hijacking)
   - [Introduction](#introduction-1)
   - [Conclusion](#conclusion-1)
- [Early Bird Injection](#early-bird-injection)
   - [Introduction](#introduction-2)
   - [Conclusion](#conclusion-2)
- [APC Injection](#apc-injection)
   - [Introduction](#introduction-3)
   - [Conclusion](#conclusion-3)
- [AtomBombing](#atombombing)
   - [Introduction](#introduction-4)
   - [Conclusion](#conclusion-4)
- [Process Doppelgänging](#process-doppelgänging)
   - [Introduction](#introduction-5)
   - [Conclusion](#conclusion-5)
- [QueueUserAPC Malware Injection](#queueuserapc-malware-injection)
   - [Introduction](#introduction-6)
   - [Conclusion](#conclusion-6)

</div>
</details>

## Reflective DLL Injection

### Introduction

Reflective DLL Injection stands as a pinnacle in the art of code injection, allowing the discreet insertion and execution of dynamic link libraries (DLLs) directly from memory. This advanced technique has gained prominence among developers, reverse engineers, and cybersecurity experts due to its ability to bypass traditional detection mechanisms and provide unparalleled control over target processes. In this in-depth exploration, we will delve deep into the intricacies of Reflective DLL Injection, uncovering its inner workings, applications, and the challenges it poses to both defenders and adversaries.

I. **Foundations of Reflective DLL Injection**

At its core, Reflective DLL Injection hinges on the concept of a self-contained, reflective DLL. Such a DLL possesses the capability to resolve its own imports, relocations, and function addresses without relying on the host process. The technique was first introduced by Stephen Fewer and has since been further refined and extended by the cybersecurity community.

II. **The Anatomy of Reflective DLL Injection**

1. **Memory Mapping:**
   Reflective DLL Injection begins with the creation of a reflective DLL structure in memory. This structure typically consists of headers, sections, and import tables, all organized in a way that facilitates self-relocation and function resolution. The injected reflective DLL is often crafted using C or assembly language to ensure precise control over memory layout.

2. **Memory Allocation and Injection:**
   To execute Reflective DLL Injection, a host process is chosen as the target. The attacker allocates memory within the target process, copies the reflective DLL structure into this allocated memory, and modifies the necessary pointers and addresses to ensure proper execution flow.

3. **Function Resolution:**
   Reflective DLLs employ a mechanism to resolve function addresses dynamically. This involves parsing the export table, reconstructing the import address table (IAT), and using runtime function hashing or other techniques to retrieve the function addresses. This self-contained resolution allows the reflective DLL to operate independently of the host process's internal structures.

III. **Advantages and Applications**

1. **Stealth and Evasion:**
   Reflective DLL Injection is inherently stealthy as it doesn't require creating files on disk or altering the host process's import address table. This characteristic makes it an attractive choice for malware developers aiming to evade detection by antivirus software and endpoint protection mechanisms.

2. **Anti-forensics and Persistence:**
   The reflective nature of this technique enables malware to remain hidden and resilient against memory analysis and traditional forensic techniques. Malicious actors can leverage Reflective DLL Injection to establish persistence by injecting their code into legitimate processes, making detection and removal more challenging.

3. **Malware Payload Delivery:**
   Attackers can use Reflective DLL Injection to deliver payloads directly into memory, reducing the need for files on disk. This approach allows them to avoid triggering alerts associated with file-based attacks and enables rapid execution of malicious code.

IV. **Countermeasures and Challenges**

1. **Behavioral Analysis:**
   Traditional signature-based detection methods may struggle to identify Reflective DLL Injection, prompting the need for behavior-based analysis that monitors runtime process activities and memory manipulation.

2. **Memory Scanning and Heuristics:**
   Endpoint protection solutions must incorporate memory scanning and heuristics to detect abnormal memory allocations, modifications, and execution flows within processes.

3. **API Hooking and Integrity Checks:**
   Employing API hooking techniques and integrity checks for critical process structures can help detect and prevent reflective injection attempts.

V. **Ethical Considerations**

As we explore Reflective DLL Injection, it is imperative to acknowledge its dual nature. While it has legitimate applications in software debugging, virtual machine introspection, and cybersecurity research, its misuse by malicious actors underscores the importance of responsible and ethical usage.

### Conclusion

Reflective DLL Injection stands as a testament to the relentless innovation in software development and cybersecurity realms. Its ability to load and execute code directly from memory represents a formidable challenge to both defenders and adversaries. As technology advances, defenders must remain vigilant in evolving their detection and mitigation strategies, while researchers continue to explore the depths of this technique to better understand its implications and potential applications. Reflective DLL Injection serves as a reminder of the intricate dance between security, innovation, and responsibility in the ever-evolving landscape of digital landscapes.

## Thread Hijacking:

### Introduction

In the realm of advanced code injection techniques, Thread Hijacking has emerged as a sophisticated method that offers unprecedented control over target processes. By redirecting the execution flow of an existing thread within a process, this technique enables both developers and cybersecurity professionals to achieve stealth, persistence, and intricate process manipulation. This article embarks on a comprehensive journey into the world of Thread Hijacking, unraveling its intricacies, real-world applications, and the intricate cat-and-mouse game it plays with defenders and attackers.

I. **Thread Hijacking: A Technical Prelude**

Thread Hijacking is grounded in the concept of taking control of a running thread within a target process and diverting its execution to execute injected code. This technique represents an evolution beyond traditional methods like DLL injection, offering a unique way to insert code into processes under the radar.

II. **The Intricate Dance of Thread Hijacking**

1. **Thread Selection and Context Switching:**
   To initiate Thread Hijacking, attackers must identify a suitable thread within the target process. This could be a dormant thread, an existing worker thread, or a thread engaged in specific functions. Once identified, the attacker forces a context switch, temporarily pausing the thread's execution and allowing for code injection.

2. **Code Injection and Execution:**
   The attacker then injects code into the suspended thread's memory space. This injected code could be a shellcode, payload, or even a complete DLL. After injection, the attacker resumes the execution of the thread, thereby ensuring the injected code runs within the context of the target process.

III. **Advantages and Applications**

1. **Stealthy Operation:**
   Thread Hijacking's strength lies in its ability to blend in seamlessly with legitimate threads, evading detection mechanisms that focus on new thread creation or external file manipulation.

2. **Bypassing Process-Based Protections:**
   Thread Hijacking can bypass process-level security mechanisms that focus on detecting new processes or injected modules, making it a potent technique for attackers seeking to circumvent defense systems.

3. **Real-time Manipulation and Evasion:**
   By intercepting a thread's execution, Thread Hijacking allows real-time manipulation of a process's behavior. This characteristic can be harnessed for debugging, software analysis, and performance optimization.

IV. **Challenges and Defenses**

1. **Detection and Behavioral Analysis:**
   Traditional signature-based approaches may struggle to detect Thread Hijacking, making behavior-based analysis essential. Monitoring for unusual thread activity, context switching, and code injection can aid in identifying suspicious behavior.

2. **Memory Protection and Sandboxing:**
   Employing memory protection mechanisms and sandboxing can help contain the impact of Thread Hijacking attempts. Sandboxes that restrict thread manipulation and isolate processes can hinder attackers' ability to carry out successful thread hijacks.

3. **Static Analysis and Code Review:**
   Performing static analysis and code review on application binaries can help identify potential vulnerabilities that attackers might exploit for Thread Hijacking.


### Conclusion

Thread Hijacking stands as a testament to the continuous evolution of code injection techniques in the realms of both software development and cybersecurity. Its ability to redirect the execution flow of a running thread within a process presents a compelling challenge to defenders and a powerful tool for attackers. As we navigate this intricate landscape, the responsibility to employ Thread Hijacking judiciously underscores the ongoing need for ethical considerations in the pursuit of knowledge, innovation, and the ever-elusive balance between security and progress.

## Early Bird Injection:

### Introduction

In the realm of advanced code injection techniques, Early Bird Injection shines as a groundbreaking method that grants unparalleled influence over the initialization of processes. By injecting code at the nascent stages of process creation, this technique provides developers, reverse engineers, and cybersecurity experts with a unique opportunity to gain insight, control, and even evade traditional security mechanisms. This article embarks on a comprehensive exploration of Early Bird Injection, diving into its inner workings, real-world applications, and the delicate balance it strikes between innovation and security.

I. **Early Bird Injection: A Prelude to Process Creation**

Early Bird Injection revolves around the concept of injecting code into a target process during its initial stages of creation, before the main entry point is invoked. This approach takes advantage of the process creation sequence to insert code seamlessly and gain unprecedented control over the target's lifecycle.

II. **The Art of Early Bird Injection**

1. **Process Creation Hooks:**
   To initiate Early Bird Injection, attackers employ various techniques, including process creation hooks, to intercept and manipulate the process creation sequence. This may involve intercepting system calls, modifying data structures, or leveraging debugging interfaces.

2. **Code Injection and Execution:**
   Once the process creation sequence is intercepted, the attacker injects their code into the target process's address space. This injected code may include payloads, hooks, or even complete modules that execute before the process's main entry point is invoked.

III. **Applications and Advantages**

1. **Security Research and Debugging:**
   Early Bird Injection offers researchers a unique vantage point to study process initialization, analyze system behavior, and identify vulnerabilities that could be exploited during this critical phase.

2. **Anti-Antivirus Evasion:**
   By injecting code before security solutions fully activate, Early Bird Injection can evade traditional antivirus detection mechanisms, giving attackers a window to execute malicious code undetected.

3. **Custom Initialization:**
   Developers can harness Early Bird Injection to customize process initialization, load additional resources, or modify process behavior before the main application logic begins.

IV. **Challenges and Defensive Strategies**

1. **Behavioral Analysis:**
   Detecting Early Bird Injection requires a focus on behavioral analysis, monitoring for unusual process creation sequences and code injections occurring outside the expected flow.

2. **Memory Protection and Monitoring:**
   Employing memory protection mechanisms and runtime monitoring can help identify unauthorized modifications to process creation data structures.

3. **System Call Monitoring and Whitelisting:**
   Implementing system call monitoring and whitelisting can prevent unauthorized modifications to process creation routines, hindering Early Bird Injection attempts.


### Conclusion

Early Bird Injection stands as a testament to the ongoing innovation in the fields of software development and cybersecurity. Its ability to inject code into processes during their initial moments of creation unveils new dimensions of control and manipulation. As we delve into the intricacies of Early Bird Injection, the importance of ethical considerations underscores the need for responsible usage, reminding us of the delicate balance between pushing boundaries and ensuring the security and integrity of digital landscapes.


## APC Injection:

### Introduction

In the ever-evolving landscape of code injection techniques, Asynchronous Procedure Call (APC) Injection stands out as a formidable method that exploits the intricacies of multitasking environments to execute code within the context of a target process. With the ability to subtly leverage the Windows operating system's thread scheduling mechanism, this advanced technique offers developers, reverse engineers, and cybersecurity experts a powerful means to manipulate processes, evade detection, and gain a deeper understanding of software behavior. This article embarks on an in-depth exploration of APC Injection, delving into its mechanics, practical applications, and the intricate dance it performs in the realm of cybersecurity.

I. **APC Injection: Paving the Way for Asynchronous Control**

At its core, APC Injection revolves around the concept of Asynchronous Procedure Calls, a Windows mechanism that allows functions to be scheduled for execution in the context of a specific thread. By injecting an APC into a target thread, attackers can subtly influence the execution flow, ushering in a new realm of control and manipulation.

II. **The Intricacies of APC Injection**

1. **Thread Selection and APC Queuing:**
   APC Injection begins with the selection of a target thread within the process of interest. Once a suitable thread is identified, the attacker leverages system functions to queue an APC, a small unit of work, for execution within the chosen thread's context.

2. **Payload Injection and Execution:**
   Following APC queuing, the attacker injects code or a payload into the target process. This payload, often containing malicious instructions or a desired action, is designed to execute when the target thread enters an alertable state, initiating the queued APC.

III. **Applications and Advantages**

1. **Stealth and Evasion:**
   APC Injection's ability to exploit the thread scheduling mechanism makes it a stealthy technique that evades traditional thread creation and module injection detection mechanisms.

2. **Bypassing Process Protections:**
   This technique can bypass process-level security mechanisms by piggybacking on legitimate threads, granting attackers a path to execute code within a target process.

3. **Injection into Remote Processes:**
   APC Injection can be leveraged remotely, allowing attackers to inject code into processes running on another system, thereby expanding its reach and potential impact.

IV. **Challenges and Defensive Strategies**

1. **Behavioral Analysis:**
   Detecting APC Injection necessitates behavioral analysis, focusing on unusual thread behaviors, APC queuing, and unexpected execution flows within a process.

2. **APC Monitoring and Whitelisting:**
   Employing APC monitoring and whitelisting can help prevent unauthorized APC queuing, adding an extra layer of protection against this type of injection.

3. **Memory Protection and Sandbox Limitations:**
   Memory protection mechanisms and sandboxing may offer limited defense against APC Injection due to its subtle exploitation of legitimate thread execution.

### Conclusion

APC Injection emerges as a testament to the ingenuity that fuels the realms of software development and cybersecurity. Its ability to manipulate thread scheduling and execute code asynchronously within processes signifies a new era of control and influence. As we navigate the intricacies of APC Injection, the importance of ethical usage echoes in the background, underscoring the delicate balance between innovation, security, and responsible exploration in the dynamic landscape of digital domains.

## AtomBombing:

### Introduction

In the realm of advanced code injection techniques, AtomBombing stands as an enigmatic and innovative method that capitalizes on the Windows operating system's Global Atom Table to execute code within the context of a target process. This technique, while lesser-known than some of its counterparts, offers developers, reverse engineers, and cybersecurity experts a unique avenue for manipulation, evasion, and insight into software behavior. This article embarks on a comprehensive exploration of AtomBombing, peeling back the layers of its intricacies, real-world applications, and the delicate dance it performs at the intersection of innovation and security.

I. **AtomBombing: Tapping into the Global Atom Table**

At its core, AtomBombing leverages the Global Atom Table, a data structure within Windows that stores strings and other data for quick retrieval. This technique involves crafting a carefully orchestrated sequence of actions to manipulate the Atom Table and execute code within a target process's context.

II. **Decoding the Mechanism of AtomBombing**

1. **Atom Table Manipulation:**
   AtomBombing begins with the manipulation of the Global Atom Table. Attackers create specially crafted atom names, corresponding to pieces of executable code or data, which are then inserted into the Atom Table.

2. **Triggering Code Execution:**
   Once the manipulated atom names are in place, the attacker proceeds to invoke specific Windows API functions that trigger the retrieval and execution of the code associated with the manipulated atom. This leads to the execution of malicious code within the target process.

III. **Applications and Advantages**

1. **Innovative Evasion:**
   AtomBombing's reliance on the Atom Table allows it to bypass traditional detection mechanisms that focus on more well-known injection methods, making it a potent technique for evading security measures.

2. **Stealth and Persistence:**
   By executing code within the context of a legitimate process, AtomBombing achieves a level of stealth and persistence that can pose challenges for detection and removal.

IV. **Challenges and Defensive Strategies**

1. **Behavioral Analysis:**
   Detecting AtomBombing requires a behavioral analysis approach that monitors unusual interactions with the Atom Table and unexpected code execution patterns.

2. **Memory Monitoring and Code Integrity Checks:**
   Employing memory monitoring and integrity checks on critical process structures can help identify unauthorized interactions with the Atom Table and code execution attempts.

### Conclusion

AtomBombing emerges as a testament to the ongoing innovation in the fields of software development and cybersecurity. Its ability to exploit the Global Atom Table to execute code within a target process's context introduces a novel dimension of control and manipulation. As we delve into the intricacies of AtomBombing, the importance of ethical considerations becomes evident, highlighting the ever-present need for responsible exploration and usage in the dynamic landscape of digital domains.

## Process Doppelgänging:
### Introduction

In the realm of advanced code injection techniques, Process Doppelgänging stands as a revolutionary method that operates at an intricate and low-level, enabling developers, reverse engineers, and cybersecurity experts to inject code into processes with remarkable stealth and evasiveness. By creating a duplicate of a legitimate process in a suspended state and then replacing its memory with custom code, this technique offers an unprecedented level of control, bypassing traditional detection mechanisms and highlighting the intricate dance between innovation and security. This article embarks on a comprehensive exploration of Process Doppelgänging, peeling back its layers to uncover its inner workings, real-world applications, and the challenges it presents to both defenders and adversaries.

I. **Process Doppelgänging: A Prelude to Code Injection**

Process Doppelgänging revolves around the creation of a ghost process, which acts as a vessel for injecting and executing custom code within a target process. This technique relies on the intricacies of process creation, memory mapping, and dynamic linking to achieve its goals.

II. **Deciphering the Mechanism of Process Doppelgänging**

1. **Process Cloning and Suspension:**
   Process Doppelgänging begins with the cloning of a legitimate process using Windows API functions. The cloned process is then suspended, placing it in a state where its memory can be manipulated.

2. **Memory Mapping and Code Injection:**
   Custom code is injected into the suspended process's memory space. This injected code could be shellcode, payloads, or even complete DLLs. The process's memory structures are meticulously modified to accommodate the injected code.

3. **Context Restoration and Execution:**
   After the injected code is in place, the suspended process's context is restored, and the code is executed. The injected code effectively runs within the context of the legitimate process, blurring the lines between the attacker's code and the host process.

III. **Applications and Advantages**

1. **Evasion and Stealth:**
   Process Doppelgänging evades many traditional detection mechanisms due to its unique approach of duplicating and manipulating legitimate processes, making it an attractive technique for malicious actors seeking to bypass security measures.

2. **Memory Analysis Resistance:**
   The stealthiness of Process Doppelgänging poses a challenge for memory analysis and forensic techniques, as the injected code resides within the context of a legitimate process.

IV. **Challenges and Defensive Strategies**

1. **Behavioral Analysis:**
   Detecting Process Doppelgänging requires behavioral analysis that monitors for unusual process creation, memory manipulation, and code execution patterns.

2. **Memory Integrity Checks and Sandboxing:**
   Employing memory integrity checks and sandboxes can help identify unauthorized memory modifications and code injection attempts.
### Conclusion

Process Doppelgänging emerges as a testament to the relentless innovation in software development and cybersecurity. Its ability to duplicate and manipulate processes, injecting code with remarkable stealth, introduces a new realm of control and manipulation. As we explore the intricacies of Process Doppelgänging, the importance of ethical considerations and responsible usage resonates, emphasizing the need for a delicate balance between pushing boundaries and safeguarding the security and integrity of digital landscapes.

## QueueUserAPC Malware Injection:

### Introduction

In the intricate realm of advanced code injection techniques, QueueUserAPC Malware Injection stands out as a method that creatively leverages the Windows Asynchronous Procedure Call (APC) mechanism for executing code within a target process's context. By harnessing the power of APCs and queueing them to an existing thread, developers, reverse engineers, and cybersecurity experts can subtly introduce custom code, offering a unique avenue for process manipulation, evasion, and insight. This article embarks on an in-depth exploration of QueueUserAPC Malware Injection, uncovering its inner workings, practical applications, and the intricate dynamics it introduces to the ever-evolving landscape of cybersecurity.

I. **QueueUserAPC Malware Injection: Navigating the Asynchronous Call Realm**

QueueUserAPC Malware Injection revolves around the concept of manipulating the Asynchronous Procedure Call mechanism in Windows to execute custom code within the context of a target process. This technique introduces a method of asynchronous interaction with threads, offering opportunities for controlled execution.

II. **The Choreography of QueueUserAPC Malware Injection**

1. **Thread Selection and APC Queueing:**
   QueueUserAPC Malware Injection begins with the identification of a suitable target thread within the process. The attacker then queues an APC, a designated unit of work, to the selected thread.

2. **Payload Injection and APC Execution:**
   With the APC queued, the attacker injects custom code or a payload into the target process. This injected payload is designed to execute when the target thread enters an alertable state, triggering the queued APC and initiating the execution of the malicious code.

III. **Applications and Advantages**

1. **Stealthy Operation:**
   QueueUserAPC Malware Injection operates with stealth, taking advantage of legitimate thread behavior and the asynchronous nature of APCs, which makes it a challenging technique to detect.

2. **Process Manipulation:**
   Attackers can manipulate the execution flow of a target process by injecting code at specific points in its execution timeline, enabling fine-grained control and interaction.

IV. **Challenges and Defensive Strategies**

1. **Behavioral Analysis:**
   Detecting QueueUserAPC Malware Injection requires behavioral analysis, focusing on monitoring for unusual thread behavior, APC queueing, and unexpected execution patterns.

2. **Memory Protection and Whitelisting:**
   Employing memory protection mechanisms and whitelisting of authorized APC queueing can help prevent unauthorized interactions and code execution attempts.
### Conclusion

QueueUserAPC Malware Injection stands as a testament to the ingenuity that drives software development and cybersecurity. Its ability to manipulate thread execution asynchronously through the APC mechanism introduces a new dimension of control and influence. As we navigate the intricacies of QueueUserAPC Malware Injection, the importance of responsible exploration becomes evident, emphasizing the delicate balance between innovation, security, and ethical considerations in the dynamic landscape of digital domains.