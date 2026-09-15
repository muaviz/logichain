-- ============================================================================
-- INVENTORY AUTO-SYNC & RESERVATION TRIGGERS
-- Maintains real-time consistency between Order Items and Stock Reservations
-- ============================================================================

-- Automatically increase reserved quantity when an order item is created
DROP TRIGGER IF EXISTS trg_reserve_stock_on_order;
CREATE TRIGGER trg_reserve_stock_on_order
AFTER INSERT ON ORDER_ITEM
FOR EACH ROW
BEGIN
    UPDATE INVENTORY_STOCK
    SET quantity_reserved = quantity_reserved + NEW.ordered_qty,
        updated_at = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id
      AND stock_id = (
          SELECT stock_id 
          FROM INVENTORY_STOCK 
          WHERE product_id = NEW.product_id 
            AND (quantity_on_hand - quantity_reserved) >= NEW.ordered_qty
          LIMIT 1
      );
END;
