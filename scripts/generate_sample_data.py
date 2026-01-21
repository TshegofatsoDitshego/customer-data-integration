"""
Generate sample customer and transaction data for testing
Run this to create larger datasets for performance testing
"""

import csv
import random
from datetime import datetime, timedelta
from faker import Faker

fake = Faker(['en_ZA'])  # South African locale

def generate_customers(num_records=1000):
    """Generate sample customer data with intentional quality issues"""
    
    customers = []
    
    # Email domains to use
    domains = ['email.com', 'company.co.za', 'gmail.com', 'yahoo.com', 'outlook.com']
    
    # Phone formats (to simulate inconsistency)
    phone_formats = [
        lambda n: f"+27 {n[:2]} {n[2:5]} {n[5:9]}",  # +27 82 555 0101
        lambda n: f"0{n[2:]}",  # 0825550101
        lambda n: f"+27-{n[:2]}-{n[2:5]}-{n[5:9]}",  # +27-82-555-0101
    ]
    
    # Date formats (to simulate inconsistency)
    date_formats = [
        lambda d: d.strftime('%Y-%m-%d'),  # ISO format
        lambda d: d.strftime('%d/%m/%Y'),  # DD/MM/YYYY
        lambda d: d.strftime('%m/%d/%Y'),  # MM/DD/YYYY (US format)
    ]
    
    for i in range(num_records):
        customer_id = 2000 + i
        first_name = fake.first_name()
        last_name = fake.last_name()
        
        # Create email (sometimes with typos)
        email = f"{first_name.lower()}.{last_name.lower()}@{random.choice(domains)}"
        
        # Randomly introduce data quality issues
        quality_issue = random.random()
        
        if quality_issue < 0.02:  # 2% missing email
            email = ""
        elif quality_issue < 0.03:  # 1% missing phone
            phone = ""
        else:
            # Generate phone with random format
            phone_num = str(random.randint(800000000, 899999999))
            phone = random.choice(phone_formats)(phone_num)
        
        # Generate signup date
        signup_date = fake.date_between(start_date='-2y', end_date='today')
        
        # Apply random date format
        if quality_issue < 0.95:  # 95% normal dates
            formatted_date = random.choice(date_formats)(signup_date)
        else:  # 5% invalid dates
            formatted_date = "Invalid-Date"
        
        # Country (mostly South Africa, some variations)
        if random.random() < 0.9:
            country = random.choice(['South Africa', 'ZA', 'RSA'])
        else:
            country = random.choice(['Namibia', 'Botswana', 'Zimbabwe'])
        
        customers.append({
            'customer_id': customer_id,
            'first_name': first_name,
            'last_name': last_name,
            'email': email,
            'phone': phone,
            'signup_date': formatted_date,
            'country': country
        })
    
    # Add some intentional duplicates (3% duplication rate)
    num_duplicates = int(num_records * 0.03)
    for _ in range(num_duplicates):
        duplicate = random.choice(customers).copy()
        duplicate['customer_id'] = 3000 + random.randint(0, 9999)
        duplicate['signup_date'] = random.choice(date_formats)(
            fake.date_between(start_date='-1y', end_date='today')
        )
        customers.append(duplicate)
    
    return customers


def generate_transactions(num_records=5000):
    """Generate sample transaction data"""
    
    transactions = []
    
    # Product categories for betting platform
    categories = ['Sports Betting', 'Casino', 'Live Casino', 'Virtual Sports', 'Poker']
    statuses = ['Completed', 'Completed', 'Completed', 'Pending', 'Refunded']  # Weighted
    
    # Load customer emails (you'd need to have generated customers first)
    customer_emails = [
        'james.smith@email.com',
        'sarah.j@email.com',
        'm.williams@company.co.za',
        'david.jones@email.com',
        'lisa.garcia@email.com'
    ]
    
    for i in range(num_records):
        transaction = {
            'transaction_id': f"TXN-{5000 + i}",
            'customer_email': random.choice(customer_emails),
            'product_category': random.choice(categories),
            'amount': round(random.uniform(10, 5000), 2),
            'transaction_date': fake.date_between(start_date='-1y', end_date='today'),
            'status': random.choice(statuses)
        }
        transactions.append(transaction)
    
    return transactions


def save_to_csv(data, filename):
    """Save data to CSV file"""
    if not data:
        print(f"No data to save for {filename}")
        return
    
    keys = data[0].keys()
    
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=keys)
        writer.writeheader()
        writer.writerows(data)
    
    print(f"✓ Generated {len(data)} records in {filename}")


if __name__ == "__main__":
    print("Generating sample data...\n")
    
    # Generate customers
    customers = generate_customers(num_records=1000)
    save_to_csv(customers, '../data/sample-data/customers_large.csv')
    
    # Generate transactions
    transactions = generate_transactions(num_records=5000)
    save_to_csv(transactions, '../data/sample-data/transactions_large.csv')
    
    print("\n✓ Sample data generation complete!")
    print("\nData quality issues intentionally included:")
    print("  - ~2% missing emails")
    print("  - ~1% missing phones")
    print("  - ~5% invalid dates")
    print("  - ~3% duplicate customers")
    print("  - Multiple phone/date formats")
    print("  - Mixed country name formats")