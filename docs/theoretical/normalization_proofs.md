# Mathematical Normalization Proofs: 1NF to 4NF

This document details the step-by-step mathematical decomposition, functional dependency proofs, lossless join verification, and multi-valued dependency resolution for the LogiChain database schema.
Maps directly to **CSE3001 Unit 2**.

---

## 1. Functional Dependency Notation & Armstrong's Axioms

Let $R(A_1, A_2, \dots, A_n)$ be a relational schema. A **Functional Dependency (FD)** $X \rightarrow Y$ states that whenever two tuples agree on attributes $X$, they must agree on attributes $Y$.

### Armstrong's Axioms:
1. **Reflexivity Rule**: If $Y \subseteq X$, then $X \rightarrow Y$.
2. **Augmentation Rule**: If $X \rightarrow Y$, then $XZ \rightarrow YZ$ for any $Z$.
3. **Transitivity Rule**: If $X \rightarrow Y$ and $Y \rightarrow Z$, then $X \rightarrow Z$.

### Derived Rules:
- **Union Rule**: If $X \rightarrow Y$ and $X \rightarrow Z$, then $X \rightarrow YZ$.
- **Decomposition Rule**: If $X \rightarrow YZ$, then $X \rightarrow Y$ and $X \rightarrow Z$.
- **Pseudo-transitivity Rule**: If $X \rightarrow Y$ and $WY \rightarrow Z$, then $WX \rightarrow Z$.

---

## 2. Step-by-Step Normalization Process

### 2.1 Unnormalized Form (UNF) to 1NF (First Normal Form)
- **Definition of 1NF**: A relation is in 1NF if and only if all domain values are atomic (indivisible) and there are no repeating groups.
- **Unnormalized State**:
  $$\text{UNF\_ORDERS}(\underline{\text{order\_id}}, \text{customer\_id}, \text{order\_date}, \{\text{item\_seq}, \text{product\_id}, \text{ordered\_qty}, \text{unit\_price}\})$$
- **1NF Decomposition**: Flatten repeating groups into discrete tuples:
  $$\text{CUSTOMER\_ORDER}(\underline{\text{order\_id}}, \text{customer\_id}, \text{order\_date}, \text{status})$$
  $$\text{ORDER\_ITEM}(\underline{\text{order\_id}, \text{item\_seq}}, \text{product\_id}, \text{ordered\_qty}, \text{unit\_price})$$

---

### 2.2 1NF to 2NF (Second Normal Form)
- **Definition of 2NF**: A relation is in 2NF if it is in 1NF and **every non-prime attribute is fully functionally dependent on the entire primary key** (no partial functional dependencies).
- **Violation in Composite Relation**:
  Consider $\text{ORDER\_LINE}(\underline{\text{order\_id}, \text{product\_id}}, \text{ordered\_qty}, \text{unit\_price}, \text{product\_name}, \text{material\_type}, \text{base\_price})$.
  - *Candidate Key*: $\{\text{order\_id}, \text{product\_id}\}$
  - *Functional Dependencies*:
    1. $\{\text{order\_id}, \text{product\_id}\} \rightarrow \text{ordered\_qty}, \text{unit\_price}$ (Full Dependency)
    2. $\text{product\_id} \rightarrow \text{product\_name}, \text{material\_type}, \text{base\_price}$ (**Partial Dependency** on a subset of the candidate key!)
- **2NF Decomposition**:
  $$R_1 = \text{ORDER\_ITEM}(\underline{\text{order\_id}, \text{product\_id}}, \text{ordered\_qty}, \text{unit\_price})$$
  $$R_2 = \text{PRODUCT}(\underline{\text{product\_id}}, \text{product\_name}, \text{material\_type}, \text{base\_price})$$

---

### 2.3 2NF to 3NF (Third Normal Form)
- **Definition of 3NF**: A relation is in 3NF if it is in 2NF and **no non-prime attribute is transitively dependent on the primary key** ($X \rightarrow Y$ and $Y \rightarrow Z$, where $Y$ is not a candidate key).
- **Violation in Customer Table**:
  Consider $\text{CUSTOMER\_RAW}(\underline{\text{customer\_id}}, \text{company\_name}, \text{contact\_email}, \text{city}, \text{region}, \text{state}, \text{country}, \text{postal\_code})$.
  - *Primary Key*: $\text{customer\_id}$
  - *Functional Dependencies*:
    1. $\text{customer\_id} \rightarrow \text{company\_name}, \text{contact\_email}, \text{postal\_code}$
    2. $\text{postal\_code} \rightarrow \text{city}, \text{region}, \text{state}, \text{country}$ (**Transitive Dependency** $\text{customer\_id} \rightarrow \text{postal\_code} \rightarrow \text{state}$)
- **3NF Decomposition**:
  $$R_1 = \text{CUSTOMER}(\underline{\text{customer\_id}}, \text{company\_name}, \text{contact\_email}, \text{loc\_id})$$
  $$R_2 = \text{GEOGRAPHY\_LOCATION}(\underline{\text{loc\_id}}, \text{city}, \text{region}, \text{state}, \text{country}, \text{postal\_code})$$

---

### 2.4 3NF to BCNF (Boyce-Codd Normal Form)
- **Definition of BCNF**: A relation is in BCNF if and only if for every non-trivial functional dependency $X \rightarrow Y$, **$X$ is a Superkey**.
- **Verification Across LogiChain Relations**:
  In `WAREHOUSE_BIN` $(\underline{\text{warehouse\_id}, \text{bin\_code}}, \text{aisle}, \text{rack}, \text{shelf\_level}, \text{zone\_type})$:
  - The only determinant is $\{\text{warehouse\_id}, \text{bin\_code}\}$, which is the primary key.
  - Since every determinant is a superkey, the relation is strictly in BCNF.

---

### 2.5 4NF (Fourth Normal Form) & Multi-Valued Dependencies (MVDs)
- **Definition of Multi-Valued Dependency ($X \twoheadrightarrow Y$)**:
  In relation $R(X, Y, Z)$, $X \twoheadrightarrow Y$ means that the set of $Y$ values associated with a given $X$ value depends only on $X$ and is completely independent of the $Z$ values.
- **Definition of 4NF**: A relation is in 4NF if it is in BCNF and for every non-trivial MVD $X \twoheadrightarrow Y$, $X$ is a superkey.
- **Violation Scenario**:
  Suppose we modeled supplier capabilities in a single table:
  $$\text{SUPPLIER\_INFO}(\underline{\text{supplier\_id}, \text{product\_category}, \text{service\_region}})$$
  - *Independent Facts*: A supplier provides multiple categories (Wood, Steel) and operates in multiple regions (Northeast, West).
  - *MVDs*:
    1. $\text{supplier\_id} \twoheadrightarrow \text{product\_category}$
    2. $\text{supplier\_id} \twoheadrightarrow \text{service\_region}$
  - Storing these together creates redundant cross-product tuples.
- **4NF Decomposition**:
  Decompose into two independent binary relations:
  $$R_1 = \text{SUPPLIER\_CATEGORY}(\underline{\text{supplier\_id}, \text{category\_id}})$$
  $$R_2 = \text{SUPPLIER\_REGION}(\underline{\text{supplier\_id}, \text{loc\_id}})$$

---

## 3. Lossless Join Decomposition Proof

A decomposition of relation $R$ into $R_1$ and $R_2$ is **Lossless** with respect to functional dependency set $F$ if and only if:
$$(R_1 \cap R_2) \rightarrow R_1 \quad \text{OR} \quad (R_1 \cap R_2) \rightarrow R_2$$

### Proof for Customer Decomposition:
Let $R = \{\text{customer\_id}, \text{company\_name}, \text{loc\_id}, \text{city}, \text{state}\}$.
Decomposed into:
$$R_1 = \text{CUSTOMER}(\underline{\text{customer\_id}}, \text{company\_name}, \text{loc\_id})$$
$$R_2 = \text{GEOGRAPHY\_LOCATION}(\underline{\text{loc\_id}}, \text{city}, \text{state})$$

1. $R_1 \cap R_2 = \{\text{loc\_id}\}$
2. In $R_2$, $\text{loc\_id}$ is the Primary Key.
3. Therefore, by definition of primary key, $\text{loc\_id} \rightarrow R_2$ (specifically $\text{loc\_id} \rightarrow \text{city}, \text{state}$).
4. Since $(R_1 \cap R_2) \rightarrow R_2$, the decomposition is **mathematically guaranteed to be Lossless**. Q.E.D.
