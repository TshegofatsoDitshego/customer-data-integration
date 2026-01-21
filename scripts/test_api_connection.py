"""
Test API connection and data retrieval
This simulates connecting to an external API source
"""

import requests
import json
from datetime import datetime

def test_jsonplaceholder_api():
    """
    Test with JSONPlaceholder (free fake API)
    This simulates getting customer data from an external system
    """
    
    print("Testing API connection...\n")
    
    try:
        # Test endpoint
        url = "https://jsonplaceholder.typicode.com/users"
        
        print(f"Calling: {url}")
        response = requests.get(url, timeout=10)
        
        # Check response
        if response.status_code == 200:
            print(f"✓ Status: {response.status_code} OK")
            
            data = response.json()
            print(f"✓ Retrieved {len(data)} records\n")
            
            # Show sample record
            print("Sample record:")
            print(json.dumps(data[0], indent=2))
            
            # Transform to customer format
            print("\n" + "="*50)
            print("Transformed to customer format:")
            print("="*50)
            
            for user in data[:3]:  # Show first 3
                customer = {
                    'customer_id': user['id'],
                    'first_name': user['name'].split()[0],
                    'last_name': user['name'].split()[-1],
                    'email': user['email'],
                    'phone': user['phone'],
                    'country': user['address']['city']  # Using city as country for demo
                }
                print(json.dumps(customer, indent=2))
                print("-" * 50)
            
            return True
            
        else:
            print(f"✗ Error: Status {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"✗ Connection error: {e}")
        return False


def test_odds_api():
    """
    Test with The Odds API (relevant for betting platform)
    You'll need a free API key from: https://the-odds-api.com/
    """
    
    API_KEY = "YOUR_API_KEY_HERE"  # Get free key from the-odds-api.com
    
    if API_KEY == "YOUR_API_KEY_HERE":
        print("\n⚠ Skipping Odds API test - no API key configured")
        print("Get a free key from: https://the-odds-api.com/")
        return False
    
    print("\nTesting Odds API connection...\n")
    
    try:
        url = f"https://api.the-odds-api.com/v4/sports/?apiKey={API_KEY}"
        
        print(f"Calling: {url}")
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            print(f"✓ Status: {response.status_code} OK")
            
            data = response.json()
            print(f"✓ Retrieved {len(data)} sports\n")
            
            # Show available sports
            print("Available sports:")
            for sport in data[:5]:
                print(f"  - {sport['title']} ({sport['key']})")
            
            return True
            
        else:
            print(f"✗ Error: Status {response.status_code}")
            print(response.text)
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"✗ Connection error: {e}")
        return False


if __name__ == "__main__":
    print("="*50)
    print("API Connection Tests")
    print("="*50)
    print()
    
    # Test 1: JSONPlaceholder (always works, no key needed)
    test_jsonplaceholder_api()
    
    # Test 2: The Odds API (optional, needs API key)
    test_odds_api()
    
    print("\n" + "="*50)
    print("Tests complete!")
    print("="*50)