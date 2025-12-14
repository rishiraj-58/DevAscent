//
//  OSConcepts.swift
//  DevAscent
//
//  Operating System CS Concepts
//

import Foundation

struct OSConcepts {
    static func all() -> [CSConcept] {
        return [
            CSConcept(
                category: .os,
                question: "Process vs Thread - Key Differences",
                answer: """
                **Process:**
                - Independent execution unit with own memory space
                - Heavy context switch (TLB flush, page tables)
                - Inter-process communication via IPC (pipes, shared memory)

                **Thread:**
                - Lightweight, shares process memory
                - Faster context switch (same address space)
                - Communication via shared variables (need synchronization)

                **Key Point:** Threads within a process share heap but have separate stacks.
                """,
                tags: ["process", "thread", "concurrency"]
            ),
            CSConcept(
                category: .os,
                question: "Deadlock - 4 Necessary Conditions",
                answer: """
                All 4 conditions must hold simultaneously (Coffman conditions):

                1. **Mutual Exclusion:** Resource can only be held by one process
                2. **Hold and Wait:** Process holds resources while waiting for others
                3. **No Preemption:** Resources cannot be forcibly taken
                4. **Circular Wait:** Circular chain of processes waiting for each other

                **Prevention:** Break any one condition
                **Detection:** Resource allocation graph with cycle detection
                """,
                tags: ["deadlock", "concurrency", "synchronization"]
            ),
            CSConcept(
                category: .os,
                question: "Virtual Memory - Page Fault Handling",
                answer: """
                1. CPU generates virtual address
                2. MMU checks page table → Page not in RAM (invalid bit)
                3. **Page Fault** trap to OS
                4. OS finds page on disk (swap space)
                5. If no free frame → Page replacement (LRU/FIFO)
                6. Load page from disk to RAM
                7. Update page table, set valid bit
                8. Restart instruction

                **Thrashing:** When system spends more time paging than executing
                """,
                tags: ["virtual memory", "paging", "page fault"]
            )
        ]
    }
}
