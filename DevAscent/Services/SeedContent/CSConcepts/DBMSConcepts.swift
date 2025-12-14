//
//  DBMSConcepts.swift
//  DevAscent
//
//  Database Management System CS Concepts
//

import Foundation

struct DBMSConcepts {
    static func all() -> [CSConcept] {
        return [
            CSConcept(
                category: .dbms,
                question: "ACID Properties",
                answer: """
                **A - Atomicity:**
                All or nothing. If any part fails, entire transaction rolls back.
                *Implementation:* Write-ahead logging (WAL)

                **C - Consistency:**
                Database moves from one valid state to another.
                *Implementation:* Constraints, triggers, rules

                **I - Isolation:**
                Concurrent transactions don't interfere.
                *Levels:* Read Uncommitted → Read Committed → Repeatable Read → Serializable

                **D - Durability:**
                Committed data survives system crash.
                *Implementation:* WAL + checkpointing
                """,
                tags: ["ACID", "transactions", "database"]
            ),
            CSConcept(
                category: .dbms,
                question: "B-Tree Indexing - How it Works",
                answer: """
                **Structure:**
                - Balanced tree with sorted keys
                - Each node has multiple keys and children
                - Leaf nodes at same level

                **Properties:**
                - Order m: max m children per node
                - Min ⌈m/2⌉ children (except root)
                - Keys in each node are sorted

                **Operations:**
                - Search: O(log n)
                - Insert: O(log n) with possible splits
                - Delete: O(log n) with possible merges

                **B+ Tree (used in databases):**
                - Only leaves contain data pointers
                - Leaves linked for range queries
                - Better for disk I/O (more keys per node)

                **Why not Hash Index for range queries:**
                Hash doesn't preserve order, B-Tree does
                """,
                tags: ["B-Tree", "indexing", "database", "data structures"]
            ),
            CSConcept(
                category: .dbms,
                question: "Database Normalization (1NF to BCNF)",
                answer: """
                **1NF (First Normal Form):**
                - No repeating groups
                - Atomic values only
                - Each row unique (primary key)

                **2NF:**
                - 1NF + No partial dependencies
                - Non-key attributes depend on entire primary key

                **3NF:**
                - 2NF + No transitive dependencies
                - Non-key attributes depend only on primary key

                **BCNF (Boyce-Codd):**
                - 3NF + Every determinant is a candidate key

                **Denormalization:**
                - Add redundancy for read performance
                - Trade-off: Write complexity vs Read speed
                """,
                tags: ["normalization", "1NF", "2NF", "3NF", "BCNF", "database"]
            ),
            CSConcept(
                category: .dbms,
                question: "Isolation Levels & Anomalies",
                answer: """
                Anomalies (low to high isolation):

                Dirty Read: Read uncommitted data
                Non-Repeatable Read: Same query, different results
                Phantom Read: New rows appear in range query

                Isolation Levels:
                1. READ UNCOMMITTED
                   • Allows dirty reads
                   • Fastest, least safe

                2. READ COMMITTED (Postgres default)
                   • No dirty reads
                   • May have non-repeatable reads

                3. REPEATABLE READ (MySQL default)
                   • Same row reads same value
                   • Phantoms possible

                4. SERIALIZABLE
                   • Full isolation
                   • Slowest, safest
                """,
                tags: ["isolation", "transactions", "ACID", "concurrency"]
            ),
            CSConcept(
                category: .dbms,
                question: "Normalization Forms",
                answer: """
                1NF (First Normal Form):
                • Atomic values (no arrays/lists in columns)
                • Each row unique (primary key)

                2NF:
                • 1NF + No partial dependencies
                • Non-key columns depend on ENTIRE primary key

                3NF:
                • 2NF + No transitive dependencies
                • Non-key columns depend ONLY on primary key

                BCNF (Boyce-Codd):
                • Every determinant is a candidate key

                When to Denormalize:
                • Read-heavy systems (analytics)
                • Reduce JOIN overhead
                • Caching/Materialized views
                """,
                tags: ["normalization", "1NF", "2NF", "3NF", "database design"]
            ),
            CSConcept(
                category: .dbms,
                question: "CAP Theorem",
                answer: """
                In distributed system, choose 2 of 3:

                Consistency:
                • All nodes see same data at same time
                • Every read gets most recent write

                Availability:
                • Every request gets a response
                • System always operational

                Partition Tolerance:
                • System works despite network failures
                • Required in distributed systems!

                Real choices (P is mandatory):
                • CP: Banks, financial systems (sacrifice availability)
                • AP: Social media, CDNs (sacrifice consistency)

                Examples:
                • CP: MongoDB, HBase, Redis Cluster
                • AP: Cassandra, DynamoDB, CouchDB
                """,
                tags: ["CAP", "distributed", "consistency", "availability"]
            ),
            CSConcept(
                category: .dbms,
                question: "Database Sharding",
                answer: """
                What: Horizontal partitioning across servers

                Strategies:
                1. Range-based: user_id 1-1M → Shard1
                2. Hash-based: hash(user_id) % N
                3. Directory-based: Lookup table

                Challenges:
                • Cross-shard queries (JOINs)
                • Transactions across shards
                • Resharding when adding nodes
                • Hotspots (uneven distribution)

                Consistent Hashing:
                • Minimizes redistribution on add/remove
                • Virtual nodes for balance

                When to shard:
                • Single DB can't handle load
                • Data too large for one server
                • Geographic distribution needed
                """,
                tags: ["sharding", "horizontal scaling", "partitioning"]
            ),
            CSConcept(
                category: .dbms,
                question: "Database Replication",
                answer: """
                Master-Slave (Primary-Replica):
                • Writes → Master only
                • Reads → Slaves (read replicas)
                • Async replication (eventual consistency)

                Master-Master:
                • Writes to any node
                • Conflict resolution needed
                • More complex

                Replication Lag:
                • Slave may have stale data
                • Read-after-write consistency issue
                • Solutions: Sticky sessions, read-your-writes

                Synchronous vs Async:
                • Sync: Wait for ACK, slower but consistent
                • Async: Faster but may lose data

                Failover:
                • Automatic promotion of slave to master
                • Split-brain prevention
                """,
                tags: ["replication", "master-slave", "high availability"]
            ),
            CSConcept(
                category: .dbms,
                question: "Query Optimization - EXPLAIN",
                answer: """
                EXPLAIN SELECT ... shows execution plan

                Key Columns:
                • type: ALL (bad), index, range, ref, eq_ref, const
                • rows: Estimated rows examined
                • key: Index used
                • Extra: Using where, Using index, Using filesort

                Optimization Tips:
                1. Add indexes on WHERE, JOIN, ORDER BY columns
                2. Use covering indexes (include all needed columns)
                3. Avoid SELECT * (fetch only needed)
                4. Avoid functions on columns in WHERE
                5. Use LIMIT for pagination
                6. Avoid OR (use UNION or IN)

                Bad: WHERE YEAR(created_at) = 2024
                Good: WHERE created_at >= '2024-01-01'
                """,
                tags: ["EXPLAIN", "query optimization", "index", "performance"]
            ),
            CSConcept(
                category: .dbms,
                question: "Database Locking Mechanisms",
                answer: """
                Lock Granularity:
                • Table lock: Locks entire table
                • Row lock: Locks specific rows
                • Page lock: Locks memory page

                Lock Types:
                • Shared (S): Read lock, multiple holders
                • Exclusive (X): Write lock, single holder

                MySQL InnoDB:
                • Row-level locking for DML
                • Gap locks (prevent phantom reads)
                • Next-key locks = row + gap

                Deadlock:
                • Two transactions waiting for each other
                • Detection: Wait-for graph
                • Resolution: Rollback one transaction

                FOR UPDATE: Acquire exclusive lock
                SELECT * FROM users WHERE id=1 FOR UPDATE;
                """,
                tags: ["locking", "deadlock", "row lock", "transactions"]
            )
        ]
    }
}
