# QR Code Examples for Smart-Check

## How It Works

When you scan a QR code in Smart-Check, it automatically:
1. ✅ Reads the item name
2. ✅ Sets the expiry date
3. ✅ Sets the quantity
4. ✅ **Automatically selects the correct category** (beverages, dairy, etc.)

## QR Code Format

Use this JSON format for your QR codes:

```json
{
  "name": "Item Name",
  "expiryDate": "YYYY-MM-DD",
  "qty": "number",
  "category": "category_name"
}
```

## Example QR Codes

### Beverages
```json
{
  "name": "Coca Cola",
  "expiryDate": "2025-12-31",
  "qty": "2",
  "category": "beverages"
}
```

### Dairy
```json
{
  "name": "Amul Milk",
  "expiryDate": "2025-12-10",
  "qty": "1",
  "category": "dairy"
}
```

### Fruits
```json
{
  "name": "Apples",
  "expiryDate": "2025-12-05",
  "qty": "5",
  "category": "fruits"
}
```

### Vegetables
```json
{
  "name": "Carrots",
  "expiryDate": "2025-12-08",
  "qty": "1",
  "category": "vegetables"
}
```

### Meat
```json
{
  "name": "Chicken Breast",
  "expiryDate": "2025-12-03",
  "qty": "500g",
  "category": "meat"
}
```

## Generating QR Codes

### Method 1: Use the Built-in Generator (Easiest)
1. Open `tools/generate-qr.html` in your browser
2. Fill in the form (category dropdown included!)
3. Click "Generate QR Code"
4. Download and print

### Method 2: Online QR Generators
1. Go to any QR code generator (qr-code-generator.com, qrcode-monkey.com, etc.)
2. Select "Text" type
3. Paste your JSON (use examples above)
4. Generate and download

### Method 3: Programmatically
```javascript
const qrData = {
  name: "Orange Juice",
  expiryDate: "2025-12-15",
  qty: "1",
  category: "beverages"
}

// Use any QR library to generate
const qrString = JSON.stringify(qrData)
```

## Supported Categories

- `beverages` - Drinks, juices, sodas
- `dairy` - Milk, cheese, yogurt
- `vegetables` - Fresh vegetables
- `fruits` - Fresh fruits
- `meat` - Meat, poultry, fish
- `other` - Everything else

## Tips

1. **Print QR codes on labels** - Stick them on containers
2. **Laminate for durability** - Especially for refrigerator items
3. **Use consistent date format** - Always YYYY-MM-DD
4. **Test before printing** - Scan with your phone first
5. **Keep a backup** - Save your QR code images

## Editing Items

Don't worry if you need to change something after scanning! Each item card now has an **Edit button (✏️)** where you can:
- Change the name
- Update expiry date
- Adjust quantity
- **Change the category manually**

## Troubleshooting

**QR code not scanning?**
- Make sure it's valid JSON format
- Check for typos in field names (name, expiryDate, qty, category)
- Ensure date is in YYYY-MM-DD format
- Try generating a new QR code

**Category not showing correctly?**
- Check spelling: must be exactly `beverages`, `dairy`, `vegetables`, `fruits`, `meat`, or `other`
- Use the edit button to manually fix it after scanning
