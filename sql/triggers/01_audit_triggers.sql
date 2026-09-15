-- ============================================================================
-- TRANSPARENT AUDIT TRIGGERS (CSE3001 Lab 5 & Unit 3)
-- Automatically records before/after state on Update or Delete in AUDIT_CLIENT_LOG
-- ============================================================================

-- SQLite & PostgreSQL Compatible Trigger Implementation for Customer Audit

-- 1. Trigger on Customer Update (Captures old vs new balance due)
DROP TRIGGER IF EXISTS trg_audit_customer_update;
CREATE TRIGGER trg_audit_customer_update
AFTER UPDATE ON CUSTOMER
FOR EACH ROW
BEGIN
    INSERT INTO AUDIT_CLIENT_LOG (
        customer_id,
        company_name,
        old_balance_due,
        new_balance_due,
        operation,
        db_user,
        changed_at
    ) VALUES (
        OLD.customer_id,
        OLD.company_name,
        OLD.balance_due,
        NEW.balance_due,
        'UPDATE',
        'APP_TRIGGER_AUDITOR',
        CURRENT_TIMESTAMP
    );
END;

-- 2. Trigger on Customer Delete (Captures prior state before removal)
DROP TRIGGER IF EXISTS trg_audit_customer_delete;
CREATE TRIGGER trg_audit_customer_delete
AFTER DELETE ON CUSTOMER
FOR EACH ROW
BEGIN
    INSERT INTO AUDIT_CLIENT_LOG (
        customer_id,
        company_name,
        old_balance_due,
        new_balance_due,
        operation,
        db_user,
        changed_at
    ) VALUES (
        OLD.customer_id,
        OLD.company_name,
        OLD.balance_due,
        NULL,
        'DELETE',
        'APP_TRIGGER_AUDITOR',
        CURRENT_TIMESTAMP
    );
END;

-- 3. Trigger on Inventory Stock Update (Captures stock movement)
DROP TRIGGER IF EXISTS trg_audit_inventory_update;
CREATE TRIGGER trg_audit_inventory_update
AFTER UPDATE OF quantity_on_hand ON INVENTORY_STOCK
FOR EACH ROW
BEGIN
    INSERT INTO AUDIT_INVENTORY_LOG (
        stock_id,
        warehouse_id,
        product_id,
        old_qty_on_hand,
        new_qty_on_hand,
        operation,
        db_user,
        changed_at
    ) VALUES (
        OLD.stock_id,
        OLD.warehouse_id,
        OLD.product_id,
        OLD.quantity_on_hand,
        NEW.quantity_on_hand,
        'UPDATE',
        'STOCK_AUTO_SYNC',
        CURRENT_TIMESTAMP
    );
END;
