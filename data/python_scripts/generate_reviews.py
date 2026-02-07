import csv
import random
from datetime import timedelta, datetime

reviews = []
review_id = 1

POSITIVE_COMMENTS = [
    "Excellent experience",
    "Great food!",
    "Will order again",
    "Delivery was quick",
    "Loved the taste"
]

NEUTRAL_COMMENTS = [
    "Good taste",
    "Average experience",
    "Packaging could be better",
    None
]

NEGATIVE_COMMENTS = [
    "Food was cold",
    "Late delivery",
    "Not satisfied",
    "Poor packaging"
]


with open("delivered_orders_for_reviews.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Only ~50% delivered orders get reviews
        if random.random() > 0.5:
            continue

        rating = random.choices(
            population=[1, 2, 3, 4, 5],
            weights=[5, 10, 25, 35, 25]
        )[0]

        food_rating = rating if random.random() > 0.2 else None
        delivery_rating = rating if random.random() > 0.2 else None

        if rating >= 4:
            comment = random.choice(POSITIVE_COMMENTS)
        elif rating == 3:
            comment = random.choice(NEUTRAL_COMMENTS)
        else:
            comment = random.choice(NEGATIVE_COMMENTS)


        review_date = datetime.fromisoformat(row["created_at"]) + timedelta(
            hours=random.randint(1, 6)
        )

        reviews.append([
            review_id,
            int(row["customer_id"]),
            int(row["restaurant_id"]),
            int(row["order_id"]),
            rating,
            food_rating,
            delivery_rating,
            comment,
            review_date,
            review_date
        ])

        review_id += 1

# ----------------------------
# Write CSV
# ----------------------------
with open("reviews.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "review_id", "customer_id", "restaurant_id", "order_id",
        "rating", "food_quality_rating", "delivery_rating",
        "comment", "review_date", "updated_at"
    ])
    writer.writerows(reviews)

print("reviews.csv generated successfully")
