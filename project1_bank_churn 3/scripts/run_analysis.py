"""Runs every query in sql/churn_analysis.sql against data/Churn_Modelling.csv,
saves each result to sql/Qn_output.csv, and builds the charts.
Usage (from the repo root): python scripts/run_analysis.py
The raw Kaggle file is renamed to snake_case in data/ (customer_id, num_products, is_active, churned ...)."""
import re, sqlite3
from pathlib import Path
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent
df = pd.read_csv(ROOT / "data" / "Churn_Modelling.csv")
con = sqlite3.connect(":memory:")
df.to_sql("customers", con, index=False)

sql = (ROOT / "sql" / "churn_analysis.sql").read_text()
blocks = re.split(r"^-- (Q\d+):[^\n]*\n", sql, flags=re.M)
results = {}
for label, body in zip(blocks[1::2], blocks[2::2]):
    query = "\n".join(l for l in body.splitlines() if not l.startswith("--")).strip().rstrip(";")
    results[label] = pd.read_sql_query(query, con)
    results[label].to_csv(ROOT / "sql" / f"{label}_output.csv", index=False)
    print(f"\n=== {label} ===\n{results[label].to_string(index=False)}")

BLUE, RED, GOLD = "#4472C4", "#C0504D", "#F2B134"
plt.rcParams.update({"font.size": 10})

q = results["Q2"]
fig, ax = plt.subplots(figsize=(6, 4))
ax.bar(q["num_products"].astype(str), q["churn_rate_pct"], color=BLUE)
for i, r in q.iterrows():
    ax.text(i, r["churn_rate_pct"] + 1, f'{r["churn_rate_pct"]}%\n(n={r["customers"]})', ha="center", fontsize=8)
ax.set_ylim(0, 120); ax.set_title("Churn Rate by Number of Products"); ax.set_xlabel("Products held"); ax.set_ylabel("Churn rate (%)")
plt.tight_layout(); plt.savefig(ROOT / "charts" / "churn_by_products.png", dpi=150); plt.close()

q = results["Q4"]
fig, ax = plt.subplots(figsize=(6, 4))
ax.bar(q["age_band"], q["churn_rate_pct"], color=BLUE)
for i, r in q.iterrows():
    ax.text(i, r["churn_rate_pct"] + 1, f'{r["churn_rate_pct"]}%', ha="center", fontsize=8)
ax.set_title("Churn Rate by Age Band"); ax.set_xlabel("Age band"); ax.set_ylabel("Churn rate (%)")
plt.tight_layout(); plt.savefig(ROOT / "charts" / "churn_by_age_band.png", dpi=150); plt.close()

q = results["Q6"].pivot(index="geography", columns="activity_status", values="churn_rate_pct")
fig, ax = plt.subplots(figsize=(6, 4))
q.plot(kind="bar", ax=ax, color=[BLUE, RED], rot=0)
ax.set_title("Churn Rate by Geography and Activity Status"); ax.set_xlabel(""); ax.set_ylabel("Churn rate (%)"); ax.legend(title="")
plt.tight_layout(); plt.savefig(ROOT / "charts" / "churn_by_geography_activity.png", dpi=150); plt.close()

q = results["Q8"]
colors = {"High": RED, "Medium": GOLD, "Low": BLUE}
fig, axes = plt.subplots(1, 2, figsize=(9, 4))
axes[0].bar(q["churn_risk_tier"], q["actual_churn_rate_pct"], color=[colors[t] for t in q["churn_risk_tier"]])
axes[0].set_title("Actual churn rate by tier"); axes[0].set_ylabel("%")
axes[1].bar(q["churn_risk_tier"], q["share_of_all_churners_pct"], color=[colors[t] for t in q["churn_risk_tier"]])
axes[1].set_title("Share of all churners captured"); axes[1].set_ylabel("%")
plt.tight_layout(); plt.savefig(ROOT / "charts" / "churn_by_risk_tier.png", dpi=150); plt.close()
print("\nCharts saved.")
