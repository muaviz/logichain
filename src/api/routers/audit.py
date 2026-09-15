from fastapi import APIRouter
from typing import List, Dict, Any
from src.database import execute_query

router = APIRouter(prefix="/audit", tags=["Transparent Audit Trails"])

@router.get("/clients")
def get_client_audit_trail() -> List[Dict[str, Any]]:
    """Retrieves transparent client modification/deletion audit history (Lab 5)."""
    query = """
    SELECT 
        audit_id,
        customer_id,
        company_name,
        old_balance_due,
        new_balance_due,
        operation,
        db_user,
        changed_at
    FROM AUDIT_CLIENT_LOG
    ORDER BY audit_id DESC
    """
    return execute_query(query)

@router.get("/inventory")
def get_inventory_audit_trail() -> List[Dict[str, Any]]:
    """Retrieves stock modification audit history."""
    query = """
    SELECT 
        audit_id,
        stock_id,
        warehouse_id,
        product_id,
        old_qty_on_hand,
        new_qty_on_hand,
        operation,
        db_user,
        changed_at
    FROM AUDIT_INVENTORY_LOG
    ORDER BY audit_id DESC
    """
    return execute_query(query)
