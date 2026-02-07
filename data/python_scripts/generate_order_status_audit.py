import csv
import random
from datetime import timedelta, datetime

STATUS_FLOW = [
    "pending", "confirmed", "preparing",
    "ready", "out_for_delivery", "delivered"
]

audit_logs = []
log_id = 1

with open("orders_for_audit.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        order_id = int(row["order_id"])
        final_status = row["order_status"]
        start_time = datetime.fromisoformat(row["created_at"])

        possible_flow = STATUS_FLOW.copy()

        if final_status == "cancelled":
            possible_flow = ["pending", "confirmed", "cancelled"]

        transitions = random.randint(3, min(6, len(possible_flow)))
        chosen_flow = possible_flow[:transitions]

        current_time = start_time

        for i in range(1, len(chosen_flow)):
            old_status = chosen_flow[i - 1]
            new_status = chosen_flow[i]

            current_time += timedelta(minutes=random.randint(5, 30))

            audit_logs.append([
                log_id,
                order_id,
                old_status,
                new_status,
                current_time
            ])

            log_id += 1

# ----------------------------
# Write CSV
# ----------------------------
with open("order_status_audit_log.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "log_id", "order_id", "old_status",
        "new_status", "changed_at"
    ])
    writer.writerows(audit_logs)

print("order_status_audit_log.csv generated successfully")
