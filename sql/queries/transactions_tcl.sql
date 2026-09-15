-- ============================================================================
-- TRANSACTION CONTROL LANGUAGE (TCL) SCRIPTS
-- Maps to CSE3001 Unit 3 & Unit 5 (COMMIT, ROLLBACK, SAVEPOINT, ACID Atomicity)
-- ============================================================================

-- Scenario: Creating a New Sales Order with Automatic Inventory Deduction and Savepoint Protection

BEGIN TRANSACTION;

-- Step 1: Insert New Order
INSERT INTO CUSTOMER_ORDER (
    order_id, order_number, customer_id, order_date, required_date, status, subtotal, discount_pct, tax_amount, total_amount
) VALUES (
    899, 'ORD-TX-DEMO-99', 701, '2026-09-15', '2026-09-25', 'PROCESSING', 499.98, 0.00, 40.00, 539.98
);

-- Establish Savepoint after Order Header Creation
SAVEPOINT svp_order_created;

-- Step 2: Insert Line Item
INSERT INTO ORDER_ITEM (order_id, item_seq, product_id, ordered_qty, unit_price, discount_rate, line_total)
VALUES (899, 1, 301, 2, 249.99, 0.00, 499.98);

-- Step 3: Establish Savepoint before stock deduction
SAVEPOINT svp_before_stock_deduct;

-- Deduct stock from warehouse 401
UPDATE INVENTORY_STOCK
SET quantity_on_hand = quantity_on_hand - 2
WHERE warehouse_id = 401 AND product_id = 301 AND quantity_on_hand >= 2;

-- Checkpoint: If something went wrong, we can do:
-- ROLLBACK TO svp_before_stock_deduct;

-- Commit the entire atomic unit
COMMIT;
