import csv
import random
from datetime import datetime, timedelta

# ----------------------------
# Configuration
# ----------------------------
RESTAURANT_IDS = list(range(1, 101))  # 100 restaurants

MENU_CATALOG = {
    "Starters": {
        "items": [
            "Paneer Tikka", "Chicken 65", "Veg Spring Rolls",
            "Crispy Corn", "Hara Bhara Kebab"
        ],
        "price": (80, 180),
        "prep_time": (15, 25)
    },
    "Main Course": {
        "items": [
            "Chicken Biryani", "Paneer Butter Masala",
            "Dal Tadka", "Veg Fried Rice",
            "Butter Chicken", "Masala Dosa"
        ],
        "price": (180, 350),
        "prep_time": (25, 40)
    },
    "Desserts": {
        "items": [
            "Gulab Jamun", "Chocolate Brownie",
            "Ice Cream Sundae", "Rasgulla"
        ],
        "price": (90, 220),
        "prep_time": (10, 20)
    },
    "Beverages": {
        "items": [
            "Masala Chai", "Cold Coffee",
            "Fresh Lime Soda", "Mango Shake"
        ],
        "price": (60, 150),
        "prep_time": (5, 10)
    }
}


START_DATE = datetime.now() - timedelta(days=540)

# ----------------------------
# Generate menu items
# ----------------------------
menu_items = []
menu_item_id = 1

for restaurant_id in RESTAURANT_IDS:
    num_items = random.randint(4, 8)

    for _ in range(num_items):
        category = random.choice(list(MENU_CATALOG.keys()))
        catalog = MENU_CATALOG[category]

        item_name = random.choice(catalog["items"])
        price = round(random.uniform(*catalog["price"]), 2)
        prep_time = random.randint(*catalog["prep_time"])

        created_at = START_DATE + timedelta(
            days=random.randint(0, 540),
            seconds=random.randint(0, 86400)
        )
        updated_at = created_at + timedelta(days=random.randint(0, 30))

        menu_items.append([
            menu_item_id,
            restaurant_id,
            item_name,
            f"Delicious {item_name.lower()} prepared fresh",
            category,
            price,
            random.choice([True] * 9 + [False]),
            prep_time,
            f"https://img.foodapp.com/item{menu_item_id}.jpg",
            created_at,
            updated_at
        ])

        menu_item_id += 1



        menu_item_id += 1

# ----------------------------
# Write CSV
# ----------------------------
with open("menu_items.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "menu_item_id", "restaurant_id", "item_name", "description",
        "category", "price", "is_available", "preparation_time",
        "image_url", "created_at", "updated_at"
    ])
    writer.writerows(menu_items)

print("menu_items.csv generated successfully")
