//
//  OSConcepts.swift
//  DevAscent
//
//  Operating System CS Concepts - Comprehensive Interview Questions
//

import Foundation

struct OSConcepts {
    static func all() -> [CSConcept] {
        return [
            // MARK: - Process Management
            CSConcept(
                category: .os,
                question: "What is a process and process table?",
                answer: """
                **Process:** An instance of a program in execution. Example: browser, shell.

                **Process Table:** OS maintains this table to track all processes. Contains:
                - Process ID (PID)
                - Process state
                - CPU registers
                - Memory allocation info
                - I/O status
                - Accounting info
                """,
                tags: ["process", "fundamentals"]
            ),
            CSConcept(
                category: .os,
                question: "What are the different states of a process?",
                answer: """
                **5 Process States:**
                1. **New** - Process being created
                2. **Ready** - Waiting for CPU allocation
                3. **Running** - Currently executing on CPU
                4. **Waiting/Blocked** - Waiting for I/O or event
                5. **Terminated** - Finished execution

                Ready and Waiting states are implemented as queues.
                """,
                tags: ["process", "states"]
            ),
            CSConcept(
                category: .os,
                question: "What is a Thread?",
                answer: """
                A thread is a single sequence stream within a process (lightweight process).

                **Properties:**
                - Shares code, data, heap with parent process
                - Has own stack, registers, program counter
                - Enables parallelism within a process

                **Example:** Browser tabs, MS Word (formatting + input threads)
                """,
                tags: ["thread", "concurrency"]
            ),
            CSConcept(
                category: .os,
                question: "Process vs Thread differences?",
                answer: """
                | Aspect | Process | Thread |
                |--------|---------|--------|
                | Memory | Own address space | Shares parent's memory |
                | Communication | IPC (slower) | Shared memory (faster) |
                | Context Switch | Heavy | Lightweight |
                | Isolation | Independent | Shares resources |
                | Creation | Expensive | Cheap |
                """,
                tags: ["process", "thread", "comparison"]
            ),
            CSConcept(
                category: .os,
                question: "What is Context Switching?",
                answer: """
                Saving state of old process and loading state for new process.

                **Steps:**
                1. Save current process state to PCB
                2. Update PCB with new state
                3. Move PCB to appropriate queue
                4. Select new process from ready queue
                5. Load new process state from its PCB
                6. Update memory management structures

                **Overhead:** CPU time spent switching (not doing useful work)
                """,
                tags: ["context switch", "scheduling"]
            ),
            CSConcept(
                category: .os,
                question: "What is PCB (Process Control Block)?",
                answer: """
                Data structure containing all info about a process:

                - **Process ID (PID)**
                - **Process State** (ready, running, waiting)
                - **Program Counter** (next instruction)
                - **CPU Registers**
                - **Memory Management Info** (page tables, segment tables)
                - **I/O Status** (open files, devices)
                - **Scheduling Info** (priority, quantum)
                """,
                tags: ["PCB", "process"]
            ),
            CSConcept(
                category: .os,
                question: "What is a Zombie Process?",
                answer: """
                A process that has finished execution but still has entry in process table.

                **Why it exists:** Parent needs to read child's exit status

                **Problem:** If parent doesn't call wait(), zombie remains

                **Solution:** Parent calls wait()/waitpid() to reap child
                """,
                tags: ["zombie", "process"]
            ),
            CSConcept(
                category: .os,
                question: "What is an Orphan Process?",
                answer: """
                A process whose parent has terminated without waiting for it.

                **What happens:** init process (PID 1) adopts orphans

                **Difference from Zombie:**
                - Zombie: Child finished, parent alive but didn't wait
                - Orphan: Parent died, child still running
                """,
                tags: ["orphan", "process"]
            ),
            
            // MARK: - CPU Scheduling
            CSConcept(
                category: .os,
                question: "What are CPU Scheduling Algorithms?",
                answer: """
                1. **FCFS** - First Come First Served (non-preemptive)
                2. **SJF** - Shortest Job First
                3. **SRTF** - Shortest Remaining Time First
                4. **Priority** - Based on priority values
                5. **Round Robin** - Time quantum based
                6. **Multilevel Queue** - Multiple queues with different priorities
                """,
                tags: ["scheduling", "algorithms"]
            ),
            CSConcept(
                category: .os,
                question: "Explain Round Robin Scheduling",
                answer: """
                Each process gets a fixed time quantum (typically 10-100ms).

                **Properties:**
                - Preemptive
                - Cyclic (no starvation)
                - Fair to all processes
                - Also called Time Slicing

                **Trade-off:** Small quantum = more context switches, Large quantum = approaches FCFS
                """,
                tags: ["round robin", "scheduling"]
            ),
            CSConcept(
                category: .os,
                question: "Preemptive vs Non-Preemptive Scheduling?",
                answer: """
                | Aspect | Preemptive | Non-Preemptive |
                |--------|------------|----------------|
                | Interruption | CPU can be taken away | Process runs until completion |
                | Starvation | Less likely | More likely |
                | Overhead | Higher (switching) | Lower |
                | Response Time | Better | Worse |
                | Examples | RR, SRTF, Priority | FCFS, SJF |
                """,
                tags: ["preemptive", "scheduling"]
            ),
            CSConcept(
                category: .os,
                question: "What is a Dispatcher?",
                answer: """
                Module that gives CPU control to process selected by scheduler.

                **Functions:**
                1. Context switching
                2. Switching to user mode
                3. Jump to proper location in user program

                **Dispatch Latency:** Time from stopping one process to starting another
                """,
                tags: ["dispatcher", "scheduling"]
            ),
            
            // MARK: - Synchronization
            CSConcept(
                category: .os,
                question: "What is a Critical Section?",
                answer: """
                Code segment where shared resources are accessed.

                **Requirements (must satisfy all 3):**
                1. **Mutual Exclusion** - Only one process at a time
                2. **Progress** - If no one in CS, selection can't be postponed
                3. **Bounded Waiting** - Limit on wait time

                **Solutions:** Mutex, Semaphores, Monitors
                """,
                tags: ["critical section", "synchronization"]
            ),
            CSConcept(
                category: .os,
                question: "What is a Semaphore?",
                answer: """
                Synchronization primitive with two atomic operations:

                **wait(S):** `while(S <= 0); S--;`
                **signal(S):** `S++;`

                **Types:**
                - **Binary (0 or 1)** - Like mutex
                - **Counting** - For multiple resources

                **Advantage:** No busy waiting (block instead of spin)
                """,
                tags: ["semaphore", "synchronization"]
            ),
            CSConcept(
                category: .os,
                question: "What is a Mutex vs Semaphore?",
                answer: """
                | Mutex | Semaphore |
                |-------|-----------|
                | Binary only | Can be counting |
                | Ownership (only locker unlocks) | No ownership |
                | For mutual exclusion | For signaling & sync |
                | One thread at a time | Multiple threads possible |
                """,
                tags: ["mutex", "semaphore", "comparison"]
            ),
            CSConcept(
                category: .os,
                question: "Classic Synchronization Problems?",
                answer: """
                1. **Producer-Consumer** (Bounded Buffer)
                2. **Readers-Writers** Problem
                3. **Dining Philosophers**
                4. **Sleeping Barber**

                All demonstrate synchronization challenges and use semaphores/mutex for solutions.
                """,
                tags: ["synchronization", "problems"]
            ),
            
            // MARK: - Deadlock
            CSConcept(
                category: .os,
                question: "What is Deadlock?",
                answer: """
                Situation where processes wait for each other indefinitely.

                **4 Necessary Conditions (all must hold):**
                1. **Mutual Exclusion**
                2. **Hold and Wait**
                3. **No Preemption**
                4. **Circular Wait**

                **Handling:** Prevention, Avoidance, Detection & Recovery
                """,
                tags: ["deadlock", "conditions"]
            ),
            CSConcept(
                category: .os,
                question: "What is Banker's Algorithm?",
                answer: """
                Deadlock avoidance algorithm that checks safe state before allocation.

                **Data Structures:**
                - Available[m] - Available resources
                - Max[n][m] - Maximum demand
                - Allocation[n][m] - Currently allocated
                - Need[n][m] = Max - Allocation

                **Safe State:** Exists sequence where all can complete
                """,
                tags: ["banker", "deadlock", "avoidance"]
            ),
            CSConcept(
                category: .os,
                question: "Starvation vs Deadlock?",
                answer: """
                | Starvation | Deadlock |
                |------------|----------|
                | Process waits indefinitely | Processes wait for each other |
                | Can happen with 1 process | Needs 2+ processes |
                | Low priority issue | Circular wait issue |
                | Solution: Aging | Solution: Break conditions |
                """,
                tags: ["starvation", "deadlock", "comparison"]
            ),
            
            // MARK: - Memory Management
            CSConcept(
                category: .os,
                question: "What is Virtual Memory?",
                answer: """
                Illusion of large contiguous memory using disk as extension of RAM.

                **Benefits:**
                - Programs larger than physical memory can run
                - Better memory utilization
                - Process isolation

                **Implementation:** Demand paging - load pages only when needed
                """,
                tags: ["virtual memory", "paging"]
            ),
            CSConcept(
                category: .os,
                question: "What is Demand Paging?",
                answer: """
                Load pages into memory only when needed (on page fault).

                **Working:**
                1. Access page not in memory
                2. Page fault occurs
                3. OS finds page on disk
                4. Load into free frame
                5. Update page table
                6. Restart instruction
                """,
                tags: ["demand paging", "virtual memory"]
            ),
            CSConcept(
                category: .os,
                question: "What is Thrashing?",
                answer: """
                System spends more time paging than executing.

                **Cause:** Too many processes, not enough frames per process

                **Symptoms:**
                - High page fault rate
                - Low CPU utilization
                - System feels unresponsive

                **Solution:** Working set model, decrease multiprogramming
                """,
                tags: ["thrashing", "paging"]
            ),
            CSConcept(
                category: .os,
                question: "Page Replacement Algorithms?",
                answer: """
                When no free frame, which page to evict?

                1. **FIFO** - Replace oldest page
                2. **LRU** - Replace least recently used
                3. **Optimal** - Replace page not needed for longest (theoretical)
                4. **Clock (Second Chance)** - FIFO with reference bit

                **Belady's Anomaly:** More frames → more faults (only FIFO)
                """,
                tags: ["page replacement", "LRU", "FIFO"]
            ),
            CSConcept(
                category: .os,
                question: "Logical vs Physical Address?",
                answer: """
                | Logical (Virtual) | Physical |
                |-------------------|----------|
                | Generated by CPU | Actual RAM location |
                | User sees this | Hidden from user |
                | Translated by MMU | Final address |
                | Per-process space | Global RAM space |
                """,
                tags: ["address", "memory"]
            ),
            CSConcept(
                category: .os,
                question: "Paging vs Segmentation?",
                answer: """
                | Paging | Segmentation |
                |--------|--------------|
                | Fixed-size blocks | Variable-size blocks |
                | Internal fragmentation | External fragmentation |
                | Invisible to user | User visible |
                | Page table | Segment table |
                | No logical division | Logical division (code, data) |
                """,
                tags: ["paging", "segmentation"]
            ),
            CSConcept(
                category: .os,
                question: "Internal vs External Fragmentation?",
                answer: """
                **Internal:**
                - Wasted space INSIDE allocated block
                - Fixed-size allocation (paging)
                - Solution: Best-fit allocation

                **External:**
                - Wasted space BETWEEN allocated blocks
                - Variable-size allocation (segmentation)
                - Solution: Compaction, Paging
                """,
                tags: ["fragmentation", "memory"]
            ),
            
            // MARK: - I/O & Disk
            CSConcept(
                category: .os,
                question: "What is Spooling?",
                answer: """
                Simultaneous Peripheral Operations Online

                Data temporarily stored in buffer (memory/disk) before slow device access.

                **Example:** Print spooling - documents queue up, printer processes at own speed

                **Benefit:** CPU doesn't wait for slow I/O devices
                """,
                tags: ["spooling", "I/O"]
            ),
            CSConcept(
                category: .os,
                question: "What is DMA (Direct Memory Access)?",
                answer: """
                I/O device transfers data directly to/from memory without CPU.

                **Benefits:**
                - CPU freed for other work
                - Faster large data transfers
                - Reduced CPU overhead

                **DMA Controller (DMAC)** manages the transfer
                """,
                tags: ["DMA", "I/O"]
            ),
            CSConcept(
                category: .os,
                question: "Disk Scheduling Algorithms?",
                answer: """
                1. **FCFS** - First Come First Served
                2. **SSTF** - Shortest Seek Time First
                3. **SCAN (Elevator)** - Move in one direction, then reverse
                4. **C-SCAN** - Circular SCAN, go to beginning after end
                5. **LOOK** - Like SCAN but only go to last request

                **Goal:** Minimize seek time
                """,
                tags: ["disk scheduling", "algorithms"]
            ),
            CSConcept(
                category: .os,
                question: "What are RAID Levels?",
                answer: """
                Redundant Array of Independent Disks

                - **RAID 0:** Striping (no redundancy, fast)
                - **RAID 1:** Mirroring (full redundancy)
                - **RAID 5:** Striping + distributed parity
                - **RAID 6:** Striping + double parity
                - **RAID 10:** Mirroring + Striping

                Trade-offs: Performance vs Redundancy vs Cost
                """,
                tags: ["RAID", "disk"]
            ),
            
            // MARK: - Kernel & System Calls
            CSConcept(
                category: .os,
                question: "What is the Kernel?",
                answer: """
                Core component of OS - bridge between hardware and applications.

                **Functions:**
                - Process management
                - Memory management
                - Device management
                - System calls handling

                **Types:** Monolithic, Microkernel, Hybrid
                """,
                tags: ["kernel", "fundamentals"]
            ),
            CSConcept(
                category: .os,
                question: "Monolithic vs Microkernel?",
                answer: """
                | Monolithic | Microkernel |
                |------------|-------------|
                | All services in kernel | Minimal kernel |
                | Faster (no IPC) | Slower (IPC overhead) |
                | Less secure | More secure |
                | Example: Linux | Example: Minix |
                """,
                tags: ["kernel", "comparison"]
            ),
            CSConcept(
                category: .os,
                question: "What is an Interrupt?",
                answer: """
                Signal to CPU that event needs immediate attention.

                **Types:**
                - **Hardware:** From I/O devices
                - **Software (Trap):** From programs (system call, exception)

                **ISR (Interrupt Service Routine):** Handler code for interrupt
                """,
                tags: ["interrupt", "fundamentals"]
            ),
            CSConcept(
                category: .os,
                question: "What is a System Call?",
                answer: """
                Interface for user programs to request OS services.

                **Categories:**
                1. Process control (fork, exec, exit)
                2. File management (open, read, write, close)
                3. Device management (ioctl)
                4. Information (getpid, time)
                5. Communication (pipe, shmget)

                Triggers switch from user mode to kernel mode
                """,
                tags: ["system call", "kernel"]
            ),
            
            // MARK: - IPC
            CSConcept(
                category: .os,
                question: "What is IPC (Inter-Process Communication)?",
                answer: """
                Mechanisms for processes to communicate and synchronize.

                **Methods:**
                1. **Pipes** - Unidirectional, same origin
                2. **Named Pipes (FIFO)** - Different processes
                3. **Message Queues** - Kernel-managed messages
                4. **Shared Memory** - Fastest, direct memory sharing
                5. **Semaphores** - Synchronization
                6. **Sockets** - Network communication
                """,
                tags: ["IPC", "communication"]
            ),
            CSConcept(
                category: .os,
                question: "What is a Pipe?",
                answer: """
                One-way communication channel between related processes.

                **Characteristics:**
                - Unidirectional
                - FIFO order
                - Between parent-child or sibling processes
                - Created with pipe() system call

                **Named Pipe (FIFO):** Can be used between unrelated processes
                """,
                tags: ["pipe", "IPC"]
            ),
            
            // MARK: - Miscellaneous
            CSConcept(
                category: .os,
                question: "Multiprogramming vs Multitasking?",
                answer: """
                **Multiprogramming:**
                - Multiple programs in memory
                - CPU switches when one blocks
                - Goal: CPU utilization

                **Multitasking:**
                - CPU switches frequently (time-sharing)
                - User can interact with each program
                - Goal: Responsiveness
                """,
                tags: ["multiprogramming", "multitasking"]
            ),
            CSConcept(
                category: .os,
                question: "What is Time-Sharing?",
                answer: """
                Logical extension of multiprogramming.

                CPU switches so frequently that users can interact with each program while running.

                **Enables:**
                - Multiple users on same computer
                - Interactive computing
                - Fair resource sharing
                """,
                tags: ["time-sharing", "multitasking"]
            ),
            CSConcept(
                category: .os,
                question: "What is a Buffer?",
                answer: """
                Memory area for temporary data storage during transfer.

                **Uses:**
                - Speed mismatch between devices
                - Data size mismatch
                - Copy semantics

                **Types:** Single, Double, Circular buffer
                """,
                tags: ["buffer", "I/O"]
            ),
            CSConcept(
                category: .os,
                question: "What is Caching?",
                answer: """
                Storing copies of frequently accessed data in faster memory.

                **Cache Hierarchy:**
                - L1 (fastest, smallest)
                - L2
                - L3
                - RAM
                - Disk

                **Goal:** Reduce average memory access time
                """,
                tags: ["caching", "memory"]
            ),
            CSConcept(
                category: .os,
                question: "What is the Bootstrap Program?",
                answer: """
                First program that runs when computer boots.

                **Functions:**
                1. POST (Power-On Self-Test)
                2. Initialize hardware
                3. Locate OS kernel on disk
                4. Load kernel into memory
                5. Transfer control to kernel
                """,
                tags: ["bootstrap", "boot"]
            ),
            CSConcept(
                category: .os,
                question: "What is Belady's Anomaly?",
                answer: """
                Counter-intuitive phenomenon: More page frames can cause MORE page faults.

                **Occurs with:** FIFO page replacement only

                **Does NOT occur with:** LRU, Optimal (stack algorithms)

                Example: 1,2,3,4,1,2,5,1,2,3,4,5 sequence
                """,
                tags: ["belady", "page replacement"]
            ),
            CSConcept(
                category: .os,
                question: "What is Peterson's Solution?",
                answer: """
                Software solution for 2-process critical section problem.

                **Uses:**
                - `flag[2]` - Process wants to enter
                - `turn` - Whose turn it is

                **Satisfies:** Mutual exclusion, Progress, Bounded waiting

                **Limitation:** Only 2 processes, busy waiting
                """,
                tags: ["peterson", "synchronization"]
            ),
            CSConcept(
                category: .os,
                question: "What is Aging in Scheduling?",
                answer: """
                Technique to prevent starvation.

                Gradually increase priority of waiting processes over time.

                **Example:** Increase priority by 1 every 15 minutes of waiting

                Used in priority scheduling to ensure all processes eventually run.
                """,
                tags: ["aging", "scheduling", "starvation"]
            ),
            CSConcept(
                category: .os,
                question: "What is Locality of Reference?",
                answer: """
                Programs tend to access same memory locations repeatedly.

                **Types:**
                1. **Temporal:** Recently accessed → likely accessed again
                2. **Spatial:** Nearby addresses → likely accessed

                **Exploited by:** Caching, Prefetching, Virtual Memory
                """,
                tags: ["locality", "memory"]
            ),
            CSConcept(
                category: .os,
                question: "What is Cycle Stealing?",
                answer: """
                DMA controller uses bus cycles that CPU would otherwise use.

                CPU and DMA alternate access to memory/bus.

                **Benefit:** More efficient than busy waiting
                **Cost:** Slight CPU slowdown
                """,
                tags: ["cycle stealing", "DMA"]
            ),
            CSConcept(
                category: .os,
                question: "Goals of CPU Scheduling?",
                answer: """
                1. **Max CPU Utilization** - Keep CPU busy
                2. **Max Throughput** - Processes completed per unit time
                3. **Min Turnaround Time** - Total time from submission to completion
                4. **Min Waiting Time** - Time spent in ready queue
                5. **Min Response Time** - Time to first response
                6. **Fairness** - Equal CPU share to each process
                """,
                tags: ["scheduling", "goals"]
            ),
            CSConcept(
                category: .os,
                question: "What is Compaction?",
                answer: """
                Moving processes to one end of memory to create large contiguous free block.

                **Solution for:** External fragmentation

                **Drawbacks:**
                - All processes must be relocated
                - Time-consuming
                - CPU overhead

                **Alternative:** Paging (avoids external fragmentation)
                """,
                tags: ["compaction", "memory"]
            ),
            CSConcept(
                category: .os,
                question: "What is Overlays?",
                answer: """
                Old technique for running programs larger than memory.

                **Concept:**
                - Divide program into independent modules
                - Load only needed module at a time
                - Replace with next module when done

                **Replaced by:** Virtual memory (automatic)
                """,
                tags: ["overlays", "memory"]
            ),
            CSConcept(
                category: .os,
                question: "What is Dynamic Loading?",
                answer: """
                Routine not loaded until called.

                **Benefits:**
                - Better memory utilization
                - Unused routines never loaded
                - Useful for error handling code (rarely used)

                **No special OS support needed** - programmer implements
                """,
                tags: ["dynamic loading", "memory"]
            ),
            CSConcept(
                category: .os,
                question: "What is Seek Time and Rotational Latency?",
                answer: """
                **Seek Time:**
                Time to move disk arm to correct track/cylinder

                **Rotational Latency:**
                Time for desired sector to rotate under read/write head

                **Average Rotational Latency:** Half rotation time

                **Total Access Time:** Seek Time + Rotational Latency + Transfer Time
                """,
                tags: ["disk", "latency"]
            ),
            CSConcept(
                category: .os,
                question: "How to recover from Deadlock?",
                answer: """
                **1. Process Termination:**
                - Abort all deadlocked processes
                - OR abort one at a time until resolved

                **2. Resource Preemption:**
                - Take resources from victim process
                - Rollback to safe state

                **Considerations:** Cost, priority, resources held
                """,
                tags: ["deadlock", "recovery"]
            ),
            CSConcept(
                category: .os,
                question: "What is Swapping?",
                answer: """
                Moving entire process between main memory and disk.

                **Swap Out:** Process moved from RAM to disk (backing store)
                **Swap In:** Process moved from disk back to RAM

                **Purpose:** More processes can be scheduled than fit in memory

                **Different from Paging:** Entire process vs individual pages
                """,
                tags: ["swapping", "memory"]
            )
        ]
    }
}
