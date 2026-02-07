import csv
import random
from datetime import datetime, timedelta

# ----------------------------
# Configuration
# ----------------------------
DELIVERY_AGENT_IDS = list(range(1101, 1301))  # delivery_agent user_ids
CUSTOMER_IDS = list(range(1, 1001))

VEHICLES = ["motorcycle", "scooter", "bicycle", "car"]

CITIES = [
    ("Bangalore", "Karnataka"),
    ("Hyderabad", "Telangana"),
    ("Chennai", "Tamil Nadu"),
    ("Mumbai", "Maharashtra"),
    ("Delhi", "Delhi"),
    ("Pune", "Maharashtra")
]

START_DATE = datetime.now() - timedelta(days=540)

# ----------------------------
# Generate delivery_agents
# ----------------------------
agents = []

for idx, user_id in enumerate(DELIVERY_AGENT_IDS, start=1):
    created_at = START_DATE + timedelta(
            days=random.randint(0, 540),
            seconds=random.randint(0, 86400)
        )

    agents.append([
        idx,
        user_id,
        random.choice(VEHICLES),
        f"KA{random.randint(10,99)}AB{random.randint(1000,9999)}",
        round(random.uniform(3.0, 5.0), 2),
        0,
        True,
        created_at,
        created_at
    ])

# ----------------------------
# Generate customer_addresses
# ----------------------------
addresses = []
address_id = 1

for customer_id in CUSTOMER_IDS:
    num_addresses = random.choice([1, 2])
    city, state = random.choice(CITIES)

    for i in range(num_addresses):
        created_at = START_DATE + timedelta(
            days=random.randint(0, 540),
            seconds=random.randint(0, 86400)
        )

        addresses.append([
            address_id,
            customer_id,
            "home" if i == 0 else "other",
            f"{random.randint(1, 500)} Residential Street",
            city,
            state,
            f"{random.randint(560000, 569999)}",
            "India",
            i == 0,
            created_at
        ])
        address_id += 1

# ----------------------------
# Write delivery_agents.csv
# ----------------------------
with open("delivery_agents.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "agent_id", "user_id", "vehicle_type", "vehicle_number",
        "rating", "total_deliveries", "is_available",
        "created_at", "updated_at"
    ])
    writer.writerows(agents)

# ----------------------------
# Write customer_addresses.csv
# ----------------------------
with open("customer_addresses.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "address_id", "customer_id", "address_type", "street_address",
        "city", "state_province", "postal_code", "country",
        "is_default", "created_at"
    ])
    writer.writerows(addresses)

print("delivery_agents.csv and customer_addresses.csv generated")
