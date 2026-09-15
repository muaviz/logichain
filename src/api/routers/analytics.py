from fastapi import APIRouter
from typing import List, Dict, Any
from src.database import execute_query

router = APIRouter(prefix="/analytics", tags=["Dimensional Data Mart & OLAP"])

@router.get("/sales-by-material")
def get_sales_by_material() -> List[Dict[str, Any]]:
    """Analyzes sales revenue, discounts, and profit margins by product material (Lab 3)."""
    query = """
    SELECT 
        dp.material_type,
        COUNT(f.fact_sales_id) AS total_orders,
        SUM(f.quantity_sold) AS total_quantity_sold,
        ROUND(SUM(f.gross_revenue), 2) AS gross_revenue,
        ROUND(SUM(f.discount_amount), 2) AS total_discounts,
        ROUND(SUM(f.net_revenue), 2) AS net_revenue,
        ROUND(AVG(f.profit_margin), 2) AS avg_profit_margin
    FROM FACT_SALES_SHIPMENT f
    JOIN DIM_PRODUCT_HIERARCHY dp ON f.dim_product_key = dp.dim_product_key
    GROUP BY dp.material_type
    ORDER BY net_revenue DESC;
    """
    return execute_query(query)

@router.get("/spatial-revenue")
def get_spatial_revenue() -> List[Dict[str, Any]]:
    """Analyzes revenue across spatial hierarchy (State -> Region -> City)."""
    query = """
    SELECT 
        dl.state,
        dl.region,
        dl.city,
        SUM(f.quantity_sold) AS total_quantity,
        ROUND(SUM(f.net_revenue), 2) AS total_revenue
    FROM FACT_SALES_SHIPMENT f
    JOIN DIM_CUSTOMER_LOCATION dl ON f.dim_location_key = dl.dim_location_key
    GROUP BY dl.state, dl.region, dl.city
    ORDER BY total_revenue DESC;
    """
    return execute_query(query)

@router.get("/warehouse-performance")
def get_warehouse_performance() -> List[Dict[str, Any]]:
    """Warehouse fulfillment speed and freight cost analytics."""
    query = """
    SELECT 
        dw.warehouse_code,
        dw.warehouse_name,
        dw.capacity_tier,
        COUNT(f.fact_sales_id) AS total_shipments_fulfilled,
        ROUND(AVG(f.delivery_lead_time_days), 1) AS avg_lead_time_days,
        ROUND(SUM(f.net_revenue), 2) AS total_revenue_dispatched
    FROM FACT_SALES_SHIPMENT f
    JOIN DIM_WAREHOUSE_HUB dw ON f.dim_warehouse_key = dw.dim_warehouse_key
    GROUP BY dw.warehouse_code, dw.warehouse_name, dw.capacity_tier
    ORDER BY total_revenue_dispatched DESC;
    """
    return execute_query(query)
