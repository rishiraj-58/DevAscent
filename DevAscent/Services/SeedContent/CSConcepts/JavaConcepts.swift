//
//  JavaConcepts.swift
//  DevAscent
//
//  Java CS Concepts - Comprehensive Interview Questions
//

import Foundation

struct JavaConcepts {
    static func all() -> [CSConcept] {
        return [
            // MARK: - Java Fundamentals
            CSConcept(
                category: .java,
                question: "What is Java?",
                answer: """
                Platform-independent high-level programming language.

                **Key Features:**
                - Object-oriented (OOP)
                - Platform independent (bytecode runs on any JVM)
                - High performance
                - Multi-threaded
                - Secure and robust
                """,
                tags: ["fundamentals", "overview"]
            ),
            CSConcept(
                category: .java,
                question: "What is JDK, JRE, and JVM?",
                answer: """
                **JDK (Java Development Kit):**
                - Compile, document, package programs
                - Contains JRE + development tools

                **JRE (Java Runtime Environment):**
                - Execute Java bytecode
                - Physical JVM implementation

                **JVM (Java Virtual Machine):**
                - Abstract machine for bytecode execution
                - Platform-specific implementation
                """,
                tags: ["JDK", "JRE", "JVM"]
            ),
            CSConcept(
                category: .java,
                question: "What is public static void main(String[] args)?",
                answer: """
                Entry point for Java application.

                **public:** Accessible by any class
                **static:** Called without creating object
                **void:** No return value
                **main:** Method name JVM looks for
                **String[] args:** Command-line arguments

                JVM calls main() before any objects created.
                """,
                tags: ["main", "fundamentals"]
            ),
            CSConcept(
                category: .java,
                question: "Heap vs Stack Memory?",
                answer: """
                **Stack:**
                - Per thread
                - Stores local variables, method calls
                - LIFO order
                - Fast access
                - Auto freed when method ends

                **Heap:**
                - Shared by all threads
                - Stores objects
                - Managed by GC
                - Slower access
                - Needs garbage collection
                """,
                tags: ["memory", "heap", "stack"]
            ),
            CSConcept(
                category: .java,
                question: "What is JIT Compiler?",
                answer: """
                Just-In-Time compiler improves performance.

                **How it works:**
                - Runs AFTER program starts
                - Compiles bytecode to native code
                - Caches frequently used code

                **vs Standard Compiler:**
                - JIT has runtime information
                - Can optimize hot paths
                - Better inlining decisions
                """,
                tags: ["JIT", "compiler", "performance"]
            ),
            
            // MARK: - OOP Concepts
            CSConcept(
                category: .java,
                question: "What are OOP Concepts?",
                answer: """
                **4 Pillars of OOP:**

                1. **Inheritance:** Reuse code from parent class
                2. **Encapsulation:** Bundle data + methods, hide internals
                3. **Polymorphism:** One interface, many implementations
                4. **Abstraction:** Hide complexity, show essentials

                **Additional:** Interface, Composition
                """,
                tags: ["OOP", "fundamentals"]
            ),
            CSConcept(
                category: .java,
                question: "What is Encapsulation?",
                answer: """
                Bundling data and methods in a single unit (class).

                **Purpose:**
                - Data hiding (private fields)
                - Controlled access (getters/setters)
                - Modular development

                **Implementation:**
                - Private variables
                - Public getter/setter methods
                """,
                tags: ["encapsulation", "OOP"]
            ),
            CSConcept(
                category: .java,
                question: "What is Polymorphism?",
                answer: """
                One interface, many implementations.

                **Types:**
                1. **Compile-time (Overloading):**
                   - Same method name, different parameters
                   - Resolved at compile time

                2. **Runtime (Overriding):**
                   - Subclass redefines parent method
                   - Resolved at runtime
                   - Requires inheritance
                """,
                tags: ["polymorphism", "OOP"]
            ),
            CSConcept(
                category: .java,
                question: "What is Inheritance?",
                answer: """
                Child class inherits properties from parent class.

                **Types:**
                - Single: One parent
                - Multilevel: Chain of inheritance
                - Hierarchical: Multiple children, one parent
                - Hybrid: Combination

                **Note:** Java doesn't support multiple inheritance (use interfaces)
                """,
                tags: ["inheritance", "OOP"]
            ),
            CSConcept(
                category: .java,
                question: "What is Abstraction?",
                answer: """
                Hiding implementation, showing only functionality.

                **Achieved via:**
                - Abstract classes (0-100% abstraction)
                - Interfaces (100% abstraction)

                **Abstract Class:**
                - Can have abstract + concrete methods
                - Can have constructors, fields

                **Interface:**
                - All methods abstract (before Java 8)
                - Default/static methods (Java 8+)
                """,
                tags: ["abstraction", "OOP"]
            ),
            
            // MARK: - Classes & Objects
            CSConcept(
                category: .java,
                question: "What is a Class and Object?",
                answer: """
                **Class:**
                - Blueprint/template for objects
                - Contains variables (state) and methods (behavior)
                - Defined once, instantiated many times

                **Object:**
                - Instance of a class
                - Has state and behavior
                - Created using `new` keyword
                """,
                tags: ["class", "object"]
            ),
            CSConcept(
                category: .java,
                question: "What is an Interface?",
                answer: """
                Blueprint of a class with abstract methods.

                **Properties:**
                - All methods public & abstract (before Java 8)
                - Variables are public static final
                - No constructors
                - Supports multiple inheritance

                **Java 8+:**
                - Default methods (with implementation)
                - Static methods
                """,
                tags: ["interface", "abstraction"]
            ),
            CSConcept(
                category: .java,
                question: "What is an Inner Class?",
                answer: """
                Class nested within another class.

                **Types:**
                1. **Member Inner Class:** Regular inner class
                2. **Static Nested Class:** Static, no outer reference
                3. **Local Inner Class:** Inside method
                4. **Anonymous Inner Class:** No name, inline

                **Access:** Can access all outer class members (including private)
                """,
                tags: ["inner class", "nested"]
            ),
            CSConcept(
                category: .java,
                question: "What is a Singleton Class?",
                answer: """
                Class with only ONE instance throughout application.

                **Implementation:**
                ```java
                public class Singleton {
                    private static Singleton instance;
                    private Singleton() {}
                    public static Singleton getInstance() {
                        if (instance == null) {
                            instance = new Singleton();
                        }
                        return instance;
                    }
                }
                ```

                **Thread-safe:** Use synchronized or enum
                """,
                tags: ["singleton", "design pattern"]
            ),
            
            // MARK: - Constructors
            CSConcept(
                category: .java,
                question: "What is a Constructor?",
                answer: """
                Special block to initialize an object.

                **Properties:**
                - Same name as class
                - No return type (not even void)
                - Called automatically when object created
                - Can be public, private, or protected

                **Default Constructor:**
                - Provided by compiler if none defined
                - No parameters
                """,
                tags: ["constructor", "initialization"]
            ),
            CSConcept(
                category: .java,
                question: "Types of Constructors?",
                answer: """
                **1. Default Constructor:**
                - No parameters
                - Initializes with default values

                **2. Parameterized Constructor:**
                - Takes arguments
                - Initializes with provided values

                **Constructor Overloading:**
                - Multiple constructors with different parameters
                - Same name, different signatures
                """,
                tags: ["constructor", "overloading"]
            ),
            CSConcept(
                category: .java,
                question: "Constructor vs Method?",
                answer: """
                | Constructor | Method |
                |-------------|--------|
                | Initialize object | Define behavior |
                | No return type | Has return type |
                | Same name as class | Any name |
                | Invoked implicitly | Invoked explicitly |
                | Compiler provides default | No default |
                """,
                tags: ["constructor", "method", "comparison"]
            ),
            CSConcept(
                category: .java,
                question: "What is this() and super()?",
                answer: """
                **this():**
                - Calls current class constructor
                - Must be first line
                - Chain constructors within same class

                **super():**
                - Calls parent class constructor
                - Must be first line
                - Access parent methods/fields

                **Note:** Both must be first statement in constructor
                """,
                tags: ["this", "super", "constructor"]
            ),
            
            // MARK: - Variables
            CSConcept(
                category: .java,
                question: "Local vs Instance vs Static Variable?",
                answer: """
                **Local Variable:**
                - Defined inside method
                - Scope: Within method only
                - No default value

                **Instance Variable:**
                - Defined in class, outside methods
                - Scope: Entire class
                - Default values assigned

                **Static Variable:**
                - Shared across all instances
                - Belongs to class, not object
                - One copy for all objects
                """,
                tags: ["variables", "scope"]
            ),
            CSConcept(
                category: .java,
                question: "Java Data Types?",
                answer: """
                **Primitive (8 types):**
                - byte (1B), short (2B), int (4B), long (8B)
                - float (4B), double (8B)
                - char (2B)
                - boolean (1 bit)

                **Non-Primitive:**
                - String, Arrays, Classes
                - Reference types
                - Can be null
                """,
                tags: ["data types", "primitive"]
            ),
            CSConcept(
                category: .java,
                question: "What are Wrapper Classes?",
                answer: """
                Object equivalents of primitive types.

                | Primitive | Wrapper |
                |-----------|---------|
                | int | Integer |
                | char | Character |
                | boolean | Boolean |
                | double | Double |

                **Autoboxing:** Primitive → Wrapper (automatic)
                **Unboxing:** Wrapper → Primitive (automatic)
                """,
                tags: ["wrapper", "autoboxing"]
            ),
            CSConcept(
                category: .java,
                question: "What is final Keyword?",
                answer: """
                **final Variable:**
                - Value cannot be changed (constant)

                **final Method:**
                - Cannot be overridden by subclass

                **final Class:**
                - Cannot be inherited

                **Final with non-primitive:**
                - Reference cannot change
                - Object contents CAN change
                """,
                tags: ["final", "immutable"]
            ),
            CSConcept(
                category: .java,
                question: "What is static Keyword?",
                answer: """
                Belongs to class, not to instance.

                **Static Variable:**
                - Shared by all objects
                - Single copy

                **Static Method:**
                - Called without object: ClassName.method()
                - Cannot access instance variables
                - Cannot use `this` or `super`

                **Static Block:**
                - Executes when class loads
                """,
                tags: ["static", "class-level"]
            ),
            
            // MARK: - Methods
            CSConcept(
                category: .java,
                question: "Method Overloading vs Overriding?",
                answer: """
                **Overloading (Compile-time):**
                - Same method name, different parameters
                - Same class
                - Return type can differ

                **Overriding (Runtime):**
                - Same method signature
                - Child class redefines parent method
                - @Override annotation
                - Return type must match (or covariant)
                """,
                tags: ["overloading", "overriding"]
            ),
            CSConcept(
                category: .java,
                question: "Can you override private or static methods?",
                answer: """
                **Private methods:**
                - Cannot be overridden
                - Not accessible in subclass
                - Can create same-name method (method hiding)

                **Static methods:**
                - Cannot be overridden
                - Can be hidden (method hiding)
                - Binding is compile-time, not runtime

                **Method Hiding:** Create similar method in child class
                """,
                tags: ["override", "private", "static"]
            ),
            CSConcept(
                category: .java,
                question: "equals() vs == ?",
                answer: """
                **== (Equality Operator):**
                - Compares references
                - For primitives: compares values
                - For objects: compares memory addresses

                **equals() Method:**
                - Compares content/values
                - Defined in Object class
                - Should be overridden for custom comparison

                **String comparison:** Always use equals()
                """,
                tags: ["equals", "comparison"]
            ),
            
            // MARK: - Strings
            CSConcept(
                category: .java,
                question: "String vs StringBuffer vs StringBuilder?",
                answer: """
                **String:**
                - Immutable
                - Thread-safe
                - Stored in String Pool

                **StringBuffer:**
                - Mutable
                - Thread-safe (synchronized)
                - Slower

                **StringBuilder:**
                - Mutable
                - NOT thread-safe
                - Faster (no synchronization)

                **Use:** StringBuilder for single thread, StringBuffer for multi-thread
                """,
                tags: ["String", "StringBuilder", "StringBuffer"]
            ),
            CSConcept(
                category: .java,
                question: "String Pool & Interning?",
                answer: """
                **String Literal:**
                ```java
                String s1 = "abc"; // String Pool
                String s2 = "abc"; // Same reference
                String s3 = new String("abc"); // Heap
                ```

                **Comparison:**
                - s1 == s2 → true (same pool reference)
                - s1 == s3 → false (different objects)
                - s1.equals(s3) → true (same content)

                **intern():** Returns pool reference
                """,
                tags: ["String Pool", "intern"]
            ),
            
            // MARK: - Exception Handling
            CSConcept(
                category: .java,
                question: "What is Exception Handling?",
                answer: """
                Mechanism to handle runtime errors.

                **Keywords:**
                - try: Code that may throw exception
                - catch: Handle specific exception
                - finally: Always executes
                - throw: Manually throw exception
                - throws: Declare exception in method signature
                """,
                tags: ["exception", "try-catch"]
            ),
            CSConcept(
                category: .java,
                question: "Checked vs Unchecked Exceptions?",
                answer: """
                **Checked Exceptions:**
                - Checked at compile time
                - Must handle or declare
                - Extends Exception
                - Ex: IOException, SQLException

                **Unchecked Exceptions:**
                - Checked at runtime
                - No mandatory handling
                - Extends RuntimeException
                - Ex: NullPointerException, ArrayIndexOutOfBounds

                **Error:** Serious problems (OutOfMemoryError)
                """,
                tags: ["checked", "unchecked", "exception"]
            ),
            CSConcept(
                category: .java,
                question: "Multiple Catch Blocks?",
                answer: """
                Yes, multiple catch blocks allowed.

                **Rule:** Specific to general order

                ```java
                try {
                    // code
                } catch (ArithmeticException e) {
                    // specific
                } catch (ArrayIndexOutOfBoundsException e) {
                    // specific
                } catch (Exception e) {
                    // general (last)
                }
                ```
                """,
                tags: ["catch", "exception"]
            ),
            
            // MARK: - Control Flow
            CSConcept(
                category: .java,
                question: "Types of Loops in Java?",
                answer: """
                **for loop:**
                - Known iterations
                - `for (int i=0; i<n; i++)`

                **while loop:**
                - Condition checked before execution
                - May not execute at all

                **do-while loop:**
                - Condition checked after execution
                - Executes at least once

                **Enhanced for (for-each):**
                - Iterate collections: `for (int x : array)`
                """,
                tags: ["loops", "control flow"]
            ),
            CSConcept(
                category: .java,
                question: "break vs continue?",
                answer: """
                **break:**
                - Exits loop immediately
                - Stops further iterations

                **continue:**
                - Skips current iteration
                - Loop continues with next iteration

                **Labeled break/continue:**
                - Can break/continue outer loops
                """,
                tags: ["break", "continue", "loops"]
            ),
            CSConcept(
                category: .java,
                question: "What is a Switch Statement?",
                answer: """
                Select from multiple conditions.

                **Advantages:**
                - Cleaner than multiple if-else
                - Faster for many conditions
                - Supports: int, char, String (Java 7+), enum

                **default:** Executes when no case matches (optional)

                **Java 12+:** Switch expressions with arrow syntax
                """,
                tags: ["switch", "control flow"]
            ),
            
            // MARK: - Packages
            CSConcept(
                category: .java,
                question: "What is a Package?",
                answer: """
                Collection of related classes and interfaces.

                **Advantages:**
                - Avoid name clashes
                - Access control
                - Easier maintenance
                - Hierarchical organization

                **Types:**
                - Built-in: java.lang, java.util
                - User-defined: com.example.app
                """,
                tags: ["package", "organization"]
            ),
            
            // MARK: - Collections
            CSConcept(
                category: .java,
                question: "HashMap Internals?",
                answer: """
                **Structure:**
                - Array of buckets (default 16)
                - Bucket: LinkedList → TreeMap (when >8 nodes)

                **Operations:**
                1. hash(key.hashCode())
                2. index = hash & (n-1)
                3. Traverse bucket, find/insert

                **Load Factor:** 0.75 (resize at 75%)
                **Java 8+:** Red-Black Tree for collision
                """,
                tags: ["HashMap", "collections"]
            ),
            CSConcept(
                category: .java,
                question: "hashCode() and equals() Contract?",
                answer: """
                **Rules:**
                - If a.equals(b) → hashCode must be same
                - If hashCode differs → objects NOT equal
                - Same hashCode doesn't mean equal (collision)

                **Breaking Contract:**
                - Override equals() only → HashMap breaks
                - Override hashCode() only → equals objects in different buckets

                **Always override BOTH together!**
                """,
                tags: ["hashCode", "equals", "contract"]
            ),
            CSConcept(
                category: .java,
                question: "ArrayList vs LinkedList?",
                answer: """
                **ArrayList:**
                - Dynamic array
                - O(1) random access
                - O(n) insert/delete (shifting)
                - Better for read-heavy

                **LinkedList:**
                - Doubly-linked nodes
                - O(n) random access
                - O(1) insert/delete at ends
                - Better for write-heavy
                """,
                tags: ["ArrayList", "LinkedList"]
            ),
            CSConcept(
                category: .java,
                question: "ConcurrentHashMap vs HashMap?",
                answer: """
                **HashMap:**
                - NOT thread-safe
                - Allows null key/values
                - Faster (no sync overhead)

                **ConcurrentHashMap:**
                - Thread-safe
                - No null keys/values
                - Segment locking (Java 7)
                - CAS operations (Java 8+)
                - Read: Lock-free
                """,
                tags: ["ConcurrentHashMap", "thread-safe"]
            ),
            
            // MARK: - Concurrency
            CSConcept(
                category: .java,
                question: "volatile vs synchronized?",
                answer: """
                **volatile:**
                - Visibility only
                - Reads/writes to main memory
                - No atomicity (i++ NOT atomic)
                - No blocking

                **synchronized:**
                - Visibility + Atomicity + Mutex
                - Acquires lock
                - Blocking (threads wait)
                - Can cause deadlock
                """,
                tags: ["volatile", "synchronized"]
            ),
            CSConcept(
                category: .java,
                question: "What is ThreadLocal?",
                answer: """
                Each thread gets its own variable copy.

                **Use Cases:**
                - User session context
                - Database connections
                - SimpleDateFormat (not thread-safe)

                **Danger:** Memory leak in thread pools!

                **Always:** Use try-finally with remove()
                """,
                tags: ["ThreadLocal", "concurrency"]
            ),
            CSConcept(
                category: .java,
                question: "Thread Pool Types?",
                answer: """
                **FixedThreadPool(n):**
                - Fixed n threads
                - Unbounded queue

                **CachedThreadPool:**
                - Creates threads as needed
                - Reuses idle threads

                **SingleThreadExecutor:**
                - One thread, sequential

                **ScheduledThreadPool:**
                - Delayed/periodic tasks

                **Always shutdown() to prevent leaks!**
                """,
                tags: ["ThreadPool", "Executor"]
            ),
            
            // MARK: - Garbage Collection
            CSConcept(
                category: .java,
                question: "Garbage Collection Generations?",
                answer: """
                **Young Generation:**
                - Eden: New objects
                - Survivor 0 & 1: Minor GC survivors
                - Minor GC: Fast, short pause

                **Old Generation:**
                - Long-lived objects
                - Major GC: Slower, longer pause

                **Metaspace (Java 8+):**
                - Class metadata
                - Replaced PermGen
                """,
                tags: ["GC", "garbage collection"]
            ),
            
            // MARK: - Java 8+ Features
            CSConcept(
                category: .java,
                question: "Functional Interface?",
                answer: """
                Interface with exactly ONE abstract method.

                **Built-in:**
                - Predicate<T>: T → boolean
                - Function<T,R>: T → R
                - Consumer<T>: T → void
                - Supplier<T>: () → T

                **Lambda Expressions:**
                - `(x) -> x * 2`
                - Implement functional interfaces concisely
                """,
                tags: ["functional", "lambda", "Java 8"]
            ),
            CSConcept(
                category: .java,
                question: "Stream API?",
                answer: """
                **Pipeline:**
                Source → Intermediate → Terminal

                **Intermediate (lazy):**
                - filter(), map(), flatMap()
                - sorted(), distinct()

                **Terminal (trigger):**
                - collect(), forEach()
                - reduce(), count()
                - findFirst(), anyMatch()

                **Example:**
                `list.stream().filter(x -> x > 5).collect(toList())`
                """,
                tags: ["Stream", "Java 8"]
            ),
            CSConcept(
                category: .java,
                question: "CompletableFuture?",
                answer: """
                Async programming without blocking.

                **Creating:**
                - supplyAsync(() -> compute())
                - runAsync(() -> sideEffect())

                **Chaining:**
                - thenApply() - transform
                - thenAccept() - consume
                - thenCompose() - flatMap

                **Error Handling:**
                - exceptionally() - recover
                - handle() - process result or error
                """,
                tags: ["CompletableFuture", "async"]
            ),
            
            // MARK: - Serialization
            CSConcept(
                category: .java,
                question: "What is Serialization?",
                answer: """
                Convert object to byte stream.

                **Markers:**
                - implements Serializable
                - serialVersionUID

                **transient:**
                - Fields NOT serialized
                - Use for: passwords, derived fields

                **Dangers:**
                - Security (deserialization attacks)
                - Breaks encapsulation
                - Version issues
                """,
                tags: ["serialization", "transient"]
            ),
            
            // MARK: - Immutability
            CSConcept(
                category: .java,
                question: "Creating an Immutable Class?",
                answer: """
                **Rules:**
                1. Class is final (no subclassing)
                2. All fields private and final
                3. No setters
                4. Defensive copy in constructor
                5. Defensive copy in getters

                **Benefits:**
                - Thread-safe
                - Cacheable
                - Good hash keys
                """,
                tags: ["immutable", "design"]
            ),
            
            // MARK: - ClassLoader
            CSConcept(
                category: .java,
                question: "ClassLoader Hierarchy?",
                answer: """
                **Parent-first delegation:**
                1. Bootstrap ClassLoader (JRE classes)
                2. Extension ClassLoader (ext folder)
                3. Application ClassLoader (classpath)

                **Loading Process:**
                1. Loading: Read .class bytecode
                2. Linking: Verify → Prepare → Resolve
                3. Initialization: Run static blocks

                **Class.forName():** Loads AND initializes
                """,
                tags: ["ClassLoader", "JVM"]
            )
        ]
    }
}
