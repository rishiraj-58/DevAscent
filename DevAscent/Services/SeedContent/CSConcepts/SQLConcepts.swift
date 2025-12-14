//
//  SQLConcepts.swift
//  DevAscent
//
//  SQL CS Concepts
//

import Foundation

struct SQLConcepts {
    static func all() -> [CSConcept] {
        return [
            CSConcept(
                category: .sql,
                question: "Find Nth Highest Salary",
                answer: """
                Method 1 - LIMIT OFFSET:
                SELECT DISTINCT salary 
                FROM Employee 
                ORDER BY salary DESC 
                LIMIT 1 OFFSET N-1;

                Method 2 - DENSE_RANK (handles ties):
                SELECT salary FROM (
                    SELECT salary, 
                           DENSE_RANK() OVER (ORDER BY salary DESC) as rnk 
                    FROM Employee
                ) ranked
                WHERE rnk = N;

                Method 3 - Subquery:
                SELECT MAX(salary) FROM Employee
                WHERE salary < (SELECT MAX(salary) FROM Employee);
                -- This gives 2nd highest

                DENSE_RANK vs RANK vs ROW_NUMBER:
                • DENSE_RANK: No gaps (1,2,2,3)
                • RANK: Gaps after ties (1,2,2,4)
                • ROW_NUMBER: Unique (1,2,3,4)
                """,
                tags: ["SQL", "ranking", "salary", "interview"]
            ),
            CSConcept(
                category: .sql,
                question: "Find & Delete Duplicates",
                answer: """
                Find Duplicates:
                SELECT email, COUNT(*) as cnt
                FROM Users
                GROUP BY email
                HAVING COUNT(*) > 1;

                Delete Duplicates (keep lowest ID):
                DELETE FROM Users
                WHERE id NOT IN (
                    SELECT MIN(id)
                    FROM Users
                    GROUP BY email
                );

                Using CTE and ROW_NUMBER:
                WITH CTE AS (
                    SELECT id, email,
                           ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) as rn
                    FROM Users
                )
                DELETE FROM Users WHERE id IN (
                    SELECT id FROM CTE WHERE rn > 1
                );
                """,
                tags: ["SQL", "duplicates", "CTE", "delete"]
            ),
            CSConcept(
                category: .sql,
                question: "Types of Joins",
                answer: """
                INNER JOIN:
                • Only matching rows from both tables
                SELECT * FROM A INNER JOIN B ON A.id = B.a_id

                LEFT JOIN:
                • All rows from left + matching from right
                • NULL for non-matching right rows

                RIGHT JOIN:
                • All rows from right + matching from left

                FULL OUTER JOIN:
                • All rows from both, NULL where no match

                CROSS JOIN:
                • Cartesian product (every row × every row)

                SELF JOIN:
                • Table joined with itself
                • Use case: Employee-Manager hierarchy
                SELECT e.name, m.name as manager
                FROM Employee e
                LEFT JOIN Employee m ON e.manager_id = m.id
                """,
                tags: ["SQL", "joins", "tables", "relationships"]
            ),
            CSConcept(
                category: .sql,
                question: "Window Functions",
                answer: """
                Syntax: function() OVER (PARTITION BY ... ORDER BY ...)

                Ranking:
                ROW_NUMBER(): 1,2,3,4 (unique)
                RANK(): 1,2,2,4 (gaps after ties)
                DENSE_RANK(): 1,2,2,3 (no gaps)
                NTILE(n): Divide into n buckets

                Aggregate:
                SUM(), AVG(), COUNT(), MIN(), MAX()
                Running total: SUM(amount) OVER (ORDER BY date)

                Value:
                LAG(col, n): n rows before
                LEAD(col, n): n rows after
                FIRST_VALUE(), LAST_VALUE()

                Example:
                SELECT name, salary,
                    salary - LAG(salary) OVER (ORDER BY hire_date) as increase,
                    AVG(salary) OVER (PARTITION BY dept) as dept_avg
                FROM employees;
                """,
                tags: ["window functions", "OVER", "PARTITION BY", "analytics"]
            ),
            CSConcept(
                category: .sql,
                question: "Common Table Expressions (CTE)",
                answer: """
                Syntax:
                WITH cte_name AS (
                    SELECT ...
                )
                SELECT * FROM cte_name;

                Benefits:
                • Readability (name complex subqueries)
                • Reusability (reference multiple times)
                • Recursive queries

                Recursive CTE (hierarchies):
                WITH RECURSIVE hierarchy AS (
                    -- Base case
                    SELECT id, name, manager_id, 1 as level
                    FROM employees WHERE manager_id IS NULL
                    
                    UNION ALL
                    
                    -- Recursive case
                    SELECT e.id, e.name, e.manager_id, h.level + 1
                    FROM employees e
                    JOIN hierarchy h ON e.manager_id = h.id
                )
                SELECT * FROM hierarchy;

                Use Cases: Org charts, file trees, graph traversal
                """,
                tags: ["CTE", "WITH", "recursive", "hierarchy"]
            ),
            CSConcept(
                category: .sql,
                question: "Index Types & When to Use",
                answer: """
                B-Tree Index (default):
                • Balanced tree structure
                • Good for: =, <, >, <=, >=, BETWEEN, LIKE 'abc%'
                • Bad for: LIKE '%abc'

                Hash Index:
                • O(1) lookup
                • Only for equality (=)
                • Not for range queries

                Full-Text Index:
                • For text search
                • Supports MATCH AGAINST

                Composite Index:
                • Multiple columns
                • Leftmost prefix rule
                • INDEX(a,b,c) works for: a, a+b, a+b+c
                • NOT for: b, c, b+c

                Covering Index:
                • Contains all columns needed
                • No table lookup required
                • "Using index" in EXPLAIN
                """,
                tags: ["index", "B-Tree", "composite", "covering index"]
            )
        ]
    }
}
