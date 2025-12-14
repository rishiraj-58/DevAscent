//
//  JavaConcepts.swift
//  DevAscent
//
//  Java CS Concepts
//

import Foundation

struct JavaConcepts {
    static func all() -> [CSConcept] {
        return [
            CSConcept(
                category: .java,
                question: "HashMap Internals (Java 8+)",
                answer: """
                **Structure:**
                - Array of buckets (default 16)
                - Each bucket: LinkedList → TreeMap (when >8 nodes)

                **Hashing:**
                ```
                index = (n-1) & hash(key.hashCode())
                ```

                **Collision Handling:**
                - Java 7: Linked List (O(n) worst case)
                - Java 8+: Red-Black Tree (O(log n) when ≥8 nodes)

                **Resize:**
                - Load Factor: 0.75
                - When exceeded: Double capacity, rehash all entries

                **Key Methods:**
                - `put()`: hash → bucket → traverse/insert
                - `get()`: hash → bucket → equals() check
                """,
                tags: ["HashMap", "data structures", "hashing"]
            ),
            CSConcept(
                category: .java,
                question: "volatile vs synchronized",
                answer: """
                **volatile:**
                - Visibility guarantee only
                - Reads/writes go to main memory
                - No atomicity for compound operations (i++)
                - No blocking

                **synchronized:**
                - Visibility + Atomicity + Mutual exclusion
                - Acquires lock (monitor)
                - Blocking (other threads wait)
                - Can cause deadlock

                **Use volatile when:**
                - Single writer, multiple readers
                - Simple flag/status variable
                - Happens-before relationship needed

                **Use synchronized when:**
                - Multiple writers
                - Compound operations (check-then-act)
                - Need mutual exclusion
                """,
                tags: ["volatile", "synchronized", "concurrency", "visibility"]
            ),
            CSConcept(
                category: .java,
                question: "Garbage Collection - Generations",
                answer: """
                **Generational Hypothesis:** Most objects die young

                **Heap Structure:**
                1. **Young Generation:**
                   - Eden (new objects allocated here)
                   - Survivor 0 & Survivor 1 (survivors of minor GC)
                   - Minor GC: Fast, stop-the-world pause

                2. **Old Generation (Tenured):**
                   - Objects surviving multiple minor GCs
                   - Major GC: Slower, longer pause

                3. **Metaspace (Java 8+):**
                   - Class metadata (replaced PermGen)

                **Common Collectors:**
                - G1 (default in Java 9+)
                - ZGC (ultra-low latency)
                - Shenandoah (concurrent compaction)
                """,
                tags: ["GC", "garbage collection", "heap", "memory"]
            ),
            CSConcept(
                category: .java,
                question: "ReentrantLock vs synchronized",
                answer: """
                **ReentrantLock advantages:**
                - `tryLock()` - non-blocking attempt
                - `lockInterruptibly()` - can be interrupted
                - Fairness policy (FIFO ordering)
                - Multiple Condition objects
                - `tryLock(timeout)` - timed waiting

                **synchronized advantages:**
                - Simpler syntax
                - Automatic release (even on exception)
                - JVM optimizations (biased locking, lock elision)

                **When to use ReentrantLock:**
                - Need tryLock or timed lock
                - Need fairness
                - Need multiple conditions
                - Need interruptible locking
                """,
                tags: ["ReentrantLock", "synchronized", "concurrency", "locks"]
            ),
            CSConcept(
                category: .java,
                question: "HashMap Internals - Architecture",
                answer: """
                Structure: Array of Node<K,V> buckets

                Put Operation:
                1. Calculate hash: hash(key) = key.hashCode() ^ (h >>> 16)
                2. Find bucket: index = hash & (n-1)
                3. If empty → insert Node
                4. If collision → add to linked list
                5. If list size >= 8 → convert to Red-Black Tree (Java 8+)
                6. If size > threshold → resize (2x capacity)

                Get Operation: O(1) average, O(log n) worst (tree)

                Load Factor: 0.75 (default) - triggers resize at 75% capacity
                """,
                tags: ["HashMap", "hashing", "collections", "data structures"]
            ),
            CSConcept(
                category: .java,
                question: "hashCode() & equals() Contract",
                answer: """
                Contract Rules:
                • If a.equals(b) → a.hashCode() == b.hashCode()
                • If hashCode differs → objects are NOT equal
                • hashCode same does NOT mean equals (collision)

                Breaking the Contract:
                • Override equals() only → HashMap finds wrong bucket
                • Override hashCode() only → equals objects in different buckets

                Example broken behavior:
                Set<Person> set = new HashSet<>();
                set.add(new Person("John")); // bucket 5
                set.contains(new Person("John")); // false! different bucket

                Always override BOTH together!
                """,
                tags: ["hashCode", "equals", "collections", "contract"]
            ),
            CSConcept(
                category: .java,
                question: "Creating an Immutable Class",
                answer: """
                Rules for Immutability:
                1. Declare class as final (prevent subclassing)
                2. All fields private and final
                3. No setters
                4. Defensive copy in constructor
                5. Defensive copy in getters (for mutable fields)

                Example:
                public final class ImmutablePerson {
                    private final String name;
                    private final List<String> hobbies;
                    
                    public ImmutablePerson(String name, List<String> hobbies) {
                        this.name = name;
                        this.hobbies = new ArrayList<>(hobbies); // defensive copy
                    }
                    
                    public List<String> getHobbies() {
                        return Collections.unmodifiableList(hobbies);
                    }
                }

                Why String is immutable: Security, caching (String pool), thread-safety
                """,
                tags: ["immutability", "final", "thread-safety", "design"]
            ),
            CSConcept(
                category: .java,
                question: "volatile Keyword - What It Does",
                answer: """
                Guarantees:
                1. Visibility: Changes visible to all threads immediately
                2. Happens-before: All writes before volatile write visible after volatile read
                3. Prevents instruction reordering around volatile

                Does NOT guarantee:
                • Atomicity! count++ is NOT atomic even with volatile

                Use Cases:
                • Flag variables (boolean stop)
                • Double-checked locking (with synchronized)
                • Publishing immutable objects

                Example:
                volatile boolean running = true;
                // Thread 1: running = false;
                // Thread 2: while(running) {} // Will see false immediately

                For atomicity, use AtomicInteger or synchronized
                """,
                tags: ["volatile", "concurrency", "visibility", "memory model"]
            ),
            CSConcept(
                category: .java,
                question: "Executor Framework - Thread Pools",
                answer: """
                submit() vs execute():
                • execute(Runnable) - void, fire-and-forget
                • submit(Callable) - returns Future<T>, can get result

                Thread Pool Types:
                • FixedThreadPool(n): Fixed n threads, queue unbounded
                • CachedThreadPool: Creates threads as needed, reuses idle
                • SingleThreadExecutor: Single thread, sequential execution
                • ScheduledThreadPool: For delayed/periodic tasks

                Best Practices:
                • Fixed for CPU-bound (n = cores)
                • Cached for many short-lived tasks
                • Always shutdown() to prevent memory leaks

                ExecutorService executor = Executors.newFixedThreadPool(4);
                Future<String> result = executor.submit(() -> "Done");
                executor.shutdown();
                """,
                tags: ["Executor", "ThreadPool", "Future", "concurrency"]
            ),
            CSConcept(
                category: .java,
                question: "String Pool & Interning",
                answer: """
                String Literal vs new String:
                String s1 = "abc";        // String Pool (Heap special area)
                String s2 = "abc";        // Same reference as s1
                String s3 = new String("abc"); // New object on Heap

                s1 == s2    // true (same pool reference)
                s1 == s3    // false (different objects)
                s1.equals(s3) // true (same content)

                Interning:
                String s4 = s3.intern(); // Returns pool reference
                s1 == s4    // true!

                Memory: Pool prevents duplicate strings
                GC: Pool strings eligible for GC if no references
                """,
                tags: ["String", "Pool", "intern", "memory"]
            ),
            CSConcept(
                category: .java,
                question: "Stream API Pipeline",
                answer: """
                Stream Pipeline:
                Source → Intermediate Operations → Terminal Operation

                Intermediate (lazy, return Stream):
                • filter(Predicate) - select elements
                • map(Function) - transform elements
                • flatMap(Function) - flatten nested structures
                • sorted() - sort elements
                • distinct() - remove duplicates

                Terminal (trigger execution):
                • collect(Collector) - to List, Set, Map
                • forEach(Consumer) - side effects
                • reduce(BinaryOperator) - aggregate
                • count(), findFirst(), anyMatch()

                Example:
                employees.stream()
                    .filter(e -> e.getSalary() > 50000)
                    .map(Employee::getName)
                    .sorted()
                    .collect(Collectors.toList());
                """,
                tags: ["Stream", "Java 8", "functional", "collections"]
            ),
            CSConcept(
                category: .java,
                question: "ConcurrentHashMap vs HashMap vs Hashtable",
                answer: """
                HashMap:
                • NOT thread-safe
                • Allows one null key, multiple null values
                • Best performance for single-threaded

                Hashtable (legacy):
                • Thread-safe (synchronized methods)
                • No null keys or values
                • Poor performance (locks entire table)

                ConcurrentHashMap:
                • Thread-safe with segment locking (Java 7)
                • Lock striping: 16 segments by default
                • Java 8+: CAS operations, no segments
                • No null keys or values
                • Best for concurrent access

                Read: Lock-free in ConcurrentHashMap
                Write: Only locks affected bucket/segment
                """,
                tags: ["ConcurrentHashMap", "thread-safety", "collections"]
            ),
            CSConcept(
                category: .java,
                question: "ThreadLocal - Use Cases & Dangers",
                answer: """
                What it does:
                • Each thread gets its own copy of variable
                • No synchronization needed
                • Accessed via ThreadLocal.get()/set()

                Use Cases:
                • User session context (Spring SecurityContextHolder)
                • Database connections per thread
                • SimpleDateFormat (not thread-safe)
                • Transaction context

                Dangers:
                • Memory leaks in thread pools!
                • Thread reuse keeps old values
                • ALWAYS use try-finally with remove()

                Example:
                ThreadLocal<User> currentUser = new ThreadLocal<>();
                try {
                    currentUser.set(user);
                    // ... use currentUser.get()
                } finally {
                    currentUser.remove(); // CRITICAL!
                }
                """,
                tags: ["ThreadLocal", "thread-safety", "memory leak"]
            ),
            CSConcept(
                category: .java,
                question: "CompletableFuture - Async Programming",
                answer: """
                Creating:
                CompletableFuture.supplyAsync(() -> compute())
                CompletableFuture.runAsync(() -> sideEffect())

                Chaining:
                • thenApply(fn) - transform result
                • thenAccept(consumer) - consume result
                • thenRun(runnable) - just run
                • thenCompose(fn) - flatMap (returns CF)

                Combining:
                • thenCombine(other, fn) - combine two
                • allOf(cf1, cf2, cf3) - wait for all
                • anyOf(cf1, cf2, cf3) - first to complete

                Error Handling:
                • exceptionally(fn) - recover from error
                • handle(bifn) - process result or error

                Example:
                CompletableFuture.supplyAsync(() -> fetchUser(id))
                    .thenApply(user -> enrichUser(user))
                    .thenAccept(user -> saveToCache(user))
                    .exceptionally(ex -> { log(ex); return null; });
                """,
                tags: ["CompletableFuture", "async", "Future", "concurrency"]
            ),
            CSConcept(
                category: .java,
                question: "ClassLoader - How Classes Are Loaded",
                answer: """
                Hierarchy (Parent-first delegation):
                1. Bootstrap ClassLoader (JRE classes)
                2. Extension ClassLoader (ext folder)
                3. Application ClassLoader (classpath)

                Loading Process:
                1. Loading: Read .class bytecode
                2. Linking: Verify → Prepare → Resolve
                3. Initialization: Run static blocks

                Class.forName() vs ClassLoader.loadClass():
                • forName() - loads AND initializes
                • loadClass() - loads only, no init

                Custom ClassLoader uses:
                • Hot reloading (Tomcat)
                • Plugin systems
                • Encryption/decryption of classes
                • Isolation (different versions)
                """,
                tags: ["ClassLoader", "JVM", "bytecode", "loading"]
            ),
            CSConcept(
                category: .java,
                question: "Functional Interface vs Regular Interface",
                answer: """
                Functional Interface:
                • Exactly ONE abstract method
                • Can have default/static methods
                • @FunctionalInterface annotation (optional)
                • Can be used with lambdas

                Built-in Functional Interfaces:
                • Predicate<T>: T → boolean
                • Function<T,R>: T → R
                • Consumer<T>: T → void
                • Supplier<T>: () → T
                • BiFunction<T,U,R>: (T,U) → R

                Why added to interfaces (Java 8)?
                Default methods: Backward compatibility
                • Add methods to interface without breaking implementations
                • Example: List.forEach() added without breaking old code

                Static methods: Utility methods in interface
                • Comparator.comparing()
                """,
                tags: ["functional interface", "lambda", "Java 8"]
            ),
            CSConcept(
                category: .java,
                question: "Serialization & Its Dangers",
                answer: """
                What: Convert object → byte stream

                Markers:
                • implements Serializable
                • serialVersionUID (version control)

                transient keyword:
                • Fields NOT serialized
                • Use for: passwords, derived fields, non-serializable refs

                Dangers:
                • Security: Deserialization attacks
                • Breaks encapsulation (bypasses constructors)
                • Versioning nightmares

                Alternatives:
                • JSON (Jackson, Gson)
                • Protocol Buffers
                • Externalization (manual control)

                Custom Serialization:
                private void writeObject(ObjectOutputStream)
                private void readObject(ObjectInputStream)
                """,
                tags: ["Serialization", "transient", "security"]
            )
        ]
    }
}
