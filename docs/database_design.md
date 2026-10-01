# Database Design & Architecture Specification

## 1. Three-Level ANSI-SPARC Architecture

LogiChain implements the standard 3-Level ANSI-SPARC Database Architecture:

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
|  CUSTOMER, ORDER, SHIPMENT, PRODUCT, WAREHOUSE, EMPLOYEE, INVENTORY     |
+-------------------------------------------------------------------------+
                                    ▲
                                    │ (Conceptual / Internal Mapping)
                                    ▼
+-------------------------------------------------------------------------+
|                        INTERNAL LEVEL (Physical Storage)                |
|  B+ Tree Indexes, Page Layouts, WAL Logs, Row Storage Blocks           |
+-------------------------------------------------------------------------+
```

### 1.1 External Level (Views)
- **Logistics Driver View** (`VW_DRIVER_PUBLIC_PROFILE`): Restricts access to driver certifications, route assignments, and hides sensitive employee salaries and commission structures.
- **Warehouse Manager View** (`VW_WAREHOUSE_INVENTORY_METRICS`): Exposes stock availability, reserved units, and bin allocations while abstracting financial margins.
- **Auditor View** (`AUDIT_CLIENT_LOG` & `AUDIT_INVENTORY_LOG`): Provides immutable history of every update/delete operation with prior values and user attribution.

### 1.2 Conceptual Level (Logical Schema)
- 20 normalized relational entities defined with primary keys, foreign key referential integrity (`ON DELETE CASCADE`, `ON DELETE RESTRICT`, `ON DELETE SET NULL`), and strict domain `CHECK` constraints.

### 1.3 Internal Level (Physical Storage)
- Composite B+ Tree indexes (`idx_orders_customer_date`, `idx_inventory_wh_prod`, `idx_shipment_driver_status`), sequential heap files, and Write-Ahead Logging (WAL) for durability.

---

## 2. Data Independence

### 2.1 Logical Data Independence
- The capacity to modify the conceptual schema (e.g., adding columns to `PRODUCT` or partitioning `CUSTOMER_ORDER`) without requiring changes to external views or application code.
- Demonstrated via view encapsulation (`VW_ACTIVE_PRODUCTS`, `VW_ACTIVE_CUSTOMERS`) and stored procedure interfaces.

### 2.2 Physical Data Independence
- The capacity to modify physical storage structures (e.g., creating secondary B+ Tree indexes, altering table layouts) without modifying the conceptual schema or rewriting SQL queries.

---

## 3. Entity-Relationship (ER) Model Specification

### 3.1 Strong Entity Sets
- **`GEOGRAPHY_LOCATION`**: Normalizes spatial hierarchy (`city`, `region`, `state`, `country`, `postal_code`).
- **`EMPLOYEE`**: Staff members with recursive boss/subordinate hierarchy (`manager_id` references `EMPLOYEE.emp_id`).
- **`SUPPLIER`**: Component and raw material vendors with star rating and tax IDs.
- **`PRODUCT_CATEGORY`**: Hierarchical product taxonomy with self-referencing parent categories.
- **`PRODUCT`**: Items and parts catalog with physical attributes (`material_type`, `unit_weight_kg`, `base_price`).
- **`WAREHOUSE`**: Physical distribution hubs with square footage capacity and assigned facility manager.
- **`VEHICLE_TYPE`**: Fleet specifications (`max_payload_kg`, `cruising_range_km`, special licensing flag).
- **`VEHICLE`**: Fleet assets tracked by VIN, license plate, maintenance dates, and warehouse depot.
- **`CUSTOMER`**: Client master records with credit limit and balance due attributes.
- **`CUSTOMER_ORDER`**: Sales orders with timestamped lifecycle status and financial totals.
- **`SHIPMENT`**: Cargo dispatches with assigned vehicle, driver, and quality inspector.

### 3.2 Weak Entity Sets (Identifying Relationships)
1. **`WAREHOUSE_BIN`**:
   - *Identifying Owner*: `WAREHOUSE`
   - *Partial Key / Discriminator*: `bin_code`
   - *Primary Key*: `(warehouse_id, bin_code)`
   - *Semantics*: A storage bin cannot exist without its containing physical warehouse facility.
2. **`SHIPMENT_ITEM`**:
   - *Identifying Owner*: `SHIPMENT`
   - *Partial Key / Discriminator*: `item_seq`
   - *Primary Key*: `(shipment_id, item_seq)`
   - *Semantics*: A manifested shipment line item has no independent identity outside its cargo dispatch.
3. **`EMPLOYEE_DEPENDENT`**:
   - *Identifying Owner*: `EMPLOYEE`
   - *Partial Key / Discriminator*: `dependent_name`
   - *Primary Key*: `(emp_id, dependent_name)`
   - *Semantics*: Insurance dependents exist only in association with an employed staff member.

### 3.3 Extended ER Features (EER)
- **Specialization & Generalization**:
  - `EMPLOYEE` is specialized into disjoint roles: `Driver` (requires commercial certifications), `Warehouse Staff`, `Quality Inspector`, and `Executive Manager`.
  - `VEHICLE_TYPE` categorizes vehicles into `SEMI_HEAVY`, `MEDIUM_VAN`, `REEFER_TRUCK`, `ELECTRIC_VAN`, and `BOEING_AIR_747`.
- **Associative Entities ($M:N$ Relationships)**:
  - `SUPPLIER_PRODUCT`: Associates multiple suppliers with multiple products, capturing supplier-specific pricing and lead times.
  - `DRIVER_CERTIFICATION`: Associates drivers with vehicle types they are certified to operate.
