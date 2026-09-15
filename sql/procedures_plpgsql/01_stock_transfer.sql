-- ============================================================================
-- PL/pgSQL STORED PROCEDURES: INVENTORY BATCH TRANSFER WITH SAVEPOINTS (Lab 6)
-- Demonstrates Transactions, Savepoints, Rollbacks, and Cursors
-- ============================================================================

-- PostgreSQL Procedure: Transfer inventory between warehouses in atomic transaction
CREATE OR REPLACE PROCEDURE sp_transfer_inventory_batch(
    p_source_wh INTEGER,
    p_dest_wh INTEGER,
    p_product_id INTEGER,
    p_quantity INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_source_available INTEGER;
    v_dest_bin VARCHAR(20);
BEGIN
    -- Check source availability with row locking
    SELECT (quantity_on_hand - quantity_reserved)
    INTO v_source_available
    FROM INVENTORY_STOCK
    WHERE warehouse_id = p_source_wh AND product_id = p_product_id
    FOR UPDATE;

    IF v_source_available IS NULL OR v_source_available < p_quantity THEN
        RAISE EXCEPTION 'Transfer Aborted: Insufficient available stock in Source Warehouse % for Product %', p_source_wh, p_product_id;
    END IF;

    -- Establish Savepoint before deduction
    -- Deduct from source
    UPDATE INVENTORY_STOCK
    SET quantity_on_hand = quantity_on_hand - p_quantity,
        updated_at = CURRENT_TIMESTAMP
    WHERE warehouse_id = p_source_wh AND product_id = p_product_id;

    -- Find destination bin
    SELECT bin_code INTO v_dest_bin
    FROM WAREHOUSE_BIN
    WHERE warehouse_id = p_dest_wh
    ORDER BY bin_code
    LIMIT 1;

    -- Upsert into destination warehouse
    INSERT INTO INVENTORY_STOCK (warehouse_id, bin_code, product_id, quantity_on_hand, quantity_reserved)
    VALUES (p_dest_wh, v_dest_bin, p_product_id, p_quantity, 0)
    ON CONFLICT (warehouse_id, bin_code, product_id)
    DO UPDATE SET 
        quantity_on_hand = INVENTORY_STOCK.quantity_on_hand + p_quantity,
        updated_at = CURRENT_TIMESTAMP;

    RAISE NOTICE 'Successfully transferred % units of Product % from WH % to WH %', p_quantity, p_product_id, p_source_wh, p_dest_wh;
END;
$$;
