-- ============================================================================
-- PL/pgSQL BUSINESS INTEGRITY: MUTUAL EXCLUSIVITY VALIDATION (Lab 7)
-- Verifies that the same employee cannot act as both Transporter/Driver and
-- Quality Inspector on the same cargo dispatch, raising a custom exception.
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_validate_shipment_staff_exclusivity(
    p_shipment_id INTEGER,
    p_driver_id INTEGER,
    p_inspector_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if driver and inspector are the same person
    IF p_driver_id = p_inspector_id THEN
        RAISE EXCEPTION 'ERR-30013: Separation of Duties Violation. Employee % cannot serve as both Transport Driver and Quality Inspector for Shipment %.', p_driver_id, p_shipment_id;
    END IF;

    -- Update shipment assignment if valid
    UPDATE SHIPMENT
    SET driver_id = p_driver_id,
        inspector_id = p_inspector_id
    WHERE shipment_id = p_shipment_id;
END;
$$;
