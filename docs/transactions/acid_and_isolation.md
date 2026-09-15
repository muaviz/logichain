# Transaction Management: ACID Properties & ANSI Isolation Levels

This document details the formal transaction lifecycle, ACID properties, ANSI SQL isolation levels, and Two-Phase Locking (2PL) protocols.
Maps directly to **CSE3001 Unit 5**.

---

## 1. The ACID Properties

| Property | Definition | Database Subsystem Responsible |
| :--- | :--- | :--- |
| **Atomicity** | "All or Nothing" — either all operations in transaction $T$ execute to completion, or the database is left in its pre-transaction state. | Recovery Manager & Write-Ahead Logging (WAL) / Rollback Undo Log. |
| **Consistency** | Transaction execution transforms database from one valid state satisfying all schema constraints to another valid state. | DBMS Constraint Engine (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, Triggers). |
| **Isolation** | Execution of transaction $T$ is shielded from concurrent transactions as if it were running alone. | Concurrency Control Manager (Locking / 2PL / MVCC / Serialization graphs). |
| **Durability** | Once committed, all state changes made by $T$ persist permanently on non-volatile media, surviving system crashes. | Recovery Subsystem, Flush to Non-Volatile Disk (`fsync`), WAL Logs. |

---

## 2. ANSI SQL Isolation Levels vs Concurrency Anomalies

| Isolation Level | Dirty Read ($G_1$) | Non-Repeatable Read ($G_{2a}$) | Phantom Read ($A_3$) | Write Skew / Serialization Anomaly |
| :--- | :---: | :---: | :---: | :---: |
| **Read Uncommitted** | Allowed | Allowed | Allowed | Allowed |
| **Read Committed** | **Prevented** | Allowed | Allowed | Allowed |
| **Repeatable Read** | **Prevented** | **Prevented** | Allowed (in some engines) | Allowed |
| **Serializable** | **Prevented** | **Prevented** | **Prevented** | **Prevented** |

---

## 3. Two-Phase Locking (2PL) Protocols

Under Two-Phase Locking, a transaction acquires locks in an **Expanding (Growing) Phase** and releases locks in a **Shrinking Phase**. Once a lock is released, no new lock may be acquired.

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

### 3.1 Variations of 2PL
1. **Basic 2PL**: Locks released whenever no longer needed during shrinking phase. (Subject to Cascading Aborts).
2. **Strict 2PL**: All Exclusive (X) locks held until transaction commits or aborts. (**Prevents Cascading Aborts**).
3. **Rigorous 2PL**: **ALL** locks (Shared 'S' and Exclusive 'X') held until commit. (Guarantees Strict Conflict Serializability in order of commit).
4. **Conservative 2PL**: Pre-declares and acquires all required locks prior to execution. (**Deadlock-Free**, but reduces concurrency).
