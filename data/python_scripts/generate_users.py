import csv
import random
from datetime import datetime, timedelta

# ----------------------------
# Configuration
# ----------------------------
TOTAL_USERS = 1300

USER_DISTRIBUTION = {
    "customer": 1000,
    "restaurant_owner": 100,
    "delivery_agent": 200
}

FIRST_NAMES = [
    "Amit", "Rahul", "Suresh", "Ravi", "Ankit", "Pooja", "Neha", "Priya",
    "Kiran", "Vikram", "Rohit", "Sneha", "Ayesha", "Nikhil", "Manish"
]

LAST_NAMES = [
    "Sharma", "Verma", "Singh", "Gupta", "Mehta", "Iyer",
    "Reddy", "Patel", "Khan", "Das", "Chatterjee"
]



# ----------------------------
# Helper functions
# ----------------------------
def random_date(start):
    return start + timedelta(days=random.randint(0, 540))

def generate_phone(index):
    return f"9{random.randint(100000000, 999999999)}"

# ----------------------------
# Generate users
# ----------------------------
users = []
user_id = 1

for user_type, count in USER_DISTRIBUTION.items():
    for _ in range(count):
        first = random.choice(FIRST_NAMES)
        last = random.choice(LAST_NAMES)
        
        START_DATE = datetime.now() - timedelta(days=540)  # ~18 months
        created_at = START_DATE + timedelta(
            days=random.randint(0, 540),
            seconds=random.randint(0, 86400)
        )
        updated_at = created_at + timedelta(days=random.randint(0, 90))

        rating = round(
            random.uniform(3.5, 5.0) if user_type == "customer"
            else random.uniform(3.0, 5.0),
            2
        )

        users.append([
            user_id,
            f"{first.lower()}.{last.lower()}{user_id}@example.com",
            f"hashed_pwd_{user_id}",
            generate_phone(user_id),
            first,
            last,
            user_type,
            rating,
            created_at,
            updated_at,
            True
        ])

        user_id += 1

# ----------------------------
# Write CSV
# ----------------------------
with open("users.csv", "w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow([
        "user_id", "email", "password_hash", "phone_number",
        "first_name", "last_name", "user_type", "rating",
        "created_at", "updated_at", "is_active"
    ])
    writer.writerows(users)

print("users.csv generated successfully")
