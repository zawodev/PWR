import pandas as pd
from sqlalchemy import create_engine, text
import sqlite3

# Database connection (example: SQLite; replace with your DB)
engine = create_engine('sqlite:///olist_dw.db', echo=False)

# Paths to source CSVs
CSV_PATHS = {
    'orders': 'olist_orders_dataset.csv',
    'order_items': 'olist_order_items_dataset.csv',
    'payments': 'olist_order_payments_dataset.csv',
    'reviews': 'olist_order_reviews_dataset.csv',
    'customers': 'olist_customers_dataset.csv',
    'sellers': 'olist_sellers_dataset.csv',
    'products': 'olist_products_dataset.csv',
    'categories': 'product_category_name_translation.csv',
    'cities': 'brazilian_cities.csv'
}

def load_stage():
    """Load CSVs into staging tables."""
    for name, path in CSV_PATHS.items():
        df = pd.read_csv(path)
        df.to_sql(f'stg_{name}', engine, if_exists='replace', index=False)
        print(f"Loaded {name} into staging.")

def clean_transform():
    """Clean and enrich staging data."""
    # Example: normalize timestamps and compute delivery_time
    orders = pd.read_sql('SELECT * FROM stg_orders', engine, parse_dates=['order_purchase_timestamp', 'order_delivered_customer_date'])
    orders['delivery_time_days'] = (orders['order_delivered_customer_date'] - orders['order_purchase_timestamp']).dt.days
    orders.to_sql('stg_orders_clean', engine, if_exists='replace', index=False)
    print("Cleaned orders and calculated delivery_time.")

    # Normalize city names and enrich with demographic data
    cities = pd.read_sql('SELECT * FROM stg_cities', engine)
    customers = pd.read_sql('SELECT * FROM stg_customers', engine)
    customers = customers.merge(cities, left_on=['customer_city', 'customer_state'], right_on=['city', 'state'], how='left')
    customers.to_sql('stg_customers_clean', engine, if_exists='replace', index=False)
    print("Enriched customers with city demographics.")

def load_dimensions():
    """Upsert dimension tables."""
    # TimeDim
    orders = pd.read_sql('SELECT DISTINCT order_purchase_timestamp FROM stg_orders_clean', engine, parse_dates=['order_purchase_timestamp'])
    times = orders.copy()
    times['time_key'] = times['order_purchase_timestamp'].dt.strftime('%Y%m%d%H%M%S').astype(int)
    times['year'] = times['order_purchase_timestamp'].dt.year
    times['quarter'] = times['order_purchase_timestamp'].dt.quarter
    times['month'] = times['order_purchase_timestamp'].dt.month
    times['day'] = times['order_purchase_timestamp'].dt.day
    times['weekday'] = times['order_purchase_timestamp'].dt.weekday + 1
    times['hour'] = times['order_purchase_timestamp'].dt.hour
    times['minute'] = times['order_purchase_timestamp'].dt.minute
    times['second'] = times['order_purchase_timestamp'].dt.second
    times = times.drop_duplicates('time_key')
    times.to_sql('TimeDim', engine, if_exists='replace', index=False)
    print("Loaded TimeDim.")

    # Month and Weekday dims - assume static, skip

    # CustomerDim
    customers = pd.read_sql('SELECT * FROM stg_customers_clean', engine)
    cust_dim = customers[['customer_id', 'customer_state', 'customer_city', 'population', 'area_km2', 'density_per_km2', 'gdp']].drop_duplicates('customer_id')
    cust_dim.to_sql('CustomerDim', engine, if_exists='replace', index=False)
    print("Loaded CustomerDim.")

def load_facts():
    """Load fact table."""
    orders = pd.read_sql('SELECT * FROM stg_orders_clean', engine)
    items = pd.read_sql('SELECT * FROM stg_order_items', engine)
    payments = pd.read_sql('SELECT * FROM stg_payments', engine)
    reviews = pd.read_sql('SELECT order_id, review_id, review_score FROM stg_reviews', engine)

    # Example join to construct fact
    fact = orders.merge(items, on='order_id') \
        .merge(payments, on='order_id') \
        .merge(reviews, on='order_id', how='left')
    fact['time_key'] = fact['order_purchase_timestamp'].dt.strftime('%Y%m%d%H%M%S').astype(int)
    fact = fact[['order_id', 'time_key', 'customer_id', 'seller_id', 'product_id', 'payment_sequential',
                 'review_id', 'quantity', 'price', 'delivery_time_days', 'review_score']]
    fact.to_sql('FactOrders', engine, if_exists='replace', index=False)
    print("Loaded FactOrders.")

def run_etl():
    load_stage()
    clean_transform()
    load_dimensions()
    load_facts()
    print("ETL process completed.")

if __name__ == "__main__":
    run_etl()
