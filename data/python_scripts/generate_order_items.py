import csv
import random
from collections import defaultdict

# ----------------------------
# Load order -> restaurant
# ----------------------------
order_restaurant = {}

with open("order_restaurant_map.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        order_restaurant[int(row["order_id"])] = int(row["restaurant_id"])

# ----------------------------
# Load menu items per restaurant
# ----------------------------
menu_by_restaurant = defaultdict(list)

with open("menu_items_map.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        menu_by_restaurant[int(row["restaurant_id"])].append({
            "menu_item_id": int(row["menu_item_id"]),
            "price": float(row["price"])
        })

# ----------------------------
# Generate order_items
# ----------------------------
order_items = []
order_item_id = 1

for order_id, restaurant_id in order_restaurant.items():
    menu_items = menu_by_restaurant[restaurant_id]

    if not menu_items:
        continue

    num_items = random.randint(1, min(5, len(menu_items)))
    selected_items = random.sample(menu_items, num_items)

    for item in selected_items:
        quantity = random.randint(1, 3)

        order_items.append([
            order_item_id,
            order_id,
            item["menu_item_id"],
            quantity,
            item["price"],
            None
        ])

        order_item_id += 1

# ----------------------------
# Write CSV
# ----------------------------
with open("order_items.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "order_item_id", "order_id", "menu_item_id",
        "quantity", "item_price", "special_instructions"
    ])
    writer.writerows(order_items)

print("order_items.csv generated successfully")
