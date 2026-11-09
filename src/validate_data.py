
import sqlite3
from pathlib import Path

# Find project root
project_root = Path(__file__).resolve().parent.parent
db_path = project_root / "data" / "instamart.db"

conn = sqlite3.connect(db_path)

print("Database connected successfully!")

# 1. Check all three tables exist
tables = {
    row[0] for row in conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table'"
    )
}

assert {"customers", "products", "orders"}.issubset(tables)

# 2. Check customer count
assert conn.execute(
    "SELECT COUNT(*) FROM customers"
).fetchone()[0] == 1200

# 3. Check product count
assert conn.execute(
    "SELECT COUNT(*) FROM products"
).fetchone()[0] == 40

# 4. Check order count
assert conn.execute(
    "SELECT COUNT(*) FROM orders"
).fetchone()[0] == 12309

# 5. Check unique customer IDs
assert conn.execute("""
    SELECT COUNT(*) FROM (
        SELECT customer_id FROM customers
        GROUP BY customer_id HAVING COUNT(*) > 1
    )
""").fetchone()[0] == 0

# 6. Check unique product IDs
assert conn.execute("""
    SELECT COUNT(*) FROM (
        SELECT product_id FROM products
        GROUP BY product_id HAVING COUNT(*) > 1
    )
""").fetchone()[0] == 0

# 7. Check unique order IDs
assert conn.execute("""
    SELECT COUNT(*) FROM (
        SELECT order_id FROM orders
        GROUP BY order_id HAVING COUNT(*) > 1
    )
""").fetchone()[0] == 0

# 8. Check customer ages
assert conn.execute("""
    SELECT COUNT(*) FROM customers
    WHERE age IS NULL OR age < 10 OR age > 100
""").fetchone()[0] == 0

# 9. Check gender counts
gender_counts = dict(conn.execute("""
    SELECT gender, COUNT(*) FROM customers
    GROUP BY gender
""").fetchall())

assert gender_counts == {
    "female": 610,
    "male": 560,
    "unknown": 30
}

# 10. Check order statuses
status_counts = dict(conn.execute("""
    SELECT status, COUNT(*) FROM orders
    GROUP BY status
""").fetchall())

assert status_counts == {
    "completed": 11110,
    "cancelled": 1199
}

# 11. Check missing order amounts
assert conn.execute("""
    SELECT COUNT(*) FROM orders
    WHERE order_amount IS NULL
""").fetchone()[0] == 0

# 12. Check completed orders have delivery minutes
assert conn.execute("""
    SELECT COUNT(*) FROM orders
    WHERE status = 'completed'
    AND delivery_minutes IS NULL
""").fetchone()[0] == 0

# 13. Check cancelled orders have missing delivery minutes
assert conn.execute("""
    SELECT COUNT(*) FROM orders
    WHERE status = 'cancelled'
    AND delivery_minutes IS NULL
""").fetchone()[0] == 1199

# 14. Check completed revenue
revenue = conn.execute("""
    SELECT ROUND(SUM(order_amount), 2)
    FROM orders
    WHERE status = 'completed'
""").fetchone()[0]

assert revenue == 2998668.80, f"Revenue mismatch: {revenue}"

# 15. Check order timestamp storage
timestamp_type = conn.execute("""
    SELECT type FROM pragma_table_info('orders')
    WHERE name = 'order_ts'
""").fetchone()[0]

assert timestamp_type.upper() == "TEXT"

conn.close()

print("ALL CHECKPOINTS PASSED")
