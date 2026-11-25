"""Generate reproducible PostgreSQL demo INSERT statements. Run after 5 manual rows/table."""
from pathlib import Path
from datetime import date, datetime, timedelta
import random

R = random.Random(20261119)
OUT = Path(__file__).with_name('generated_inserts_PostgreSQL.sql')

def sql(v):
    if v is None: return 'NULL'
    if isinstance(v, bool): return 'TRUE' if v else 'FALSE'
    if isinstance(v, (date, datetime)): return "'" + str(v) + "'"
    if isinstance(v, str): return "'" + v.replace("'", "''") + "'"
    return str(v)

def write(f, table, cols, rows):
    rows = list(rows)
    for i in range(0, len(rows), 200):
        part = rows[i:i+200]
        f.write(f'INSERT INTO {table} ({", ".join(cols)}) VALUES\n')
        f.write(',\n'.join('(' + ', '.join(map(sql, row)) + ')' for row in part))
        f.write(' ON CONFLICT DO NOTHING;\n\n')
    return len(rows)

def generate():
    # IDs 1-5 are already present from the manual insertion.
    pairs = {(i, i) for i in range(1, 6)}
    sp = {}
    for sid in range(6, 2001):
        while True:
            pair = (R.randint(6, 500), R.randint(6, 1000))
            if pair not in pairs:
                pairs.add(pair)
                sp[sid] = pair
                break
    by_store = {i: [] for i in range(1, 501)}
    for sid, (store, _) in sp.items():
        by_store[store].append(sid)
    stores = [s for s, ids in by_store.items() if ids]
    sales, items = [], []
    for sale_id in range(6, 20001):
        store = R.choice(stores)
        dt = datetime(2026, 1, 1) + timedelta(days=R.randint(0, 300), minutes=R.randint(0, 1439))
        sales.append((sale_id, dt, R.choice(['Cash','Credit Card','Debit Card']), 'Completed', R.randint(1000,9999), R.randint(1,2000), store))
        count = 3 if sale_id <= 10 else 2
        for line in range(1, count + 1):
            items.append((line, sale_id, R.randint(1,4), round(R.uniform(10,200),2), R.choice(by_store[store])))
    assert len(sales) == 19995 and len(items) == 39995
    with OUT.open('w', encoding='utf-8') as f:
        f.write('-- PostgreSQL demo data, Python-generated. Run after the 5 manual rows in every table.\n')
        f.write('-- New IDs start at 6. Safe to rerun: existing keys are skipped.\n')
        f.write('-- Execute in pgAdmin Query Tool connected to AirportCommercialDB.\nBEGIN;\n\n')
        totals = {}
        totals['ProductCategories'] = write(f,'ProductCategories',['Category_ID','CategoryName','Description'],((i,f'Category {i}',f'Airport products {i}') for i in range(6,501)))
        totals['Stores'] = write(f,'Stores',['Store_ID','StoreName','StoreType','Terminal','Gate_Id_FK','Opening_Date','Is_Active'],((i,f'Store {i}','Duty Free',f'T{R.randint(1,5)}',R.randint(1,100),date(2020,1,1),True) for i in range(6,501)))
        totals['Products'] = write(f,'Products',['Product_Id','Product_Name','BarCode','Unit_Cost','IsActive','Category_ID'],((i,f'Product {i}',str(700000000000+i),round(R.uniform(5,100),2),True,R.randint(1,500)) for i in range(6,1001)))
        totals['Customers'] = write(f,'Customers',['Customer_ID','IdentityNumber','FirstName','LastName','CustomerType','Email'],((i,None,f'First{i}',f'Last{i}',R.choice(['Passenger','Pilot','Flight Attendant']),f'customer{i}@example.com') for i in range(6,2001)))
        totals['StoreProducts'] = write(f,'StoreProducts',['StoreProduct_ID','SellingPrice','StockQuantity','ReorderLevel','LastRestockDate','Store_ID','Product_Id'],((sid,round(R.uniform(10,200),2),R.randint(20,300),10,date(2026,6,1),*sp[sid]) for sid in range(6,2001)))
        totals['Sales'] = write(f,'Sales',['Sale_ID','SaleDateTime','PaymentMethod','SaleStatus','Flight_ID_FK','Customer_ID','Store_ID'],sales)
        totals['SaleItems'] = write(f,'SaleItems',['LineNumber','Sale_ID','Quantity','UnitPriceAtSale','StoreProduct_ID'],items)
        f.write('COMMIT;\n\n')
        f.write('SELECT \'ProductCategories\' AS table_name, COUNT(*) AS total FROM ProductCategories\n')
        for t in ['Stores','Products','Customers','StoreProducts','Sales','SaleItems']:
            f.write(f"UNION ALL SELECT '{t}', COUNT(*) FROM {t}\n")
        f.write(';\n')
    print('Created:', OUT, 'new rows:', totals)

if __name__ == '__main__': generate()
