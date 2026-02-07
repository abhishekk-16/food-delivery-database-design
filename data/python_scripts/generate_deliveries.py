import csv
import random
from datetime import timedelta, datetime

# ----------------------------
# Load order data
# ----------------------------
orders = []

with open("order_delivery_map.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        orders.append({
            "order_id": int(row["order_id"]),
            "order_status": row["order_status"],
            "created_at": datetime.fromisoformat(row["created_at"])
        })

# ----------------------------
# Load delivery agents
# ----------------------------
agent_ids = []

with open("delivery_agents_map.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        agent_ids.append(int(row["agent_id"]))

# ----------------------------
# Generate deliveries
# ----------------------------
deliveries = []
delivery_id = 1

for order in orders:
    status = order["order_status"]

    if status not in ["delivered", "out_for_delivery", "cancelled"]:
        continue

    pickup_time = order["created_at"] + timedelta(minutes=random.randint(10, 25))
    estimated_delivery_time = pickup_time + timedelta(minutes=random.randint(20, 45))

    if status == "delivered":
        actual_delivery_time = estimated_delivery_time + timedelta(
            minutes=random.randint(-10, 20)
        )
        delivery_status = "delivered"
        agent_id = random.choice(agent_ids)
        rating = random.randint(3, 5)
        feedback = random.choice(
            ["On time", "Late but polite", "Excellent service", None]
        )

    elif status == "out_for_delivery":
        actual_delivery_time = None
        delivery_status = "in_transit"
        agent_id = random.choice(agent_ids)
        rating = None
        feedback = None

    else:  # cancelled
        actual_delivery_time = None
        delivery_status = "cancelled"
        agent_id = None
        rating = None
        feedback = None

    deliveries.append([
        delivery_id,
        order["order_id"],
        agent_id,
        pickup_time,
        estimated_delivery_time,
        actual_delivery_time,
        delivery_status,
        round(random.uniform(1.5, 12.0), 2),
        rating,
        feedback,
        pickup_time,
        pickup_time
    ])

    delivery_id += 1

# ----------------------------
# Write CSV
# ----------------------------
with open("deliveries.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "delivery_id", "order_id", "delivery_agent_id",
        "pickup_time", "estimated_delivery_time", "actual_delivery_time",
        "delivery_status", "distance_km",
        "delivery_rating", "delivery_feedback",
        "created_at", "updated_at"
    ])
    writer.writerows(deliveries)

print("deliveries.csv generated successfully")
