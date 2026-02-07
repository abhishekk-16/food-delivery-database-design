import csv
import random
from datetime import datetime, timedelta
from collections import defaultdict

# ----------------------------
# Configuration
# ----------------------------
TOTAL_ORDERS = 10000
CUSTOMER_IDS = list(range(1, 1001))
RESTAURANT_IDS = list(range(1, 101))
START_DATE = datetime.now() - timedelta(days=540)

ORDER_STATUSES = (
    ["delivered"] * 75 +
    ["cancelled"] * 10 +
    ["confirmed"] * 5 +
    ["preparing"] * 5 +
    ["ready"] * 3 +
    ["out_for_delivery"] * 2
)

NOW = datetime.now()
RECENT_CUTOFF = NOW - timedelta(days=2)

# ----------------------------
# Load customer-address mapping
# ----------------------------
customer_addresses = defaultdict(list)

with open("customer_address_map.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        customer_addresses[int(row["customer_id"])].append(
            int(row["address_id"])
        )

# ----------------------------
# Helper
# ----------------------------
def random_date():
    return START_DATE + timedelta(
        days=random.randint(0, 540),
        seconds=random.randint(0, 86400)
    )

# ----------------------------
# Generate orders
# ----------------------------
orders = []

for order_id in range(1, TOTAL_ORDERS + 1):
    customer_id = random.choice(CUSTOMER_IDS)

    # pick only valid address for that customer
    address_id = random.choice(customer_addresses[customer_id])

    restaurant_id = random.choice(RESTAURANT_IDS)
    order_date = random_date()

    requested_delivery_time = order_date + timedelta(
        minutes=random.randint(30, 90)
    )

    total_amount = round(random.uniform(200, 800), 2)
    discount_amount = random.choice([0, 0, 0, 50, 100])
    tax_amount = round(total_amount * 0.05, 2)
    delivery_fee = 50.00

    if order_date >= RECENT_CUTOFF:
    # Recent orders can be in-progress
        order_status = random.choice(ORDER_STATUSES)
    else:
    # Old orders must be final
        order_status = random.choice(
            ["delivered"] * 85 + ["cancelled"] * 15
         )


    if order_status == "delivered":
        payment_status = "paid"
    elif order_status == "cancelled":
        payment_status = random.choice(["failed", "refunded"])
    else:
        payment_status = "pending"

    created_at = order_date
    updated_at = created_at + timedelta(
        minutes=random.randint(10, 120)
    )

    orders.append([
        order_id,
        customer_id,
        restaurant_id,
        address_id,
        order_date,
        requested_delivery_time,
        total_amount,
        discount_amount,
        delivery_fee,
        tax_amount,
        order_status,
        payment_status,
        None,
        created_at,
        updated_at
    ])

# ----------------------------
# Write CSV
# ----------------------------
with open("orders.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "order_id", "customer_id", "restaurant_id", "delivery_address_id",
        "order_date", "requested_delivery_time", "total_amount",
        "discount_amount", "delivery_fee", "tax_amount",
        "order_status", "payment_status", "special_instructions",
        "created_at", "updated_at"
    ])
    writer.writerows(orders)

print("orders.csv generated successfully")
