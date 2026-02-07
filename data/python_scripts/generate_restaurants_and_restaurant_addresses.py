import csv
import random
from datetime import datetime, timedelta

# ----------------------------
# Configuration
# ----------------------------
TOTAL_RESTAURANTS = 100

CITIES = [
    ("Bangalore", "Karnataka"),
    ("Hyderabad", "Telangana"),
    ("Chennai", "Tamil Nadu"),
    ("Mumbai", "Maharashtra"),
    ("Delhi", "Delhi"),
    ("Pune", "Maharashtra")
]

CUISINES = [
    "North Indian", "South Indian", "Chinese",
    "Italian", "Fast Food", "Biryani", "Desserts"
]

START_DATE = datetime.now() - timedelta(days=540)

# ----------------------------
# Fetch restaurant owners IDs
# ----------------------------
# Export this from PostgreSQL beforehand:
# SELECT user_id FROM users WHERE user_type = 'restaurant_owner';

OWNER_IDS = list(range(1001, 1101))  # adjust if needed

# ----------------------------
# Generate restaurants
# ----------------------------
restaurants = []
addresses = []

for i in range(1, TOTAL_RESTAURANTS + 1):
    owner_id = random.choice(OWNER_IDS)
    city, state = random.choice(CITIES)
    created_at = START_DATE + timedelta(
            days=random.randint(0, 540),
            seconds=random.randint(0, 86400)
        )

    cuisine = random.choice(CUISINES)

    restaurants.append([
        i,
        owner_id,
        f"Restaurant {i}",
        f"Popular {cuisine} restaurant",
        cuisine,
        f"98{random.randint(10000000, 99999999)}",
        f"restaurant{i}@foodapp.com",
        round(random.uniform(3.5, 5.0), 2),
        0,
        True,
        created_at,
        created_at
    ])

    addresses.append([
        i,
        i,
        f"{random.randint(10, 500)} Main Street",
        city,
        state,
        f"{random.randint(560000, 569999)}",
        "India",
        True,
        created_at
    ])

# ----------------------------
# Write restaurants.csv
# ----------------------------
with open("restaurants.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "restaurant_id", "owner_id", "restaurant_name", "description",
        "cuisine_type", "phone_number", "email", "rating",
        "total_orders", "is_operational", "created_at", "updated_at"
    ])
    writer.writerows(restaurants)

# ----------------------------
# Write restaurant_addresses.csv
# ----------------------------
with open("restaurant_addresses.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "address_id", "restaurant_id", "street_address", "city",
        "state_province", "postal_code", "country",
        "is_primary", "created_at"
    ])
    writer.writerows(addresses)

print("restaurants.csv and restaurant_addresses.csv generated")
