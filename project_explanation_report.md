# LogiChain DBMS: Project Defense & Academic Presentation Report

**Course**: CSE3001 — Database Management Systems  
**Project Title**: LogiChain — Enterprise Supply Chain & Logistics Relational Database  
**Architecture**: 3-Level ANSI-SPARC Relational Architecture | Pure CLI Interface | Standard Relational SQL & Oracle PL/SQL  

---

## 1. Executive Summary & Project Purpose

### What is LogiChain?
LogiChain is a relational database management system modeled around supply chain, warehousing, fleet logistics, and cargo fulfillment. It was developed to implement and demonstrate the fundamental principles of database management systems specified in the university curriculum (CSE3001).

### Why Supply Chain Logistics?
Rather than a basic student or library management system, a logistics enterprise naturally demands:
1. **Multi-level hierarchies**: Spatial locations (Country -> State -> Region -> City), Employee hierarchy (CEO -> Directors -> Hub Managers -> Staff/Drivers), Product catalog taxonomy.
2. **Complex entity relationships**: Many-to-many associations ($M:N$) like suppliers supplying multiple products, and drivers holding multiple vehicle type certifications.
3. **Weak entities & cascading rules**: Warehouse bins and shipment items cannot exist without their parent warehouse and shipment records.
4. **Data integrity & financial rules**: Non-negative stock levels, price reduction threshold triggers, transparent audit logs for customer credit balances, and atomic multi-step order-inventory dispatches.

---

## 2. System Architecture & Relational Design

### 2.1 The Three-Level ANSI-SPARC Architecture

LogiChain adheres strictly to the classic ANSI-SPARC three-tier database standard:

```
+-------------------------------------------------------------------------+
|                        EXTERNAL LEVEL (User Views)                      |
|  [Driver Portal View]     [Warehouse Manager View]    [Auditor View]    |
+-------------------------------------------------------------------------+
                                    ▲
                                    │ (External / Conceptual Mapping)
                                    ▼
+-------------------------------------------------------------------------+
|                        CONCEPTUAL LEVEL (Logical Schema)                |
|  20 Normalized Relational Tables (CUSTOMER, ORDER, SHIPMENT, PRODUCT...) |
+-------------------------------------------------------------------------+
                                    ▲
                                    │ (Conceptual / Internal Mapping)
                                    ▼
+-------------------------------------------------------------------------+
|                        INTERNAL LEVEL (Physical Storage)                |
|  B+ Tree Indexes, Page Layouts, WAL Logs, Row Storage Blocks            |
+-------------------------------------------------------------------------+
```

1. **External Level (Views)**:
   - `VW_DRIVER_PUBLIC_PROFILE`: Restricts access to driver certifications and route dispatches, shielding sensitive employee salaries and commission structures.
   - `VW_WAREHOUSE_INVENTORY_METRICS`: Exposes stock availability and bin allocations while hiding financial margins.
   - `VW_ACTIVE_CUSTOMERS` & `VW_ACTIVE_PRODUCTS`: Updatable views created `WITH CHECK OPTION` to ensure DML consistency.
2. **Conceptual Level (Logical Schema)**:
   - 20 normalized relational entities defined with primary keys, foreign keys (`ON DELETE CASCADE`, `ON DELETE RESTRICT`), and domain `CHECK` constraints.
3. **Internal Level (Physical Storage)**:
   - Secondary B+ Tree indexes (`idx_orders_customer_date`, `idx_inventory_wh_prod`, `idx_shipment_driver_status`), sequential heap files, and Write-Ahead Logging (WAL) for durability.

### 2.2 Data Independence
- **Logical Data Independence**: The ability to modify the conceptual schema (e.g., adding columns or altering table structures) without breaking external views or client application code.
- **Physical Data Independence**: The ability to create secondary indexes, adjust fill factors, or reorganize disk storage without altering the conceptual schema or rewriting SQL queries.

---

## 3. Entity-Relationship (ER) Structure & Normalization

### 3.1 Entity Breakdown (20 Tables)

| Category | Entities | Key Characteristics |
| :--- | :--- | :--- |
| **Spatial & Taxonomy** | `GEOGRAPHY_LOCATION`, `PRODUCT_CATEGORY` | Master spatial hierarchy (`loc_id`) and self-referential category tree (`parent_category_id`). |
| **Organization & Fleet** | `EMPLOYEE`, `EMPLOYEE_DEPENDENT`, `VEHICLE_TYPE`, `VEHICLE`, `DRIVER_CERTIFICATION` | Recursive employee self-join (`manager_id`), weak dependent entity, vehicle classifications, and composite certification keys. |
| **Product & Inventory** | `SUPPLIER`, `PRODUCT`, `SUPPLIER_PRODUCT`, `WAREHOUSE`, `WAREHOUSE_BIN`, `INVENTORY_STOCK` | Associative $M:N$ supplier-product pricing, weak warehouse bins (`warehouse_id`, `bin_code`), and multi-depot stock quantities. |
| **Orders & Fulfillment** | `CUSTOMER`, `CUSTOMER_ORDER`, `ORDER_ITEM`, `SHIPMENT`, `SHIPMENT_ITEM` | Sales lifecycle, weak order line items and shipment manifests, dispatch timestamps, and freight costs. |
| **Audit & Security** | `AUDIT_CLIENT_LOG`, `AUDIT_INVENTORY_LOG` | Immutable historical audit tables tracking `UPDATE` and `DELETE` actions with old/new values, timestamps, and database users. |

### 3.2 Normalization Rigor (1NF to BCNF)
Every table was designed and mathematically proven from First Normal Form to Boyce-Codd Normal Form:
- **1NF**: All domain values are atomic; repeating order line items are flattened into the separate relation `ORDER_ITEM`.
- **2NF**: Eliminated partial dependencies on composite keys. In `ORDER_ITEM(order_id, item_seq)`, non-key attributes (`ordered_qty`, `unit_price`, `discount_rate`) depend on the full composite key, while product metadata is segregated into `PRODUCT(product_id)`.
- **3NF**: Eliminated transitive functional dependencies ($X \rightarrow Y \rightarrow Z$). In customer records, address attributes are segregated into `GEOGRAPHY_LOCATION(loc_id)`, removing the dependency `customer_id -> postal_code -> state`.
- **BCNF**: Every determinant in the relational schema is a candidate superkey (e.g., in `WAREHOUSE_BIN(warehouse_id, bin_code)`, the only functional determinant is the primary key itself).
- **Lossless Join Proof**: For decomposition $R \rightarrow (R_1, R_2)$, $(R_1 \cap R_2) \rightarrow R_2$ holds via primary key foreign key relationships.

---

## 4. Key Teacher Question: How is Concurrency Maintained in the Database?

When your teacher asks: **"How is the concurrency maintained in the database?"**, deliver this structured, professional answer.

### 4.1 The Short Answer (Viva Hook)
> "In LogiChain, concurrency is maintained through **Two-Phase Locking (2PL)** and **Transaction Isolation Levels** governed by ACID properties. 
> 
> At the theoretical level, we prevent anomalies like Dirty Reads and Lost Updates by enforcing Strict 2PL where exclusive write locks are held until commit. 
> 
> At the engine level, in our SQLite implementation, concurrency is managed using **Write-Ahead Logging (WAL)** and transaction locks (`DEFERRED`, `IMMEDIATE`, `EXCLUSIVE`), which allows concurrent readers without blocking writers. 
> 
> In enterprise environments like PostgreSQL and Oracle (which our schema and PL/SQL suite are designed for), concurrency is maintained via **Multi-Version Concurrency Control (MVCC)** with snapshot isolation and row-level locking."

---

### 4.2 The Detailed Technical Breakdown

#### A. The ACID Foundations
Concurrency control directly protects the **C (Consistency)** and **I (Isolation)** of ACID:
1. **Atomicity**: Either all operations of a transaction succeed, or all changes roll back.
2. **Consistency**: Transactions preserve all entity integrity, foreign keys, and domain checks.
3. **Isolation**: Concurrent transactions execute as if they were running serially in isolation.
4. **Durability**: Committed data persists across crashes via the Write-Ahead Log.

#### B. ANSI SQL Isolation Levels & Prevented Anomalies
Database concurrency control determines which anomalies are tolerated:

| Isolation Level | Dirty Read ($G_1$) | Non-Repeatable Read ($G_{2a}$) | Phantom Read ($A_3$) | Mechanism Used |
| :--- | :---: | :---: | :---: | :--- |
| **Read Uncommitted** | Allowed | Allowed | Allowed | No read locks; bare dirty reads. |
| **Read Committed** | **Prevented** | Allowed | Allowed | Short-term read locks or snapshot per statement. |
| **Repeatable Read** | **Prevented** | **Prevented** | Allowed | Long-term read locks or snapshot per transaction. |
| **Serializable** | **Prevented** | **Prevented** | **Prevented** | Strict 2PL, predicate locking, or Serializable Snapshot Isolation (SSI). |

- **Dirty Read**: Transaction $T_2$ reads uncommitted modifications written by $T_1$. If $T_1$ aborts, $T_2$ acted on phantom data.
- **Non-Repeatable Read**: Transaction $T_1$ reads a row; $T_2$ updates that row and commits; $T_1$ re-reads the row and observes altered values.
- **Phantom Read**: Transaction $T_1$ reads a range of tuples matching a predicate; $T_2$ inserts a new tuple satisfying that predicate and commits; $T_1$ re-queries and sees an additional row.

#### C. Two-Phase Locking (2PL) Protocol
Concurrency schedulers maintain serializability through Two-Phase Locking:
```
       Number of Locks
              ▲
              │            Lock Point (Max Locks)
              │                 ┌───┐
   Growing    │           ┌─────┘   └─────┐   Shrinking
   Phase      │     ┌─────┘               └─────┐  Phase
              │  ┌──┘                           └──┐
              └──┴─────────────────────────────────┴──► Time
```
1. **Growing Phase**: Transaction acquires locks (Shared `S` locks for reading, Exclusive `X` locks for writing) and cannot release any locks.
2. **Shrinking Phase**: Transaction releases locks and cannot acquire any new locks.
3. **Strict 2PL (Industry Standard)**: All Exclusive (`X`) write locks must be held until the transaction finishes (`COMMIT` or `ROLLBACK`). This prevents dirty reads and **completely eliminates cascading aborts**.

#### D. Implementation in LogiChain Codebase
1. **Savepoints & Transaction Control** ([`sql/queries/transactions_tcl.sql`](file:///home/muaviz/collegedev/logichain/sql/queries/transactions_tcl.sql)):
   - Demonstrates multi-step order placement and inventory reduction under a single atomic transaction.
   - Uses `SAVEPOINT svp_start`, allowing partial rollback on error without aborting the entire transaction.
2. **Write-Ahead Logging (WAL)**:
   - Configured in [`src/database.py`](file:///home/muaviz/collegedev/logichain/src/database.py). Readers read from the database file while writers write changes into the WAL file. Readers and writers do not block each other.
3. **Audit Triggers & Row-Level Integrity** ([`sql/triggers/01_audit_triggers.sql`](file:///home/muaviz/collegedev/logichain/sql/triggers/01_audit_triggers.sql)):
   - Executed within the caller's transaction context. If the outer transaction rolls back, the audit entry also rolls back, maintaining consistent audit state.

---

## 5. Lab Experiments & Feature Mapping (Labs 1–11)

| Experiment | Requirement in Curriculum | LogiChain Implementation |
| :--- | :--- | :--- |
| **Lab 1** | Flight & Pilot Certification (Joins & Division) | [`lab01_certification_queries.sql`](file:///home/muaviz/collegedev/logichain/sql/queries/lab_equivalents/lab01_certification_queries.sql): Pilot certification queries and Relational Division ($\div$) finding vehicle types certified by every senior driver. |
| **Lab 2** | Sailors, Boats & Reserves (25 Query Suite) | [`lab02_sailors_25_queries.sql`](file:///home/muaviz/collegedev/logichain/sql/queries/lab_equivalents/lab02_sailors_25_queries.sql): 25 queries covering `ALL`, `ANY`, correlated subqueries, set operations, and aggregate filters on Driver/Vehicle operations. |
| **Lab 3** | Multi-Dimensional Wholesale Aggregations | [`lab03_dimensional_olap.sql`](file:///home/muaviz/collegedev/logichain/sql/queries/lab_equivalents/lab03_dimensional_olap.sql): Product material sales, spatial hierarchy rollups (State -> Region -> City), and warehouse dispatch metrics on normalized tables. |
| **Lab 4** | Implicit Cursors & Hot Backup Script | [`03_oracle_cursors_savepoints.sql`](file:///home/muaviz/collegedev/logichain/sql/plsql_oracle/03_oracle_cursors_savepoints.sql) utilizing `SQL%FOUND`/`SQL%ROWCOUNT` + [`scripts/backup_restore.sh`](file:///home/muaviz/collegedev/logichain/scripts/backup_restore.sh) shell automation. |
| **Lab 5** | Transparent Audit Logging on Client Master | [`01_audit_triggers.sql`](file:///home/muaviz/collegedev/logichain/sql/triggers/01_audit_triggers.sql): Captures `UPDATE` and `DELETE` on `CUSTOMER` into `AUDIT_CLIENT_LOG` with old/new balances, user, and timestamps. |
| **Lab 6** | Cursor Loops with Savepoints & Cascade Delete | [`03_oracle_cursors_savepoints.sql`](file:///home/muaviz/collegedev/logichain/sql/plsql_oracle/03_oracle_cursors_savepoints.sql): Explicit cursor loop committing in batches of 10 rows and demonstrating `SAVEPOINT` rollbacks. |
| **Lab 7** | Mutual Exclusivity Rule & User-Defined Exceptions | [`04_oracle_exceptions.sql`](file:///home/muaviz/collegedev/logichain/sql/plsql_oracle/04_oracle_exceptions.sql): Enforces separation of duties (Driver cannot be Quality Inspector on the same shipment) via custom PL/SQL exceptions. |
| **Lab 8 & 9** | Stored Procedures with IN/OUT & Functions | [`05_oracle_procedures_functions.sql`](file:///home/muaviz/collegedev/logichain/sql/plsql_oracle/05_oracle_procedures_functions.sql): Stored procedure returning Driver Name & Salary via `OUT` parameters, and SQL-callable stored functions. |
| **Lab 10** | Error-Raising Triggers Blocking DML | [`02_business_rule_triggers.sql`](file:///home/muaviz/collegedev/logichain/sql/triggers/02_business_rule_triggers.sql): Triggers aborting illegal price drops > 75% or modifications to locked shipments with custom error messages. |
| **Lab 11** | Recursive Employee Hierarchy & Self-Joins | [`lab11_employee_hierarchy.sql`](file:///home/muaviz/collegedev/logichain/sql/queries/lab_equivalents/lab11_employee_hierarchy.sql): Manager-subordinate counts descending, self-joins, and handling `NULL` boss for the President/CEO. |

---

## 6. Viva Voce / Oral Examination Cheat Sheet

Here are the top questions examiners typically ask for this project, along with high-scoring answers:

### Q1: What makes a table in BCNF compared to 3NF?
**Answer**: In 3NF, for any non-trivial functional dependency $X \rightarrow Y$, $X$ must be a superkey OR $Y$ must be a prime attribute (part of some candidate key). BCNF removes that second condition: in BCNF, $X$ **must** be a superkey in every non-trivial dependency. BCNF strictly eliminates all anomalies arising from functional dependencies.

### Q2: What is a Weak Entity, and where did you use it?
**Answer**: A weak entity cannot be uniquely identified by its own attributes alone and depends on an owner entity via an identifying relationship. Its primary key consists of the owner entity's primary key plus its own partial discriminator. In LogiChain, `WAREHOUSE_BIN` (key: `warehouse_id, bin_code`), `SHIPMENT_ITEM` (key: `shipment_id, item_seq`), and `EMPLOYEE_DEPENDENT` (key: `emp_id, dependent_name`) are weak entities configured with `ON DELETE CASCADE`.

### Q3: What is the purpose of `WITH CHECK OPTION` on an updatable view?
**Answer**: When performing an `INSERT` or `UPDATE` through a view, `WITH CHECK OPTION` forces the DBMS to reject any DML statement where the new data does not satisfy the view's `WHERE` clause condition. This prevents inserting or updating rows that would immediately disappear from the view.

### Q4: How does Relational Division ($\div$) work in your SQL queries?
**Answer**: Relational division answers "for all" queries, such as "Find vehicle types driven by *every* senior driver." Since standard SQL lacks a native `DIVIDE` operator, we implement it mathematically using double negated existence (`NOT EXISTS ... NOT EXISTS`), which checks that there does not exist a driver who lacks certification for the given vehicle type.

### Q5: What is the difference between an explicit cursor and an implicit cursor?
**Answer**: An implicit cursor is generated automatically by the DBMS for single-row `SELECT` or DML statements (`SQL%FOUND`, `SQL%ROWCOUNT`). An explicit cursor is declared by the programmer (`CURSOR c_name IS SELECT...`) to fetch and iterate through a multi-row result set row-by-row with full programmatic control (`OPEN`, `FETCH`, `CLOSE`).

### Q6: What is the advantage of PL/SQL Packages over standalone procedures?
**Answer**: Packages group logically related types, cursors, variables, and subprograms together into a single unit. They offer:
1. **Modularity and Encapsulation**: Clear separation between public specifications (`PACKAGE`) and private hidden implementations (`PACKAGE BODY`).
2. **Performance**: When a package subprogram is called for the first time, the entire package is loaded into memory, avoiding repeated disk I/O on subsequent calls.

---

## 7. How to Demonstrate the Project to Your Teacher

Run these commands directly in your terminal to demonstrate the project live:

1. **Show the interactive CLI menu**:
   ```bash
   python3 -m src.cli
   ```
2. **Run the automated full demo** (presents entity row counts, division queries, sailor queries, aggregations, trigger intercepts, hierarchy, and ACID savepoint rollbacks):
   ```bash
   python3 -m src.cli --demo
   ```
3. **Execute the automated test suite** (demonstrates 10 passed tests verifying schema constraints, cascade deletions, triggers, and lab queries):
   ```bash
   pytest tests/ -v
   ```
4. **Demonstrate hot database backup and restore (Lab 4)**:
   ```bash
   ./scripts/backup_restore.sh backup
   ```
