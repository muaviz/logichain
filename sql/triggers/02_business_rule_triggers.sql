-- ============================================================================
-- BUSINESS INTEGRITY & USER-DEFINED ERROR TRIGGERS (CSE3001 Lab 10)
-- Raises user-defined error messages to block unauthorized or invalid DML
-- ============================================================================

-- Trigger 1: Prevent Discontinued Product Orders with Custom Error
DROP TRIGGER IF EXISTS trg_prevent_discontinued_order;
CREATE TRIGGER trg_prevent_discontinued_order
BEFORE INSERT ON ORDER_ITEM
FOR EACH ROW
WHEN (SELECT is_discontinued FROM PRODUCT WHERE product_id = NEW.product_id) = 1
BEGIN
    SELECT RAISE(ABORT, 'ERR-30010: Business Rule Violation - Cannot add discontinued product to order.');
END;

-- Trigger 2: Prevent Credit Limit Exceeded on Customer Orders
DROP TRIGGER IF EXISTS trg_prevent_credit_limit_breach;
CREATE TRIGGER trg_prevent_credit_limit_breach
BEFORE UPDATE OF balance_due ON CUSTOMER
FOR EACH ROW
WHEN NEW.balance_due > NEW.credit_limit
BEGIN
    SELECT RAISE(ABORT, 'ERR-30011: Credit Limit Exceeded - Customer balance cannot exceed approved credit limit.');
END;

-- Trigger 3: Prevent Extreme Price Reductions (> 75% Drop in single update)
DROP TRIGGER IF EXISTS trg_prevent_predatory_price_drop;
CREATE TRIGGER trg_prevent_predatory_price_drop
BEFORE UPDATE OF base_price ON PRODUCT
FOR EACH ROW
WHEN NEW.base_price < (OLD.base_price * 0.25)
BEGIN
    SELECT RAISE(ABORT, 'ERR-30012: Audit Lock - Base price reduction cannot exceed 75% without executive authorization.');
END;
