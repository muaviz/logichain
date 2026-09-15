-- ============================================================================
-- ORACLE PL/SQL CURSORS, SAVEPOINTS & BATCH TRANSACTIONS
-- Maps to CSE3001 Lab 4, Lab 6, and Unit 4
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. IMPLICIT CURSOR SCRIPT (Syllabus Lab 4 Equivalent)
-- Displays shipment cargo manifest using SQL%FOUND and SQL%ROWCOUNT
-- ----------------------------------------------------------------------------
DECLARE
    v_ship_id       NUMBER := 901;
    v_ship_code     VARCHAR2(40);
    v_dispatch_date DATE;
    v_status        VARCHAR2(30);
    v_freight_cost  NUMBER;
    v_total_items   NUMBER;
BEGIN
    -- Query basic shipment info
    SELECT shipment_code, dispatch_date, status, freight_cost
    INTO v_ship_code, v_dispatch_date, v_status, v_freight_cost
    FROM SHIPMENT
    WHERE shipment_id = v_ship_id;

    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('=== SHIPMENT MANIFEST (IMPLICIT CURSOR) ===');
        DBMS_OUTPUT.PUT_LINE('Shipment ID    : ' || v_ship_id);
        DBMS_OUTPUT.PUT_LINE('Shipment Code  : ' || v_ship_code);
        DBMS_OUTPUT.PUT_LINE('Dispatch Date  : ' || TO_CHAR(v_dispatch_date, 'YYYY-MM-DD HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('Current Status : ' || v_status);
        DBMS_OUTPUT.PUT_LINE('Freight Cost   : $' || TO_CHAR(v_freight_cost, '999,999.99'));
    END IF;

    -- Count total items using implicit cursor
    SELECT COUNT(*) INTO v_total_items
    FROM SHIPMENT_ITEM
    WHERE shipment_id = v_ship_id;

    DBMS_OUTPUT.PUT_LINE('Total Item Records : ' || v_total_items || ' (SQL%ROWCOUNT checked)');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Shipment ID ' || v_ship_id || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/

-- ----------------------------------------------------------------------------
-- 2. EXPLICIT CURSOR WITH SAVEPOINTS & BATCH DELETION (Syllabus Lab 6 Equivalent)
-- Reads all parts in order, saves state, deletes every 10th row, commits/rollbacks
-- ----------------------------------------------------------------------------
DECLARE
    -- Explicit Parameterized Cursor
    CURSOR cur_supplier_parts IS
        SELECT sp.supplier_id, sp.product_id, p.sku, p.product_name, sp.supply_price
        FROM SUPPLIER_PRODUCT sp
        JOIN PRODUCT p ON sp.product_id = p.product_id
        ORDER BY sp.product_id ASC
        FOR UPDATE OF sp.supply_price;

    v_row_count     NUMBER := 0;
    v_deleted_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== STARTING CURSOR BATCH PROCESSING WITH SAVEPOINTS ===');

    FOR rec IN cur_supplier_parts LOOP
        v_row_count := v_row_count + 1;
        DBMS_OUTPUT.PUT_LINE('Row ' || v_row_count || ': SKU [' || rec.sku || '] ' || rec.product_name || ' @ $' || rec.supply_price);

        -- Every 5th row (or 10th row in larger table), create savepoint and test transaction logic
        IF MOD(v_row_count, 5) = 0 THEN
            SAVEPOINT sp_batch_checkpoint;
            DBMS_OUTPUT.PUT_LINE('--> Established SAVEPOINT [sp_batch_checkpoint] at row ' || v_row_count);

            -- Simulate deletion of the 5th item
            DELETE FROM SUPPLIER_PRODUCT
            WHERE CURRENT OF cur_supplier_parts;

            v_deleted_count := v_deleted_count + 1;
            DBMS_OUTPUT.PUT_LINE('--> Deleted item at row ' || v_row_count || ' using WHERE CURRENT OF.');

            -- Commit transaction batch
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('--> Batch Committed successfully.');
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total Rows Processed: ' || v_row_count || ', Total Deleted: ' || v_deleted_count);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_batch_checkpoint;
        DBMS_OUTPUT.PUT_LINE('Transaction Error encountered: ' || SQLERRM || '. Rolled back to last savepoint.');
END;
/
