# Query Processing & Optimization Mechanics

This document details query evaluation pipelines, heuristic equivalence transformations, and Cost-Based Optimization (CBO) models.
Maps directly to **CSE3001 Unit 4**.

---

## 1. Query Processing Pipeline

```
     SQL Query Text
           │
           ▼
  [ 1. Lexical & Syntax Parser ]  ──► Validates tokens & grammar
           │
           ▼
  [ 2. Query Tree Generator ]     ──► Translates to Relational Algebra Tree
           │
           ▼
  [ 3. Heuristic Optimizer ]      ──► Pushes Selections & Projections Early
           │
           ▼
  [ 4. Cost-Based Optimizer (CBO) ]─► Evaluates access paths using catalog statistics
           │
           ▼
  [ 5. Execution Engine ]         ──► Evaluates physical operators & returns tuples
```

---

## 2. Heuristic Optimization Rules (Algebraic Equivalences)

Heuristic optimization transforms relational algebra trees into equivalent trees with minimal intermediate tuple sizes:

### Rule 1: Commutativity & Associativity of Joins
$$R \bowtie S \equiv S \bowtie R$$
$$(R \bowtie S) \bowtie T \equiv R \bowtie (S \bowtie T)$$

### Rule 2: Pushing Selections Below Joins (Early Filtering)
If predicate $c_1$ involves only attributes from relation $R$:
$$\sigma_{c_1 \land c_2}(R \bowtie S) \equiv \sigma_{c_2}(\sigma_{c_1}(R) \bowtie S)$$

> **Example**: Filtering $\text{status} = \text{'DELIVERED'}$ on `SHIPMENT` before joining with `CUSTOMER_ORDER` reduces join inputs from 1,000,000 rows to 50,000 rows, yielding a 95% reduction in join memory.

### Rule 3: Pushing Projections Early (Minimizing Tuple Width)
$$\pi_{A_1, B_1}(R \bowtie S) \equiv \pi_{A_1, B_1}(\pi_{A_1, \text{join\_key}}(R) \bowtie \pi_{B_1, \text{join\_key}}(S))$$

---

## 3. Cost-Based Optimization (CBO) Cost Formulas

The estimated execution cost $C$ is modeled as a function of Disk Block Transfers ($B$), Disk Seeks ($S$), and CPU Instruction Cycles ($C_{\text{cpu}}$):

$$\text{Cost} = (B \times t_T) + (S \times t_S) + (N_{\text{tuples}} \times t_{\text{cpu}})$$

Where:
- $t_T$: Block transfer time ($\approx 0.1 \text{ ms}$ on NVMe / $1 \text{ ms}$ on HDD)
- $t_S$: Average disk seek time ($\approx 4 \text{ ms}$ on HDD, negligible on Flash)
- $t_{\text{cpu}}$: CPU evaluation cost per tuple

### Cost Comparison: Table Scan vs B+ Tree Index Scan

Let:
- Table Size = 100,000 blocks
- Number of matching tuples = 5 tuples

1. **Sequential Table Scan Cost**:
   $$\text{Cost}_{\text{seq}} = B = 100,000 \text{ block transfers} \approx 10.0 \text{ seconds}$$
2. **B+ Tree Secondary Index Scan Cost**:
   $$\text{Cost}_{\text{index}} = (\text{Tree\_Height} + N_{\text{matches}}) \times (\text{Seek} + \text{Transfer}) = (3 + 5) \times 0.1 \text{ ms} \approx 0.8 \text{ milliseconds}$$

> **Speedup Factor**: $\frac{10,000 \text{ ms}}{0.8 \text{ ms}} = \mathbf{12,500\times \text{ Performance Gain}}$

---

## 4. Join Physical Operator Selection

| Join Algorithm | Best Used When | Time Complexity | Memory Requirements |
| :--- | :--- | :--- | :--- |
| **Nested Loop Join** | Outer relation is tiny ($\le 100$ rows) and inner relation has an index on join key. | $O(M \times \log N)$ with index | $O(1)$ blocks |
| **Hash Join** | Large relations with equi-join condition ($R.x = S.x$). | $O(M + N)$ | $O(\min(M, N))$ blocks for hash table in RAM |
| **Merge Join** | Both inputs are already sorted on join keys (e.g. via B+ Tree index). | $O(M + N)$ | $O(1)$ blocks (streaming) |
