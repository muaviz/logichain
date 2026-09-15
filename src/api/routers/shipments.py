from fastapi import APIRouter, HTTPException
from typing import List, Dict, Any, Optional
from src.database import execute_query, execute_statement

router = APIRouter(prefix="/shipments", tags=["Fleet & Dispatch"])

@router.get("/")
def get_all_shipments(status: Optional[str] = None) -> List[Dict[str, Any]]:
    """Retrieves all shipments with origin, driver, vehicle, and delivery info."""
    query = """
    SELECT 
        s.shipment_id,
        s.shipment_code,
        s.order_id,
        w.warehouse_name AS origin_hub,
        v.license_plate AS vehicle_plate,
        vt.type_name AS vehicle_type,
        e.first_name || ' ' || e.last_name AS driver_name,
        COALESCE(i.first_name || ' ' || i.last_name, 'None') AS inspector_name,
        s.dispatch_date,
        s.delivery_date,
        s.status,
        s.freight_cost
    FROM SHIPMENT s
    JOIN WAREHOUSE w ON s.origin_warehouse_id = w.warehouse_id
    JOIN VEHICLE v ON s.vehicle_id = v.vehicle_id
    JOIN VEHICLE_TYPE vt ON v.type_code = vt.type_code
    JOIN EMPLOYEE e ON s.driver_id = e.emp_id
    LEFT JOIN EMPLOYEE i ON s.inspector_id = i.emp_id
    """
    params = ()
    if status:
        query += " WHERE s.status = ?"
        params = (status,)
    query += " ORDER BY s.shipment_id DESC"
    return execute_query(query, params)

@router.get("/{shipment_id}/items")
def get_shipment_items(shipment_id: int) -> List[Dict[str, Any]]:
    """Retrieves weak entity line items for a specific shipment."""
    query = """
    SELECT 
        si.shipment_id,
        si.item_seq,
        p.product_id,
        p.sku,
        p.product_name,
        si.quantity_shipped,
        si.unit_price,
        (si.quantity_shipped * si.unit_price) AS item_total_value
    FROM SHIPMENT_ITEM si
    JOIN PRODUCT p ON si.product_id = p.product_id
    WHERE si.shipment_id = ?
    ORDER BY si.item_seq
    """
    return execute_query(query, (shipment_id,))
