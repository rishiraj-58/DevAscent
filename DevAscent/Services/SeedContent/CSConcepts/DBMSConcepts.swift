//
//  DBMSConcepts.swift
//  DevAscent
//
//  Database Management System CS Concepts - Comprehensive Interview Questions
//

import Foundation

struct DBMSConcepts {
    static func all() -> [CSConcept] {
        return [
            // MARK: - Fundamentals
            CSConcept(
                category: .dbms,
                question: "What is DBMS?",
                answer: """
                Software to manage and organize databases.

                **Functions:**
                - Store, retrieve, update data
                - Ensure data integrity & security
                - Manage concurrency
                - Backup & recovery

                **Examples:** MySQL, PostgreSQL, Oracle, SQL Server
                """,
                tags: ["fundamentals", "database"]
            ),
            CSConcept(
                category: .dbms,
                question: "DBMS vs RDBMS?",
                answer: """
                | Aspect | DBMS | RDBMS |
                |--------|------|-------|
                | Storage | Files/non-relational | Tables (rows & columns) |
                | Relationships | Not supported | Foreign keys |
                | Integrity | No constraints | Primary/Foreign keys |
                | Examples | MS Access, XML DB | MySQL, Oracle |
                """,
                tags: ["comparison", "fundamentals"]
            ),
            CSConcept(
                category: .dbms,
                question: "Types of DBMS?",
                answer: """
                1. **Hierarchical:** Tree structure (parent-child). Ex: IBM IMS
                2. **Network:** Graph with many-to-many. Ex: IDS
                3. **Relational (RDBMS):** Tables + SQL. Ex: MySQL
                4. **Object-Oriented:** Data as objects. Ex: ObjectDB
                5. **NoSQL:** Document, Key-Value, Graph. Ex: MongoDB
                """,
                tags: ["types", "fundamentals"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is a Relation/Table?",
                answer: """
                **Table:** Collection of data in rows and columns.
                **Row (Tuple):** Single record/entity
                **Column (Attribute):** Property with data type

                **Schema:** Structure defining columns and constraints
                """,
                tags: ["table", "fundamentals"]
            ),
            
            // MARK: - Keys
            CSConcept(
                category: .dbms,
                question: "What is a Primary Key?",
                answer: """
                Unique identifier for each record in a table.

                **Properties:**
                - Uniquely identifies each row
                - Cannot be NULL
                - Only ONE per table

                **Example:** ROLL_NO in STUDENT table
                """,
                tags: ["primary key", "keys"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is a Foreign Key?",
                answer: """
                Attribute linking to primary key in another table.

                **Purpose:**
                - Create relationships between tables
                - Ensure referential integrity
                - Prevent orphan records

                **Example:** BRANCH_CODE in STUDENT referencing BRANCH table
                """,
                tags: ["foreign key", "keys"]
            ),
            CSConcept(
                category: .dbms,
                question: "Candidate Key vs Super Key?",
                answer: """
                **Super Key:**
                - Set of attributes that uniquely identifies a row
                - May contain extra/unnecessary attributes

                **Candidate Key:**
                - MINIMAL super key (no redundant attributes)
                - Table can have multiple
                - One chosen as Primary Key
                """,
                tags: ["candidate key", "super key", "keys"]
            ),
            CSConcept(
                category: .dbms,
                question: "Primary Key vs Unique Key?",
                answer: """
                | Primary Key | Unique Key |
                |-------------|------------|
                | Only ONE per table | Multiple allowed |
                | Cannot be NULL | CAN be NULL |
                | Creates clustered index | Creates non-clustered |
                | Identifies records | Just ensures uniqueness |
                """,
                tags: ["primary key", "unique key", "comparison"]
            ),
            
            // MARK: - Normalization
            CSConcept(
                category: .dbms,
                question: "What is Normalization?",
                answer: """
                Organizing data to reduce redundancy and dependency.

                **Benefits:**
                - Eliminates duplicate data
                - Prevents anomalies (insert, update, delete)
                - Improves data integrity

                **Process:** Divide large tables into smaller related ones
                """,
                tags: ["normalization", "design"]
            ),
            CSConcept(
                category: .dbms,
                question: "Normal Forms (1NF to BCNF)?",
                answer: """
                **1NF:** Atomic values, no repeating groups, unique rows
                **2NF:** 1NF + No partial dependencies (non-key depends on ENTIRE PK)
                **3NF:** 2NF + No transitive dependencies (non-key depends ONLY on PK)
                **BCNF:** Every determinant is a candidate key

                Higher forms = Less redundancy = More tables = More JOINs
                """,
                tags: ["1NF", "2NF", "3NF", "BCNF"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is Denormalization?",
                answer: """
                Adding redundancy to improve read performance.

                **When to use:**
                - Read-heavy workloads (analytics)
                - Reduce expensive JOINs
                - Caching/Materialized views

                **Trade-off:** Faster reads vs Write complexity
                """,
                tags: ["denormalization", "performance"]
            ),
            
            // MARK: - Transactions & ACID
            CSConcept(
                category: .dbms,
                question: "What is a Transaction?",
                answer: """
                Sequence of SQL operations executed as single unit.

                **Properties (ACID):**
                - All operations succeed or all fail
                - Database stays consistent
                - Isolated from other transactions
                - Changes are permanent after commit
                """,
                tags: ["transaction", "ACID"]
            ),
            CSConcept(
                category: .dbms,
                question: "ACID Properties?",
                answer: """
                **A - Atomicity:** All or nothing (WAL logging)
                **C - Consistency:** Valid state to valid state
                **I - Isolation:** Transactions don't interfere
                **D - Durability:** Committed data survives crash

                **Implementation:** Write-Ahead Logging (WAL) + Checkpointing
                """,
                tags: ["ACID", "transactions"]
            ),
            CSConcept(
                category: .dbms,
                question: "Isolation Levels?",
                answer: """
                1. **READ UNCOMMITTED** - Dirty reads allowed (fastest)
                2. **READ COMMITTED** - No dirty reads (Postgres default)
                3. **REPEATABLE READ** - Same row = same value (MySQL default)
                4. **SERIALIZABLE** - Full isolation (slowest)

                **Anomalies:**
                - Dirty Read: Read uncommitted data
                - Non-Repeatable Read: Different results same query
                - Phantom Read: New rows in range query
                """,
                tags: ["isolation", "concurrency"]
            ),
            CSConcept(
                category: .dbms,
                question: "COMMIT vs ROLLBACK?",
                answer: """
                **COMMIT:**
                - Saves all changes permanently
                - Ends transaction successfully
                - Changes visible to others

                **ROLLBACK:**
                - Reverses all changes
                - Restores previous state
                - Used on errors/failures
                """,
                tags: ["commit", "rollback", "transactions"]
            ),
            
            // MARK: - SQL Operations
            CSConcept(
                category: .dbms,
                question: "DELETE vs TRUNCATE vs DROP?",
                answer: """
                | DELETE | TRUNCATE | DROP |
                |--------|----------|------|
                | Removes rows | Removes ALL rows | Removes table |
                | Uses WHERE | No WHERE | - |
                | Can rollback | Cannot rollback | Cannot rollback |
                | Slow (logs each) | Fast (no logging) | Fast |
                | Triggers fire | Triggers don't fire | - |
                """,
                tags: ["DELETE", "TRUNCATE", "DROP"]
            ),
            CSConcept(
                category: .dbms,
                question: "Types of SQL JOINs?",
                answer: """
                1. **INNER JOIN** - Only matching rows
                2. **LEFT JOIN** - All from left + matching right
                3. **RIGHT JOIN** - All from right + matching left
                4. **FULL JOIN** - All from both tables
                5. **CROSS JOIN** - Cartesian product
                6. **SELF JOIN** - Join table with itself
                """,
                tags: ["JOIN", "SQL"]
            ),
            CSConcept(
                category: .dbms,
                question: "INNER JOIN vs OUTER JOIN?",
                answer: """
                **INNER JOIN:**
                - Only matching rows from both tables
                - No NULL values from join
                - Generally faster

                **OUTER JOIN (LEFT/RIGHT/FULL):**
                - Includes non-matching rows
                - NULL for missing values
                - Preserves all data from one/both tables
                """,
                tags: ["INNER JOIN", "OUTER JOIN"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is a Subquery?",
                answer: """
                Query embedded within another query.

                **Types:**
                - Single-row: Returns one value
                - Multiple-row: Returns multiple values
                - Correlated: References outer query

                **Example:**
                `SELECT * FROM Student WHERE Age > (SELECT AVG(Age) FROM Student)`
                """,
                tags: ["subquery", "SQL"]
            ),
            CSConcept(
                category: .dbms,
                question: "UNION vs UNION ALL?",
                answer: """
                **UNION:**
                - Combines results of two queries
                - Removes duplicates
                - Slower (needs to check duplicates)

                **UNION ALL:**
                - Combines results
                - Keeps ALL rows including duplicates
                - Faster
                """,
                tags: ["UNION", "SQL"]
            ),
            CSConcept(
                category: .dbms,
                question: "GROUP BY and Aggregate Functions?",
                answer: """
                **GROUP BY:** Groups rows with same values into summary rows

                **Aggregate Functions:**
                - COUNT() - Number of rows
                - SUM() - Sum of values
                - AVG() - Average value
                - MAX() - Maximum value
                - MIN() - Minimum value

                **HAVING:** Filter groups (like WHERE for groups)
                """,
                tags: ["GROUP BY", "aggregates", "SQL"]
            ),
            
            // MARK: - Indexing
            CSConcept(
                category: .dbms,
                question: "What is an Index?",
                answer: """
                Data structure to speed up data retrieval.

                **How it works:**
                - Like book's table of contents
                - Stores column values + row pointers
                - Sorted for fast lookup

                **Trade-off:** Faster reads vs Slower writes (index maintenance)
                """,
                tags: ["index", "performance"]
            ),
            CSConcept(
                category: .dbms,
                question: "Clustered vs Non-Clustered Index?",
                answer: """
                **Clustered:**
                - Physically reorders table data
                - Only ONE per table
                - Primary key creates clustered by default

                **Non-Clustered:**
                - Separate structure with pointers
                - Multiple allowed per table
                - Stores index + row locator
                """,
                tags: ["clustered", "non-clustered", "index"]
            ),
            CSConcept(
                category: .dbms,
                question: "B-Tree vs B+ Tree?",
                answer: """
                **B-Tree:**
                - Data in both internal and leaf nodes
                - Balanced search tree

                **B+ Tree (used in DBs):**
                - Data ONLY in leaf nodes
                - Leaves linked for range queries
                - More keys per node (better for disk I/O)
                - Better for range queries
                """,
                tags: ["B-Tree", "B+ Tree", "index"]
            ),
            
            // MARK: - Views & Procedures
            CSConcept(
                category: .dbms,
                question: "What is a View?",
                answer: """
                Virtual table created from a query.

                **Properties:**
                - Doesn't store data physically
                - Dynamically retrieves data when queried
                - Can simplify complex queries
                - Provides security (hide columns)

                **Materialized View:** Stores query results (faster, needs refresh)
                """,
                tags: ["view", "virtual table"]
            ),
            CSConcept(
                category: .dbms,
                question: "Stored Procedure vs Function?",
                answer: """
                **Stored Procedure:**
                - Precompiled SQL statements
                - May or may not return value
                - Can have OUT parameters
                - Can perform DML

                **Function:**
                - Must return a value
                - Can be used in SELECT
                - Usually no side effects
                """,
                tags: ["stored procedure", "function"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is a Trigger?",
                answer: """
                Automatic action on table events (INSERT, UPDATE, DELETE).

                **Types:**
                - BEFORE trigger - Runs before the event
                - AFTER trigger - Runs after the event
                - INSTEAD OF - Replaces the event

                **Uses:** Audit logging, validation, cascading changes
                """,
                tags: ["trigger", "automation"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is a Cursor?",
                answer: """
                Pointer to result set for row-by-row processing.

                **Types:**
                - Implicit: Created by DBMS automatically
                - Explicit: Created by programmer

                **Use when:** Need to process rows individually (loops)

                **Avoid when:** Set-based operations are possible (faster)
                """,
                tags: ["cursor", "SQL"]
            ),
            
            // MARK: - Constraints
            CSConcept(
                category: .dbms,
                question: "Types of Constraints?",
                answer: """
                1. **NOT NULL** - No NULL values allowed
                2. **PRIMARY KEY** - Unique + Not Null
                3. **FOREIGN KEY** - References another table
                4. **UNIQUE** - All values distinct (allows NULL)
                5. **CHECK** - Validates condition
                6. **DEFAULT** - Sets default value
                """,
                tags: ["constraints", "integrity"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is Referential Integrity?",
                answer: """
                Ensures relationships between tables remain valid.

                **Rules:**
                - Foreign key must match a primary key OR be NULL
                - No orphan records

                **Actions:**
                - ON DELETE CASCADE - Delete child records
                - ON UPDATE CASCADE - Update child records
                - SET NULL - Set to NULL on delete
                """,
                tags: ["referential integrity", "foreign key"]
            ),
            
            // MARK: - Concurrency & Locking
            CSConcept(
                category: .dbms,
                question: "What is a Deadlock?",
                answer: """
                Two+ transactions waiting for each other's resources.

                **Prevention:**
                - Lock ordering
                - Timeouts
                - Deadlock detection

                **Resolution:** Rollback one transaction (victim selection)
                """,
                tags: ["deadlock", "concurrency"]
            ),
            CSConcept(
                category: .dbms,
                question: "Types of Database Locks?",
                answer: """
                **By Type:**
                - Shared (S): Read lock, multiple holders
                - Exclusive (X): Write lock, single holder

                **By Granularity:**
                - Row lock: Specific rows
                - Page lock: Memory page
                - Table lock: Entire table

                **FOR UPDATE:** Acquire exclusive lock on selected rows
                """,
                tags: ["locks", "concurrency"]
            ),
            CSConcept(
                category: .dbms,
                question: "Concurrency Control Techniques?",
                answer: """
                1. **Locking:** Acquire locks before access
                2. **Timestamp Ordering:** Order by transaction timestamp
                3. **Optimistic:** Check conflicts at commit time
                4. **Two-Phase Locking:** Growing (acquire) + Shrinking (release)

                **MVCC:** Multiple versions for read consistency (Postgres)
                """,
                tags: ["concurrency control", "locking"]
            ),
            
            // MARK: - Distributed & Scaling
            CSConcept(
                category: .dbms,
                question: "CAP Theorem?",
                answer: """
                In distributed systems, choose 2 of 3:

                **C - Consistency:** All nodes see same data
                **A - Availability:** Every request gets response
                **P - Partition Tolerance:** Works despite network failures

                **CP:** MongoDB, HBase (sacrifice availability)
                **AP:** Cassandra, DynamoDB (sacrifice consistency)
                """,
                tags: ["CAP", "distributed"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is Database Sharding?",
                answer: """
                Horizontal partitioning across multiple servers.

                **Strategies:**
                - Range-based: ID 1-1M → Shard1
                - Hash-based: hash(id) % N
                - Directory-based: Lookup table

                **Challenges:** Cross-shard JOINs, transactions, resharding
                """,
                tags: ["sharding", "scaling"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is Data Partitioning?",
                answer: """
                Dividing large datasets into smaller segments.

                **Types:**
                - **Horizontal:** By rows (sharding)
                - **Vertical:** By columns
                - **Range:** By value ranges
                - **Hash:** By hash function

                **Benefits:** Better performance, scalability, availability
                """,
                tags: ["partitioning", "scaling"]
            ),
            CSConcept(
                category: .dbms,
                question: "Database Replication?",
                answer: """
                **Master-Slave:**
                - Writes → Master
                - Reads → Replicas
                - Async replication (eventual consistency)

                **Master-Master:**
                - Writes to any node
                - Conflict resolution needed

                **Replication Lag:** Slaves may have stale data
                """,
                tags: ["replication", "high availability"]
            ),
            
            // MARK: - Design & Modeling
            CSConcept(
                category: .dbms,
                question: "What is an ER Diagram?",
                answer: """
                Visual representation of entities and relationships.

                **Components:**
                - **Entities:** Objects (Rectangle) - Student, Course
                - **Attributes:** Properties (Oval) - Name, ID
                - **Relationships:** How entities relate (Diamond)

                **Used in:** Database design phase
                """,
                tags: ["ER diagram", "design"]
            ),
            CSConcept(
                category: .dbms,
                question: "Types of Relationships?",
                answer: """
                1. **One-to-One (1:1)**
                   One record → One record
                   Ex: Person → Passport

                2. **One-to-Many (1:M)**
                   One record → Many records
                   Ex: Customer → Orders

                3. **Many-to-Many (M:M)**
                   Many → Many (needs junction table)
                   Ex: Students ↔ Courses
                """,
                tags: ["relationships", "design"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is a Schema?",
                answer: """
                Structure defining database organization.

                **Includes:**
                - Tables and columns
                - Data types
                - Constraints
                - Keys and indexes
                - Views and procedures

                **Types:** Physical, Logical, View (3-schema architecture)
                """,
                tags: ["schema", "design"]
            ),
            
            // MARK: - Advanced Topics
            CSConcept(
                category: .dbms,
                question: "What is a Transaction Log?",
                answer: """
                Record of all transactions for recovery.

                **Contains:**
                - Transaction start/commit/rollback
                - Before and after values
                - Modification details

                **Uses:**
                - Crash recovery
                - Point-in-time recovery
                - Replication
                """,
                tags: ["transaction log", "recovery"]
            ),
            CSConcept(
                category: .dbms,
                question: "Types of Database Backups?",
                answer: """
                1. **Full Backup:** Entire database (comprehensive but slow)
                2. **Incremental:** Changes since last backup
                3. **Differential:** Changes since last full backup
                4. **Transaction Log:** Log entries for point-in-time recovery

                **Strategy:** Full weekly + Daily incremental
                """,
                tags: ["backup", "recovery"]
            ),
            CSConcept(
                category: .dbms,
                question: "Query Optimization Techniques?",
                answer: """
                1. **Use EXPLAIN** to analyze query plan
                2. **Add indexes** on WHERE, JOIN, ORDER BY columns
                3. **Avoid SELECT *** - fetch only needed columns
                4. **Use LIMIT** for pagination
                5. **Avoid functions on columns** in WHERE
                6. **Use covering indexes**

                **Bad:** `WHERE YEAR(date) = 2024`
                **Good:** `WHERE date >= '2024-01-01'`
                """,
                tags: ["optimization", "performance"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is Data Redundancy?",
                answer: """
                Unnecessary repetition of data in database.

                **Problems:**
                - Storage waste
                - Inconsistency risk
                - Update anomalies

                **Solutions:**
                - Normalization
                - Constraints (UNIQUE, PRIMARY KEY)
                - Proper database design
                """,
                tags: ["redundancy", "design"]
            ),
            CSConcept(
                category: .dbms,
                question: "File System vs DBMS?",
                answer: """
                | Aspect | File System | DBMS |
                |--------|-------------|------|
                | Redundancy | Common | Minimized |
                | Security | OS-level | Fine-grained |
                | Concurrency | Poor | Transaction control |
                | Integrity | Manual | Constraints |
                | Recovery | Manual | Automatic |
                | Querying | Complex | SQL |
                """,
                tags: ["comparison", "fundamentals"]
            ),
            CSConcept(
                category: .dbms,
                question: "What is Hashing in DBMS?",
                answer: """
                Mapping data to fixed-size value using hash function.

                **Uses:**
                - Hash indexes for O(1) lookup
                - Hash partitioning for sharding

                **Hash Index:**
                - Fast for equality queries
                - NOT good for range queries
                - B-Tree better for ranges
                """,
                tags: ["hashing", "index"]
            ),
            CSConcept(
                category: .dbms,
                question: "Role of DBA (Database Administrator)?",
                answer: """
                **Responsibilities:**
                - Database design & architecture
                - Backup & recovery planning
                - Performance tuning
                - Security management
                - User access control
                - Upgrades & patches
                - Troubleshooting
                """,
                tags: ["DBA", "administration"]
            )
        ]
    }
}
