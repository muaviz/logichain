# Concurrency Control: Multiple Granularity, Deadlocks & MVCC

This document details Multiple Granularity Locking, Deadlock handling protocols, and Multi-Version Concurrency Control (MVCC).
Maps directly to **CSE3001 Unit 5**.

---

## 1. Multiple Granularity Locking (MGL)

To balance concurrency vs locking overhead, database engines organize lockable resources into a Granularity Tree:

```
               Database Level
                     │
                     ▼
                Table Level
                     │
                     ▼
                 Page Level
                     │
                     ▼
                 Row Level
```

### 1.1 Intention Locks:
- **Intention Shared (IS)**: Indicates intent to acquire Shared (S) locks at a lower descendant node.
- **Intention Exclusive (IX)**: Indicates intent to acquire Exclusive (X) locks at a lower descendant node.
- **Shared Intention Exclusive (SIX)**: Explicit Shared lock on the entire subtree, with intent to acquire Exclusive (X) locks on specific lower rows.

### 1.2 Lock Compatibility Matrix:
| Requested \ Held | IS | IX | S | SIX | X |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **IS** | **YES** | **YES** | **YES** | **YES** | NO |
| **IX** | **YES** | **YES** | NO | NO | NO |
| **S** | **YES** | NO | **YES** | NO | NO |
| **SIX** | **YES** | NO | NO | NO | NO |
| **X** | NO | NO | NO | NO | NO |

---

## 2. Deadlock Handling Strategies

### 2.1 Deadlock Detection: Wait-For Graph (WFG)
- Construct directed graph $G = (V, E)$ where vertices $V$ represent active transactions and directed edge $T_1 \rightarrow T_2$ means $T_1$ is waiting for a lock held by $T_2$.
- **Cycle Detection**: If cycle exists (e.g. $T_1 \rightarrow T_2 \rightarrow T_1$), deadlock has occurred.
- **Victim Selection**: Choose transaction with least accumulated work, roll back to prior savepoint, and restart.

### 2.2 Deadlock Prevention: Timestamp Ordering Protocols
Let transaction $T_i$ have timestamp $TS(T_i)$ (smaller timestamp = older transaction):
1. **Wait-Die Protocol (Non-Preemptive)**:
   - If older $T_i$ requests lock held by younger $T_j$: $T_i$ is allowed to **WAIT**.
   - If younger $T_i$ requests lock held by older $T_j$: $T_i$ **DIES** (aborts and restarts).
2. **Wound-Wait Protocol (Preemptive)**:
   - If older $T_i$ requests lock held by younger $T_j$: $T_i$ **WOUNDS** $T_j$ (preempts/aborts $T_j$).
   - If younger $T_i$ requests lock held by older $T_j$: $T_i$ is allowed to **WAIT**.

---

## 3. Multi-Version Concurrency Control (MVCC)

Modern engines (PostgreSQL, Oracle) avoid read locks by storing multiple versions of every row:
- **PostgreSQL**: Each tuple contains system header columns:
  - `xmin`: Transaction ID of the creating transaction.
  - `xmax`: Transaction ID of the deleting/updating transaction.
  - A reading transaction $T_{\text{read}}$ reads the tuple snapshot where $\text{xmin} \le TS(T_{\text{read}})$ and $(\text{xmax} > TS(T_{\text{read}}) \lor \text{xmax} \text{ uncommitted})$.
- **Core Principle**: *"Readers never block Writers, and Writers never block Readers."*
