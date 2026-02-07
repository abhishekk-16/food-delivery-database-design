import csv
import random
from datetime import timedelta

PAYMENT_METHODS = ["credit_card", "debit_card", "wallet", "upi", "cash"]

payments = []
payment_id = 1

with open("order_payment_map.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        order_id = int(row["order_id"])
        order_status = row["order_status"]
        payment_status = row["payment_status"]
        amount = float(row["final_amount"])
        created_at = row["created_at"]

        if payment_status == "paid":
            final_payment_status = "completed"
        elif payment_status in ["failed", "refunded"]:
            final_payment_status = payment_status
        else:
            final_payment_status = random.choice(["pending", "processing"])

        payments.append([
            payment_id,
            order_id,
            random.choice(PAYMENT_METHODS),
            amount,
            f"TXN{order_id}{random.randint(1000,9999)}",
            final_payment_status,
            created_at,
            created_at,
            created_at
        ])

        payment_id += 1

# ----------------------------
# Write CSV
# ----------------------------
with open("payments.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "payment_id", "order_id", "payment_method",
        "payment_amount", "transaction_id",
        "payment_status", "payment_date",
        "created_at", "updated_at"
    ])
    writer.writerows(payments)

print("payments.csv generated successfully")
