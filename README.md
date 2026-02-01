<img width="1182" height="121" alt="sss" src="https://github.com/user-attachments/assets/a27cd3fe-8eac-445f-a221-fcc577602071" />

# Misr Hydraulics Management System (مؤسسة مصر للهيدروليك)

A comprehensive, dual-role **Point of Sale (POS)** and **Inventory Management System** built with **Flutter**.  
Designed specifically for **Misr Hydraulics**, this application streamlines operations across multiple branches—covering stock management, sales with custom fabrication costs, and detailed financial analytics.

---

## 🌟 Key Features

### 🔐 Authentication & Roles
- **Secure Login:** Dedicated login interfaces for **Administrators** and **Sellers**
- **Role-Based Access Control**
  - **Admins:** Full control over inventory, branches, financial analytics, and expenses
  - **Sellers:** POS-focused interface for sales and stock queries

---

### 🛒 Point of Sale (POS) & Sales
- **Smart Search:** Search products by **Name**, **ID**, or **Category**
- **Cart System**
  - Real-time stock validation
  - Manual quantity input for bulk sales
  - Mandatory client name for each transaction
- **Fabrication Costs (المصنعية):**  
  Add custom workmanship fees separately from product prices
- **Dynamic Totals:** Automatic calculation of final bill (products + fabrication)

---

### 📦 Inventory & Product Management
- **Detailed Product Data**
  - Name, Category, Description
  - Buy Price (MRU), Sell Price (MRU)
  - Quantity
- **CRUD Operations**
  - Add products with category selection
  - Inline editing for price, stock, and description
  - Secure product deletion
- **Category Management**
  - Organize products into custom categories

---

### 🏢 Branch & User Management (Admin Only)
- **Multi-Branch Support**
  - Create and manage multiple physical branches
- **Staff Management**
  - Create seller accounts
  - Assign sellers to branches
  - View, monitor, or delete branches and sellers

---

### 📊 Financial Analytics & Expenses (Admin Only)
- **Performance Dashboard**
  - Filters by **Year**, **Month**, or **Day**
  - KPI Cards:
    - Product Count
    - Transaction Count
    - Total Revenue
    - Total Expenses
    - **Net Profit**
- **Expense Management**
  - Record operational expenses
  - Automatic net profit calculation
  - Secure expense deletion

---

### 🧾 Invoicing & History
- **Transaction Logs**
  - Search by receipt ID, client name, seller, or branch
  - Sort by newest or oldest
- **Professional Receipts**
  - Printable PDF invoices
  - Includes branch, client, seller, date, and invoice number
  - Itemized breakdown:
    - Quantity
    - Product name
    - Unit price
    - Fabrication cost
    - Total price

---

## 🛠️ Tech Stack
- **Framework:** Flutter (Desktop & Web)
- **State Management:** Riverpod
- **Database:** Hive (Offline-first NoSQL)
- **Currency:** MRU (Mauritanian Ouguiya)
- **Localization:** RTL Arabic layout support

---

## 📸 Screenshots

### 👨‍💼 Admin App

**Login Screen**  
<img width="1920" height="993" alt="ad1" src="https://github.com/user-attachments/assets/006863b2-f44e-4cd5-b06e-e274d39b732c" />

**Analytics Dashboard & Net Profit**  
<img width="1920" height="991" alt="ad10" src="https://github.com/user-attachments/assets/29525a91-5647-4b51-a801-6f188a5befc2" />
<img width="1920" height="992" alt="ad11" src="https://github.com/user-attachments/assets/45cdef26-8952-437f-b9f1-80b22be9de5b" />
<img width="1918" height="991" alt="ad12" src="https://github.com/user-attachments/assets/ec347331-c874-40f2-9818-fb48ba7e3234" />
<img width="1915" height="987" alt="ad13" src="https://github.com/user-attachments/assets/826035c9-0ee9-4873-b0b6-0063c8ef4aec" />

**Branch & User Management**  
<img width="1920" height="992" alt="ad6" src="https://github.com/user-attachments/assets/90148093-482e-4060-9415-1573dc3bc5ce" />
<img width="1920" height="997" alt="ad7" src="https://github.com/user-attachments/assets/76fb8608-afb6-48ed-9b69-ddae7617976b" />
<img width="1918" height="992" alt="ad8" src="https://github.com/user-attachments/assets/42c99172-b337-4367-8193-7d627c19dd4e" />

**Product Management List**  
<img width="1920" height="991" alt="ad3" src="https://github.com/user-attachments/assets/deb7f03f-1e34-4404-972f-aef358efe06d" />

**Transaction History**  
<img width="1920" height="992" alt="ad9" src="https://github.com/user-attachments/assets/f2514fab-0409-40d0-b541-097297cda493" />
<img width="1920" height="990" alt="ad95" src="https://github.com/user-attachments/assets/71c0ee78-6668-49ec-af2a-a12b13993a0d" />

---

### 🛒 Seller App

**Seller Login**  
<img width="1920" height="996" alt="sell1" src="https://github.com/user-attachments/assets/74d448b4-8e1e-4983-9988-e5b3f28bce66" />

**POS & Product Search**  
<img width="1920" height="987" alt="sell2" src="https://github.com/user-attachments/assets/1602b6da-74fc-4afa-99fa-032abe40815c" />
<img width="1920" height="990" alt="sell3" src="https://github.com/user-attachments/assets/a3bfdccf-83ea-4834-87ce-12c1645dc131" />

**Cart & Checkout**  
<img width="1920" height="981" alt="sell4" src="https://github.com/user-attachments/assets/c3a10768-046e-474e-86ce-009ab00134b2" />

**Receipt Preview & PDF**  
<img width="1920" height="993" alt="sell5" src="https://github.com/user-attachments/assets/6375650c-f979-4177-8548-e0bceffe7747" />
<img width="1920" height="991" alt="sell6" src="https://github.com/user-attachments/assets/435933a5-7549-4107-9b99-88d8631e1440" />

---

## 📦 Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/misr-hydraulics.git](https://github.com/your-username/misr-hydraulics.git)
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the application:**
    ```bash
    # For Windows/Linux/macOS
    flutter run -d windows
    ```
