# Retention Recommendation: Bank Customer Churn

**Prepared by:** Nisha Bharadwaj | **Data:** 10,000 customer records (Kaggle Bank Customer Churn)

## Problem
20.4% of customers churned (2,037 of 10,000). Those customers held $185.6M of the $764.9M in total balances (24%). Churn is concentrated, so a targeted program can reach most of it without contacting everyone.

## Findings
1. **Age 40-59 is the largest at-risk group.** Churn is 30.8% at 40-49 and 56.0% at 50-59, against 8-11% for under-40s. It falls back to 27.9% at 60+.
2. **Germany churns at 32.4% against about 16% in France and Spain.** It is 25% of customers but 40% of churners (814). Even Germany's *active* customers (23.7%) churn more than *inactive* customers in France (21.1%) and Spain (23.3%), so activity does not explain the gap.
3. **Product count is a warning sign in both directions.** 2-product customers churn at 7.6%, the healthiest group. Customers with 3-4 products churn at 82.7% and 100% (280 of 326). One-product customers churn at 27.7% and, at 1,409 churners, are 69% of all churn.
4. **Secondary signals:** inactive customers churn at 26.9% vs 14.3% active; women 25.1% vs men 16.5%; customers with a balance 24.1% vs 13.8% with none.

## Recommendation
**Phase 1 (contact the High tier).** Rule: 3+ products, OR age 45-64 who are inactive or in Germany. This is 1,480 customers (14.8% of the base) with 65.7% churn, and it captures 47.7% of all churners. The Low tier (34.8% of customers) churns at 4.7% and needs no outreach.
- Owner: Retention/CRM team, with a relationship-manager call for the highest balances.
- Offer: a service check-in and a product or fee review, not a blanket discount. Validate the offer by segment in the pilot.

**Phase 2 (fix the causes, not just the symptoms).**
- Review how 3-4 product bundles are sold. Churn this high suggests a sales or product-fit problem, so check onboarding and fees before offering incentives.
- Ask the Germany market owner what differs in pricing, service or competition, and run a customer survey there.
- Test whether a second product retains single-product customers, using a pilot (see below).

## How to Measure It
- **Pilot:** randomly split the High tier, contact one half and hold out the other half. Compare churn at 90 and 180 days.
- **Success metrics:** churn rate versus holdout, balance retained, and contact cost per retained customer.
- **Cost check:** at an assumed $25 per contact, reaching all 1,480 High-tier customers costs about $37,000. Replace this with the bank's real cost. The High tier's average balance is about $90,000, so retaining even a small share outweighs the contact cost (balances are not revenue, so convert to margin before presenting a final ROI).

## Limits and Next Steps
- The data is a single snapshot: no dates, no churn reasons, no product or pricing detail. Findings show correlation, not cause.
- Next: add churn reasons and dates, test a simple logistic regression to check these drivers hold up together, and rerun the tiering on fresh data.
