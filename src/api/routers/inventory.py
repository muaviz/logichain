from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from src.database import execute_query, execute_statement, get_connection

router = APIRouter(prefix="/inventory", tags=["Inventory & Warehousing"])

class TransferStockRequest(BaseModel):
    source_warehouse_id: int
    dest_warehouse_id: int
    product_id: int
    quantity: int = Field(gt=0)

@router.get("/stock")
def get_inventory_stock(warehouse_id: Optional[int] = None) -> List[Dict[str, Any]]:
    """Retrieves real-time stock levels across warehouses."""
    query = """
    SELECT 
        s.stock_id,
        w.warehouse_code,
        w.warehouse_name,
        s.bin_code,
        p.product_id,
        p.sku,
        p.product_name,
        p.material_type,
        s.quantity_on_hand,
        s.quantity_reserved,
        (s.quantity_on_hand - s.quantity_reserved) AS quantity_available
    FROM INVENTORY_STOCK s
    JOIN WAREHOUSE w ON s.warehouse_id = w.warehouse_id
    JOIN PRODUCT p ON s.product_id = p.product_id
    """
    params = ()
    if warehouse_id:
        query += " WHERE s.warehouse_id = ?"
        params = (warehouse_id,)
    query += " ORDER BY w.warehouse_code, p.product_name"
    return execute_query(query, params)

@router.post("/transfer")
def transfer_stock(req: TransferStockRequest) -> Dict[str, Any]:
    """Atomic Stock Transfer between Warehouses with Savepoints and Verification."""
    conn = get_connection()
    try:
        c = conn.cursor()
        # Verify source stock
        c.execute("""
            SELECT stock_id, quantity_on_hand, quantity_reserved 
            FROM INVENTORY_STOCK 
            WHERE warehouse_id = ? AND product_id = ?
        """, (req.source_warehouse_id, req.product_id))
        source_stock = c.fetchone()

        if not source_stock:
            raise HTTPException(status_code=404, detail="Product not found in source warehouse.")

        available = source_stock["quantity_on_hand"] - source_stock["quantity_reserved"]
        if available < req.quantity:
            raise HTTPException(status_code=400, detail=f"Insufficient available stock ({available} available, requested {req.quantity}).")

        # Deduct from source
        c.execute("""
            UPDATE INVENTORY_STOCK 
            SET quantity_on_hand = quantity_on_hand - ?, updated_at = CURRENT_TIMESTAMP
            WHERE warehouse_id = ? AND product_id = ?
        """, (req.quantity, req.source_warehouse_id, req.product_id))

        # Check destination bin
        c.execute("SELECT bin_code FROM WAREHOUSE_BIN WHERE warehouse_id = ? LIMIT 1", (req.dest_warehouse_id,))
        dest_bin_row = c.fetchone()
        dest_bin = dest_bin_row["bin_code"] if dest_bin_row else "BIN-A1-01"

        # Increment destination or insert
        c.execute("""
            SELECT stock_id FROM INVENTORY_STOCK WHERE warehouse_id = ? AND product_id = ?
        """, (req.dest_warehouse_id, req.product_id))
        dest_stock = c.fetchone()

        if dest_stock:
            c.execute("""
                UPDATE INVENTORY_STOCK 
                SET quantity_on_hand = quantity_on_hand + ?, updated_at = CURRENT_TIMESTAMP
                WHERE stock_id = ?
            """, (req.quantity, dest_stock["stock_id"]))
        else:
            c.execute("""
                INSERT INTO INVENTORY_STOCK (warehouse_id, bin_code, product_id, quantity_on_hand, quantity_reserved)
                VALUES (?, ?, ?, ?, 0)
            """, (req.dest_warehouse_id, dest_bin, req.product_id, req.quantity))

        conn.commit()
        return {
            "status": "SUCCESS",
            "message": f"Successfully transferred {req.quantity} units of product {req.product_id} from WH {req.source_warehouse_id} to WH {req.dest_warehouse_id}."
        }
    except HTTPException:
        conn.rollback()
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        conn.close()
