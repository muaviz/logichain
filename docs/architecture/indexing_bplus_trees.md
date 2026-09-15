# Indexing Mechanics: B+ Trees & Hashing Schemes

This document details the mathematical structure and operational algorithms for B+ Tree Indexes and Hashing schemes implemented in modern relational database systems.
Maps directly to **CSE3001 Unit 4**.

---

## 1. B+ Tree Index Structure

A B+ Tree of order $n$ (maximum fan-out $n$) satisfies the following structural invariants:
1. Every internal node (except root) contains between $\lceil n/2 \rceil$ and $n$ child pointers.
2. Every leaf node contains between $\lceil (n-1)/2 \rceil$ and $n-1$ key values.
3. All leaf nodes are linked horizontally in a doubly-linked list for fast sequential range scans.
4. The tree is perfectly balanced (all leaf nodes reside at identical depth $h$).

```
                      ┌──────────────────────┐
                      │    [ K_20  |  K_50 ] │  Root Node (Internal)
                      └───┬──────┬──────┬────┘
                          │      │      │
            ┌─────────────┘      │      └─────────────┐
            ▼                    ▼                    ▼
     ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
     │ [K_5 | K_12]│      │[K_25 | K_38]│      │[K_60 | K_85]│ Internal Nodes
     └──┬───┬───┬──┘      └──┬───┬───┬──┘      └──┬───┬───┬──┘
        │   │   │            │   │   │            │   │   │
        ▼   ▼   ▼            ▼   ▼   ▼            ▼   ▼   ▼
     ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
     │[1..4] ───►  │──│[5..11] ───► │──│[20..24]───► │──│[50..59]───► │ Leaf Nodes
     └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘ (Data Pointers)
```

### 1.1 Fan-Out & Tree Depth Formulation
Let:
- Block / Page size $B = 8,192 \text{ bytes}$ (8 KB)
- Search key size $K = 8 \text{ bytes}$ (e.g. `order_id INTEGER / BIGINT`)
- Child pointer size $P = 8 \text{ bytes}$

Maximum order $n$:
$$n \times P + (n - 1) \times K \le B \implies 8n + 8(n - 1) \le 8192 \implies 16n \le 8200 \implies n = 512$$

With an average fan-out of 350 pointers per node:
- **Depth 1 (Root)**: $350 \text{ keys}$
- **Depth 2**: $350^2 = 122,500 \text{ keys}$
- **Depth 3**: $350^3 = 42,875,000 \text{ keys}$
- **Depth 4**: $350^4 = 15,006,250,000 \text{ keys}$

> **Result**: An indexed table with over 42 million orders requires at most **3 disk I/O operations** to retrieve any specific order tuple!

---

## 2. B+ Tree Operations

### 2.1 Search Algorithm
1. Start at root node.
2. In current internal node, find smallest key $K_i > \text{search\_key}$. Follow pointer $P_{i-1}$.
3. Repeat until leaf node is reached. Binary search within leaf block to locate tuple pointer.

### 2.2 Insertion with Node Splitting
1. Insert $(K, \text{record\_ptr})$ into target leaf in sorted order.
2. If leaf exceeds $(n - 1)$ keys:
   - Split leaf into two nodes containing $\lceil n/2 \rceil$ and $\lfloor n/2 \rfloor$ keys.
   - Copy up the smallest key of the second leaf to the parent internal node.
   - If parent overflows, propagate split upward toward root.

---

## 3. Static vs Dynamic Hashing

| Feature | Static Hashing | Extendible Dynamic Hashing | Linear Dynamic Hashing |
| :--- | :--- | :--- | :--- |
| **Directory Structure** | Fixed number of buckets $M$ | Dynamic global directory ($2^d$ entries) | Directory-less, incremental pointer $p$ |
| **Overflow Handling** | Overflow chaining (degrades to $O(N)$) | Bucket splitting & local depth increase | Bucket splitting at pointer $p$ round-robin |
| **Expansion Cost** | Requires full table rehashing | Doubles directory size in memory | Smooth incremental bucket allocation |
| **Best Used For** | Small static lookup tables | High-volume point-lookup key spaces | Write-heavy distributed key-value stores |
