# PROJECT LATTE: SYSTEM LOGIC & OPERATIONAL RULES

---

## 1. Security & Authorization

| Module | Logic & Rules |
| :---: | ----- |
| **Cashier Mode** | Default active mode upon application startup. Can process sales, customize items with add-ons, select payment methods, and apply BIR-mandated Senior Citizen / PWD discounts. |
| **Admin Mode** | Protected by a mandatory 4-digit Admin PIN (`1234`). Required to access the Admin Management Console (Daily Sales Reports, Charts, Settings) and authorize transaction voiding (`_voidOrder`). |

---

## 2. Transaction & Payment Flows

| Module | Logic & Rules |
| :---: | ----- |
| **Cash Tender** | Cashier inputs the physical cash amount tendered. The system instantly calculates and displays the exact change due, eliminating mental math errors during peak hours. |
| **e-Wallet Tender** | Cashier utilizes the interactive on-screen touch numpad to quickly log the GCash, Maya, or QR reference number (with quick-prefix buttons) for automated reconciliation. |
| **BIR Exemption** | Cashier verifies Senior Citizen/PWD ID. The system automatically extracts the 12% VAT from the subtotal and applies the statutory 20% discount on the VAT-exempt amount. |

---

## 3. Data Persistence & Auditing

| Module | Logic & Rules |
| :---: | ----- |
| **Local Database** | All products, orders, order items, and daily sales metrics are saved instantly to a local SQLite database (`sqflite_common_ffi`) ensuring 100% offline-first reliability. |
| **Accounting Exports** | The Owner can generate filtered, formal Daily Sales PDF reports and master CSV spreadsheets for seamless import into QuickBooks or Microsoft Excel. |
| **Inventory Depletion** | The Owner can export an itemized inventory CSV tracking every individual cup, size, and syrup add-on sold for precise ingredient audit trailing. |

---

## 4. Receipt & UI Layout Standards

| Module | Logic & Rules |
| :---: | ----- |
| **Receipt Layout** | **Header:** Cafe Name, Address, Contact, TIN. <br>**Body:** Order Number (Large), Itemized List, Size, Add-ons, Subtotal. <br>**Footer:** 12% VAT Breakdown, SC/PWD Discount details, Cashier Name, "Thank you!" |
| **Master Header Bar** | In Transaction History, filter dropdowns (`Date`, `Method`, `Status`) and top pagination controls (`1-10 of 45`) are unified into a single elegant crema header bar. |
| **Top Pagination** | In Menu Management and Transaction History, lists are paginated at 10 items per page with horizontal scroll protection for numbered page selectors. |
