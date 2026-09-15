# Relational Algebra & Tuple Relational Calculus (TRC) Specification

This document details the formal mathematical operators of Relational Algebra and Tuple Relational Calculus implemented across the LogiChain database queries.
Maps directly to **CSE3001 Unit 2**.

---

## 1. Fundamental Relational Algebra Operators

### 1.1 Selection ($\sigma$)
Filters tuples satisfying a boolean predicate:
$$\sigma_{\text{salary} > 70000 \land \text{job\_role} = \text{'Driver'}}(\text{EMPLOYEE})$$
**SQL Equivalent:**
```sql
SELECT * FROM EMPLOYEE WHERE salary > 70000 AND job_role = 'Driver';
```

### 1.2 Projection ($\pi$)
Extracts specified attribute columns while eliminating duplicates:
$$\pi_{\text{first\_name}, \text{last\_name}, \text{salary}}(\text{EMPLOYEE})$$
**SQL Equivalent:**
```sql
SELECT DISTINCT first_name, last_name, salary FROM EMPLOYEE;
```

### 1.3 Cartesian Product ($\times$)
Computes cross-product of two relations:
$$\text{PRODUCT} \times \text{SUPPLIER}$$
**SQL Equivalent:**
```sql
SELECT * FROM PRODUCT CROSS JOIN SUPPLIER;
```

### 1.4 Natural Join ($\bowtie$) & Theta Join ($\bowtie_{\theta}$)
Combines tuples matching common attribute values or condition $\theta$:
$$\text{CUSTOMER} \bowtie_{\text{CUSTOMER.loc\_id} = \text{GEOGRAPHY\_LOCATION.loc\_id}} \text{GEOGRAPHY\_LOCATION}$$
**SQL Equivalent:**
```sql
SELECT * FROM CUSTOMER c JOIN GEOGRAPHY_LOCATION g ON c.loc_id = g.loc_id;
```

### 1.5 Set Operations ($\cup, \cap, -$)
- **Union ($\cup$)**: $\pi_{\text{city}}(\text{WAREHOUSE} \bowtie \text{GEOGRAPHY\_LOCATION}) \cup \pi_{\text{city}}(\text{CUSTOMER} \bowtie \text{GEOGRAPHY\_LOCATION})$
- **Intersection ($\cap$)**: $\pi_{\text{city}}(\text{WAREHOUSE} \bowtie \text{GEOGRAPHY\_LOCATION}) \cap \pi_{\text{city}}(\text{CUSTOMER} \bowtie \text{GEOGRAPHY\_LOCATION})$
- **Set Difference ($-$)**: $\pi_{\text{city}}(\text{SUPPLIER} \bowtie \text{GEOGRAPHY\_LOCATION}) - \pi_{\text{city}}(\text{WAREHOUSE} \bowtie \text{GEOGRAPHY\_LOCATION})$

### 1.6 Renaming ($\rho$)
Renames relations and attributes for unambiguous self-joins:
$$\rho_{\text{Emp}}(\text{EMPLOYEE}) \bowtie_{\text{Emp.manager\_id} = \text{Mgr.emp\_id}} \rho_{\text{Mgr}}(\text{EMPLOYEE})$$

---

## 2. Advanced Operators: Relational Division ($\div$)

Relational Division ($\div$) finds entities in Relation $R(A, B)$ that are associated with **ALL** values in Relation $S(B)$.

### Lab 1 Division Scenario:
Find vehicle types certified by **every** senior driver earning $> \$70,000$.

Let:
$$R = \pi_{\text{type\_code}, \text{emp\_id}}(\text{DRIVER\_CERTIFICATION})$$
$$S = \pi_{\text{emp\_id}}(\sigma_{\text{salary} > 70000 \land \text{job\_role} = \text{'Driver'}}(\text{EMPLOYEE}))$$

Then:
$$\text{Result} = R \div S = \pi_{\text{type\_code}}(R) - \pi_{\text{type\_code}}((\pi_{\text{type\_code}}(R) \times S) - R)$$

**SQL Formulation with Double `NOT EXISTS`:**
```sql
SELECT vt.type_code, vt.type_name
FROM VEHICLE_TYPE vt
WHERE NOT EXISTS (
    SELECT e.emp_id
    FROM EMPLOYEE e
    WHERE e.salary > 70000 AND e.job_role LIKE '%Driver%'
      AND NOT EXISTS (
          SELECT 1
          FROM DRIVER_CERTIFICATION dc
          WHERE dc.emp_id = e.emp_id AND dc.type_code = vt.type_code
      )
);
```

---

## 3. Tuple Relational Calculus (TRC) Formulations

Tuple Relational Calculus specifies queries declaratively as:
$$\{ t \mid P(t) \}$$

### 3.1 TRC Query 1: Pilots Certified for Boeing Aircraft
$$\{ t \mid \exists e \in \text{EMPLOYEE}, \exists dc \in \text{DRIVER\_CERTIFICATION}, \exists vt \in \text{VEHICLE\_TYPE} \\
(e.\text{emp\_id} = dc.\text{emp\_id} \land dc.\text{type\_code} = vt.\text{type\_code} \land vt.\text{type\_name} = \text{'Boeing 747-8F Heavy Air Freighter'} \land t[\text{pilot\_name}] = e.\text{first\_name} \circ \text{' '} \circ e.\text{last\_name}) \}$$

### 3.2 TRC Query 2: All Drivers Earning More Than Driver Rajesh
$$\{ t \mid \exists e \in \text{EMPLOYEE} \, (e.\text{job\_role} = \text{'Driver'} \land \exists r \in \text{EMPLOYEE} \, (r.\text{first\_name} = \text{'Rajesh'} \land e.\text{salary} > r.\text{salary}) \land t[\text{driver\_name}] = e.\text{first\_name} \circ \text{' '} \circ e.\text{last\_name}) \}$$
