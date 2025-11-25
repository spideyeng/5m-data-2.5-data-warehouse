# Liquor Sales dbt Walkthrough

This repo turns the public `bigquery-public-data.iowa_liquor_sales.sales` table into a tiny star-schema mart using dbt. The flow mirrors what you would build in a warehouse: capture source data, preserve history for important attributes, and shape analytics-friendly tables.

## Pipeline Overview

1. **Source registration** – `models/sources.yml` names the BigQuery table so every model can reference it with `source('iowa_liquor_sales', 'sales')`.
2. **Snapshots** – `snapshots/store_snapshot.sql` captures Type-2 history for store attributes so store changes are never lost.
3. **Models** – SQL files in `models/` and `models/star/` transform raw rows into fact/dimension tables.
4. **Testing** – `schema.yml` files define not-null/unique/relationship tests to keep data quality in check.
5. **Execution** – Running `dbt snapshot`, `dbt run`, and `dbt test` materializes the mart and validates it.

## Data Flow Details

| Stage | What happens | Files |
| --- | --- | --- |
| Source | Registers BigQuery public table | `models/sources.yml` |
| Fact | Copies core sales measures (invoice id, store/item ids, pricing, volumes) | `models/fact_sales.sql` |
| Dim: Item | Deduplicates attributes like `item_description`, `vendor_name`, etc. | `models/star/dim_item.sql` |
| Dim: Store | Selects the *current* record from the snapshot history | `models/star/dim_store.sql` |
| Snapshot | Builds SCD Type-2 log using `store_number` as unique key and `updated_at` timestamp strategy | `snapshots/store_snapshot.sql` |

## Snapshots & Slowly Changing Dimensions

`store_snapshot` is configured with `strategy='timestamp'`, so dbt compares the `updated_at` column to detect changes. Each time the store’s attributes differ, dbt writes a new row with `dbt_valid_from` and `dbt_valid_to` timestamps. `dim_store` filters to `dbt_valid_to IS NULL`, giving you the latest store record while still retaining history for audits or trend analysis.

## Testing & Config

- `models/schema.yml` enforces `fact_sales.invoice_and_item_number` uniqueness and ensures every `store_number` has a matching `dim_store` row.
- `models/star/schema.yml` asserts primary keys in each dimension are unique/not null.
- Project config (`dbt_project.yml`) materializes everything in the `star` schema and points dbt to the `liquor_sales` profile.

## Running the Project

1. Configure GCP auth, BigQuery, and `profiles.yml` as noted in `README.md`.
2. Activate the `elt` Conda env (or equivalent).
3. Run the typical dbt flow:
   ```bash
   dbt debug       # sanity check configuration
   dbt seed        # only if you add CSV seeds later
   dbt snapshot    # build/update store history
   dbt run         # materialize fact and dimension tables
   dbt test        # run uniqueness/relationship tests
   ```

The end product is a minimal but complete star schema (fact + dimensions) backed by proper lineage, historical tracking, and automated tests—exactly what you’d expect from a clean dbt analytics mart.

