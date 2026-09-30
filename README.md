# LogiChain — Supply Chain & Logistics DBMS
### Academic Database Management System for Supply Chain & Logistics

---

## Executive Overview

LogiChain is an academic relational database system designed
around supply-chain and logistics operations.

The core application models and manages customers, orders,
products, suppliers, warehouses, inventory, shipments,
vehicles, and employees.

The repository also contains additional DBMS demonstrations
for SQL, views, triggers, indexing, stored routines,
analytics, concurrency, recovery, and related coursework topics.

### Key Highlights:
### Key Highlights

- **Core relational database**
  - Customers and orders
  - Products and suppliers
  - Warehouses and inventory
  - Shipments, vehicles, and employees

- **Database functionality**
  - SQL queries and joins
  - Views and triggers
  - Indexes
  - Stored procedures and functions
  - Transaction and integrity demonstrations

- **Analytics**
  - Dimensional/star-schema data model
  - Sales and shipment analysis

- **Academic demonstrations**
  - Concurrency and isolation
  - Deadlock detection
  - Two-phase commit
  - Recovery concepts
  - Oracle PL/SQL examples

---


## Project Scope

### Core Application

The main LogiChain application focuses on supply-chain and
logistics management through a relational database.

Core areas include:

- Customer and order management
- Product and supplier management
- Warehouse and inventory management
- Shipment and fleet management
- Employee and driver information
- SQL-based operational and analytical queries

### Academic DBMS Demonstrations

The repository also includes separate demonstrations and
documentation for database coursework concepts, including:

- Relational algebra and normalization
- Views and triggers
- Stored procedures and functions
- Indexing and query optimization
- Transactions and concurrency control
- Deadlock and two-phase commit demonstrations
- Recovery concepts
- Oracle PL/SQL examples

These modules support the academic objectives of the project
without representing separate core business applications.

## CSE3001 Syllabus & Lab Experiments Coverage Matrix

| Unit / Lab No. | Topic in Syllabus | LogiChain Implementation | Source File Link |
| :--- | :--- | :--- | :--- |
| **Unit 1** | ANSI-SPARC 3-Level Architecture, Data Independence, ER Diagrams, Weak Entity Sets, Attribute Types, Cardinalities | 3-Level Views, ER Crow's Foot specs, weak entities (`SHIPMENT_ITEM`, `WAREHOUSE_BIN`, `DEPENDENT`), composite/multivalued mappings. | [database_design.md](file:///home/muaviz/collegedev/logichain/docs/database_design.md), [er_diagram.mermaid](file:///home/muaviz/collegedev/logichain/docs/diagrams/er_diagram.mermaid) |
| **Unit 2** | Relational Models, Integrity Rules, Relational Algebra, Calculus (TRC), Codd's Rules, Normalization (1NF to 4NF) | Foreign key actions (`ON DELETE CASCADE`), formal $\sigma, \pi, \bowtie, \div, \cup, -, \rho, \gamma$ queries, Codd's audit, 1NF–4NF proofs. | [relational_algebra.md](file:///home/muaviz/collegedev/logichain/docs/theoretical/relational_algebra.md), [normalization_proofs.md](file:///home/muaviz/collegedev/logichain/docs/theoretical/normalization_proofs.md), [codds_rules.md](file:///home/muaviz/collegedev/logichain/docs/theoretical/codds_rules.md) |
| **Unit 3** | SQL DDL/DML/TCL, Joins, Subqueries, Aggregate Functions, Updatable & Materialized Views, Triggers, Sequences, Indexes | Master DDL, complex multi-table joins, correlated `EXISTS`, updatable views `WITH CHECK OPTION`, performance indexes. | [01_ddl_tables.sql](file:///home/muaviz/collegedev/logichain/sql/schema/01_ddl_tables.sql), [01_performance_indexes.sql](file:///home/muaviz/collegedev/logichain/sql/indexes/01_performance_indexes.sql), [01_updatable_views.sql](file:///home/muaviz/collegedev/logichain/sql/views/01_updatable_views.sql) |
| **Unit 4** | PL/SQL, %TYPE, %ROWTYPE, Cursors, Stored Procedures/Functions, Storage & RAID, B+ Trees, Dynamic Hashing, Query Optimization | PL/pgSQL & Oracle PL/SQL packages, explicit cursors, B+ Tree mathematical models, RAID 0/1/5/10 analysis, CBO formulas. | [02_oracle_packages.sql](file:///home/muaviz/collegedev/logichain/sql/plsql_oracle/02_oracle_packages.sql), [storage_and_raid.md](file:///home/muaviz/collegedev/logichain/docs/architecture/storage_and_raid.md), [indexing_bplus_trees.md](file:///home/muaviz/collegedev/logichain/docs/architecture/indexing_bplus_trees.md), [query_optimization.md](file:///home/muaviz/collegedev/logichain/docs/performance/query_optimization.md) |
| **Unit 5** | ACID Properties, Isolation Levels, Serializability, Concurrency Control (2PL, Deadlocks, MVCC, 2PC), ARIES Recovery | Concurrency test runner, deadlock detector, 2PC simulation, Strict/Rigorous 2PL specs, ARIES Analysis/Redo/Undo workflows. | [acid_and_isolation.md](file:///home/muaviz/collegedev/logichain/docs/transactions/acid_and_isolation.md), [concurrency_control.md](file:///home/muaviz/collegedev/logichain/docs/transactions/concurrency_control.md), [recovery_and_aries.md](file:///home/muaviz/collegedev/logichain/docs/transactions/recovery_and_aries.md) |
| **Lab 1** | Airline Flight & Pilot Certification (Complex Joins & Division) | Fleet vehicle and driver certification queries with Relational Division ($\div$) over certified vehicles. | [lab01_certification_queries.sql](file:///home/muaviz/collegedev/logichain/sql/queries/lab_equivalents/lab01_certification_queries.sql) |
| **Lab 2** | Sailors, Boats & Reserves (25 Queries: ALL, ANY, Aggregations, Outer Joins) | Complete 25-query benchmark catalog on Driver/Fleet operations matching all 25 queries. | [lab02_sailors_25_queries.sql](file:///home/muaviz/collegedev/logichain/sql/queries/lab_equivalents/lab02_sailors_25_queries.sql) |
| **Lab 3** | Wholesale Multi-Dimensional Data Warehouse (Product, Spatial, Time, Sales) | Star/Snowflake schema (`FACT_SALES_SHIPMENT`, `DIM_*`) with OLAP aggregations (`ROLLUP`, `CUBE`, material/city analytics). | [03_data_warehouse_star_schema.sql](file:///home/muaviz/collegedev/logichain/sql/schema/03_data_warehouse_star_schema.sql), [lab03_dimensional_olap.sql](file:///home/muaviz/collegedev/logichain/sql/queries/lab_equivalents/lab03_dimensional_olap.sql) |
| **Lab 4** | Shipping Manifest Implicit Cursor & Hot DB Backup Script | PL/SQL block utilizing `SQL%FOUND`, `SQL%ROWCOUNT` + hot database backup/restore shell automation. | [03_oracle_cursors_savepoints.sql](file:///home/muaviz/collegedev/logichain/sql/plsql_oracle/03_oracle_cursors_savepoints.sql), [backup_restore.sh](file:///home/muaviz/collegedev/logichain/scripts/backup_restore.sh) |
| **Lab 5** | Transparent Audit System on Client_Master (`AUDIT_CLIENT_LOG`) | Trigger tracking `UPDATE` and `DELETE` on `CUSTOMER` with before-image balance, operation type, user, and timestamp. | [01_audit_triggers.sql](file:///home/muaviz/collegedev/logichain/sql/triggers/01_audit_triggers.sql) |
| **Lab 6** | Supplier & Parts Cursor with Savepoints, Deleting Every 10th Row & ON DELETE CASCADE | Explicit cursor loop committing in batches, rolling back to savepoints, deleting every Nth row with cascade verification. | [03_oracle_cursors_savepoints.sql](file:///home/muaviz/collegedev/logichain/sql/plsql_oracle/03_oracle_cursors_savepoints.sql) |
| **Lab 7** | Mutual Exclusivity Business Rule with Custom Exceptions | Enforces separation of duties (Driver cannot be Quality Inspector on same shipment), raising user-defined exceptions. | [03_driver_exclusivity.sql](file:///home/muaviz/collegedev/logichain/sql/procedures_plpgsql/03_driver_exclusivity.sql), [04_oracle_exceptions.sql](file:///home/muaviz/collegedev/logichain/sql/plsql_oracle/04_oracle_exceptions.sql) |
| **Lab 8 & 9** | Stored Procedures with IN/OUT, SQL-Callable Stored Function & 10% Salary Bump | Stored procedure returning Driver Name & Salary via `OUT` parameters, function returning depot location in SQL, 10% raise script. | [02_employee_bonus.sql](file:///home/muaviz/collegedev/logichain/sql/procedures_plpgsql/02_employee_bonus.sql), [05_oracle_procedures_functions.sql](file:///home/muaviz/collegedev/logichain/sql/plsql_oracle/05_oracle_procedures_functions.sql) |
| **Lab 10** | Trigger Raising User-Defined Error to Block Unauthorized DML | Triggers preventing unauthorized price reductions > 75% or discontinued product ordering with custom error codes. | [02_business_rule_triggers.sql](file:///home/muaviz/collegedev/logichain/sql/triggers/02_business_rule_triggers.sql), [04_oracle_exceptions.sql](file:///home/muaviz/collegedev/logichain/sql/plsql_oracle/04_oracle_exceptions.sql) |
| **Lab 11** | Employee & Department Hierarchy (Self-Joins, Boss of President = NULL, Subordinate Rankings) | Recursive hierarchy queries, department groupings, President NULL boss handling, and subordinate counts descending. | [lab11_employee_hierarchy.sql](file:///home/muaviz/collegedev/logichain/sql/queries/lab_equivalents/lab11_employee_hierarchy.sql) |

---

## System Architecture & Entity-Relationship (ER) Model

```mermaid
erDiagram
    GEOGRAPHY_LOCATION ||--o{ WAREHOUSE : "located in"
    GEOGRAPHY_LOCATION ||--o{ CUSTOMER : "resides in"
    GEOGRAPHY_LOCATION ||--o{ SUPPLIER : "operates in"

    SUPPLIER ||--o{ SUPPLIER_PRODUCT : "supplies"
    PRODUCT ||--o{ SUPPLIER_PRODUCT : "supplied by"
    PRODUCT_CATEGORY ||--o{ PRODUCT : "categorizes"
    
    PRODUCT ||--o{ INVENTORY_STOCK : "stocked as"
    WAREHOUSE ||--o{ INVENTORY_STOCK : "stores"
    WAREHOUSE ||--o{ WAREHOUSE_BIN : "contains (weak)"
    WAREHOUSE_BIN ||--o{ INVENTORY_STOCK : "allocates"

    EMPLOYEE ||--o{ EMPLOYEE : "reports to (self-join)"
    EMPLOYEE ||--o{ EMPLOYEE_DEPENDENT : "supports (weak)"
    EMPLOYEE ||--o{ DRIVER_CERTIFICATION : "holds"
    VEHICLE_TYPE ||--o{ DRIVER_CERTIFICATION : "qualifies"
    VEHICLE_TYPE ||--o{ VEHICLE : "classifies"
    WAREHOUSE ||--o{ VEHICLE : "garages"

    CUSTOMER ||--o{ CUSTOMER_ORDER : "places"
    CUSTOMER_ORDER ||--o{ ORDER_ITEM : "contains"
    PRODUCT ||--o{ ORDER_ITEM : "ordered in"

    CUSTOMER_ORDER ||--o{ SHIPMENT : "fulfilled via"
    WAREHOUSE ||--o{ SHIPMENT : "dispatches"
    VEHICLE ||--o{ SHIPMENT : "transports"
    EMPLOYEE ||--o{ SHIPMENT : "drives / inspects"
    SHIPMENT ||--o{ SHIPMENT_ITEM : "manifests (weak)"
    PRODUCT ||--o{ SHIPMENT_ITEM : "shipped as"

    CUSTOMER ||--o{ AUDIT_CLIENT_LOG : "audited into"
    INVENTORY_STOCK ||--o{ AUDIT_INVENTORY_LOG : "tracked into"
```

---

## Quickstart & Interactive Demonstration

### 1. Initialize Database & Seed Records
```bash
./scripts/setup_database.sh
```

### 2. Launch the Interactive Rich Terminal CLI
```bash
python3 -m src.cli
```
The CLI provides an interactive interface for exploring the
core supply-chain database, running SQL and analytics queries,
viewing integrity and audit demonstrations, and accessing
advanced DBMS simulations.

```
  _             _  ____ _           _       
 | |   ___   __ _(_)/ ___| |__   __ _(_)_ __  
 | |  / _ \ / _` | | |   | '_ \ / _` | | '_ \ 
 | | | (_) | (_| | | |___| | | | (_| | | | | |
 |_|  \___/ \__, |_|\____|_| |_|\__,_|_|_| |_|
            |___/                             
  Enterprise Supply Chain & Logistics DBMS Suite

Select an Option:
  LogiChain - Supply Chain & Logistics DBMS

Main Menu

[1] View Database Statistics
[2] SQL & Analytics
[3] Database Integrity & Auditing
[4] Employee Hierarchy
[5] Advanced DBMS Demonstrations
[6] Database Management
[0] Exit
```

### 3. Run the Automated Concurrency & ACID Test Suite
```bash
./scripts/run_concurrency_tests.sh
```

### 4. Run Pytest Test Suite
```bash
pytest tests/ -v
```

### 5. Launch Web GUI Control Center & REST API
```bash
uvicorn src.api.app:app --host 127.0.0.1 --port 8000 --reload
```
- Open Interactive Web GUI Dashboard at: `http://127.0.0.1:8000/` (or `/dashboard`)
- Open Swagger API documentation at: `http://127.0.0.1:8000/docs`

---

## Codebase Directory Layout

```
/home/muaviz/collegedev/logichain/
├── README.md                           <- Master academic documentation & overview
├── requirements.txt                    <- Python dependencies (fastapi, rich, pytest)
├── .env.example                        <- Configuration template
├── docs/                               <- Comprehensive DBMS Syllabus Documentation
│   ├── database_design.md              <- ANSI-SPARC 3-Level Architecture & ER Specs
│   ├── diagrams/
│   │   ├── er_diagram.mermaid          <- High-res Crow's Foot ERD
│   │   ├── schema_relational_model.mermaid
│   │   ├── transaction_states.mermaid
│   │   └── aries_recovery_flow.mermaid
│   ├── theoretical/
│   │   ├── relational_algebra.md       <- Formal Relational Algebra & TRC formulas
│   │   ├── codds_rules.md              <- Evaluation of Codd's 12 Rules
│   │   └── normalization_proofs.md     <- 1NF to 4NF proofs with FDs & MVDs
│   ├── architecture/
│   │   ├── storage_and_raid.md         <- RAID 0/1/5/10, block formats, file layout
│   │   └── indexing_bplus_trees.md     <- B+ Tree math, split algorithms & Hashing
│   ├── performance/
│   │   └── query_optimization.md       <- Heuristic optimization rules & CBO models
│   └── transactions/
│       ├── acid_and_isolation.md       <- Isolation levels, anomalies, 2PL protocols
│       ├── concurrency_control.md      <- Multiple Granularity, Deadlocks & MVCC
│       └── recovery_and_aries.md       <- WAL, Checkpoints & ARIES algorithm
├── sql/
│   ├── schema/
│   │   ├── 01_ddl_tables.sql           <- Master DDL with all relational integrity rules
│   │   ├── 02_seed_data.sql            <- Rich enterprise dataset (20+ entities)
│   │   └── 03_data_warehouse_star_schema.sql <- Star & Snowflake dimensional schema
│   ├── views/
│   │   ├── 01_updatable_views.sql      <- Updatable views (WITH CHECK OPTION)
│   │   ├── 02_security_views.sql       <- User-role security & abstraction views
│   │   └── 03_materialized_views.sql   <- Analytical summary views
│   ├── indexes/
│   │   └── 01_performance_indexes.sql  <- B-Tree, Composite, Hash & Partial indexes
│   ├── triggers/
│   │   ├── 01_audit_triggers.sql       <- Transparent audit triggers (Lab 5)
│   │   ├── 02_business_rule_triggers.sql <- Error-raising triggers (Lab 10)
│   │   └── 03_inventory_sync_triggers.sql
│   ├── procedures_plpgsql/
│   │   ├── 01_stock_transfer.sql       <- Stock transfer procedure with savepoints (Lab 6)
│   │   ├── 02_employee_bonus.sql       <- IN/OUT procedure & SQL function (Lab 8, 9)
│   │   └── 03_driver_exclusivity.sql   <- Business exception procedure (Lab 7)
│   ├── plsql_oracle/                   <- 100% Native Oracle PL/SQL Suite
│   │   ├── 01_oracle_ddl_sequences.sql <- Oracle DDL, Sequences, Synonyms
│   │   ├── 02_oracle_packages.sql      <- Modular PL/SQL Packages (Specs & Bodies)
│   │   ├── 03_oracle_cursors_savepoints.sql <- Explicit Cursors, Savepoints (Lab 4, 6)
│   │   ├── 04_oracle_exceptions.sql    <- User-defined exceptions (Lab 7, 10)
│   │   └── 05_oracle_procedures_functions.sql <- Stored routines with IN/OUT (Lab 8, 9)
│   └── queries/
│       ├── lab_equivalents/            <- Direct mapping of Labs 1 to 11
│       │   ├── lab01_certification_queries.sql
│       │   ├── lab02_sailors_25_queries.sql
│       │   ├── lab03_dimensional_olap.sql
│       │   └── lab11_employee_hierarchy.sql
│       ├── advanced_queries.sql        <- Subqueries, Correlated EXISTS, Division
│       ├── set_operations.sql          <- UNION, INTERSECT, EXCEPT / MINUS
│       └── transactions_tcl.sql        <- COMMIT, ROLLBACK, SAVEPOINT scripts
├── src/
│   ├── config.py                       <- Database and environment configuration
│   ├── database.py                     <- Core DB connection and query execution interface
│   ├── schema_loader.py                <- Automated DDL/DML runner and initializer
│   ├── cli.py                          <- Interactive Rich Terminal CLI runner
│   ├── api/                            <- FastAPI REST Endpoints
│   │   ├── app.py
│   │   └── routers/
│   │       ├── inventory.py
│   │       ├── shipments.py
│   │       ├── analytics.py
│   │       └── audit.py
│   └── simulations/
│       ├── isolation_runner.py         <- Runs concurrency anomaly demos
│       ├── deadlock_runner.py          <- Runs deadlock detection demo
│       └── two_phase_commit.py         <- Simulates 2PC across distributed depots
├── tests/
│   ├── test_schema_integrity.py        <- Validates PKs, FKs, CHECK constraints
│   ├── test_triggers_and_audit.py      <- Validates transparent audit logging
│   ├── test_isolation_levels.py        <- Automated tests for ACID isolation & 2PC
│   └── test_lab_queries.py             <- Validates Lab 1 to 11 queries
└── scripts/
    ├── setup_database.sh               <- Automates DB setup & seeding
    ├── run_concurrency_tests.sh        <- Runs transaction & deadlock test suite
    └── backup_restore.sh               <- Database backup & restore script (Lab 4)
```
