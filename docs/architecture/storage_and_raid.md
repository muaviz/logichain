# Physical Storage Media, File Organization & RAID Architectures

This document details the internal physical storage hierarchy, record formats, and RAID storage strategies implemented in enterprise relational database systems.
Maps directly to **CSE3001 Unit 4**.

---

## 1. Storage Media Hierarchy

```
   ┌───────────────────────────┐  Fastest, Most Expensive, Volatile
   │    CPU Registers & Cache  │  (Nanoseconds)
   ├───────────────────────────┤
   │     Main Memory (RAM)     │  (10 - 100 ns) - Buffer Pool / Shared Buffers
   ├───────────────────────────┤
   │    Flash Memory (NVMe)    │  (10 - 100 µs) - High IOPS Data & Indexes
   ├───────────────────────────┤
   │  Magnetic Disk (HDD/SAN)  │  (5 - 10 ms) - Cold Archives & Long-Term Logs
   ├───────────────────────────┤
   │    Optical / Tape Backup  │  Slowest, Cheapest, Non-Volatile (Seconds/Mins)
   └───────────────────────────┘
```

---

## 2. File and Record Organization

### 2.1 Fixed-Length vs Variable-Length Records
- **Fixed-Length Records**: Attributes have predetermined byte widths (e.g., `loc_id INTEGER` (4 bytes), `country CHAR(3)` (3 bytes)). Tuples are addressable via direct byte offset calculation:
  $$\text{Offset}(i) = i \times \text{Record\_Size}$$
- **Variable-Length Records**: Attributes utilize `VARCHAR` and nullable fields. Stored using a **Slotted-Page Architecture**:
  - *Page Header*: Tracks number of record entries, end of free space pointer, and an array of slot offsets $(offset_i, length_i)$.
  - Records grow from the bottom of the page upward, while slot entries grow from the top downward.

### 2.2 Heap File Organization
- Tuples are inserted into any page with sufficient free space without predefined ordering.
- Best for high-velocity `INSERT` workloads (e.g. `AUDIT_CLIENT_LOG`).

### 2.3 Clustered File Organization
- Related records from different tables are stored physically on the same disk block (e.g., `CUSTOMER_ORDER` stored on the same page as its child `ORDER_ITEM` rows) to eliminate multi-block disk seeks during join queries.

---

## 3. RAID (Redundant Array of Independent Disks) Comparative Analysis

| RAID Level | Description | Minimum Disks | Data Striping | Data Mirroring | Parity Type | Write Penalty | Recommended Enterprise DB Use Case |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **RAID 0** | Block Striping without redundancy | 2 | Yes (Block) | No | None | 0 | Temporary tablespaces, volatile scratch buffers (Not for production data). |
| **RAID 1** | Disk Mirroring | 2 | No | Yes (100%) | None | 1 write per mirror | Write-Ahead Log (WAL) disks requiring ultra-low latency. |
| **RAID 5** | Block Striping with Distributed Parity | 3 | Yes (Block) | No | Distributed $(N-1)$ | 4 I/Os (Read-Modify-Write) | Read-heavy Data Warehouses and Reporting Marts. |
| **RAID 10 (1+0)**| Striping of Mirrored Sets | 4 | Yes (Block) | Yes (Mirrored) | None | 2 I/Os | **Primary OLTP Databases (LogiChain Recommended)** for maximum I/O throughput and fault tolerance. |
