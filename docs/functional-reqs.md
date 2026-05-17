# PROJECT LATTE: FUNCTIONAL REQUIREMENTS & SYSTEM SPECIFICATIONS

---

## 1. Core System Specifications

| Feature | Specification |
| :---: | :---- |
| **Platform** | Native Windows Desktop (C++ Compilation / Windows 11+) |
| **Pricing** | VAT-Inclusive (Prices on menu include 12% Philippine VAT) |
| **UI Type** | Variant-based (One button per drink flavor with modifier popups) |
| **Discounting** | Automatic BIR SC/PWD calculation (VAT Exemption + 20% Discount) |
| **Modifier Style** | Passive/On-Demand (Streamlined size, temp & syrup selection) |
| **Output** | Standard 80mm Thermal Receipt Printing (ESC/POS & PDF format) |

---

## 2. Operational Logic & Permissions

| Feature | Specification |
| :---: | ----- |
| **App Type** | Standalone Desktop Application (Offline-first SQLite FFI) |
| **Payment Logic** | Multi-channel: Cash (Change Calculator), e-Wallet (GCash/Maya Numpad) |
| **Queueing** | Auto-generating Order Numbers (Printed on receipt & saved in SQLite) |
| **Permissions** | **Owner/Admin:** Full access (Sales reports, Price editing, PIN Voiding) <br>**Cashier:** Transactional access (Sales, Add-ons, SC/PWD discounts) |
| **Inventory** | Itemized CSV export tracking line-item depletion for auditing |

---

## 3. Compliance & Reporting Standards

| Feature | Specification |
| :---: | ----- |
| **Tax Compliance** | Bureau of Internal Revenue (BIR) compliant formulas & audit trails |
| **Reconciliation** | Shift-end visual breakdown of Cash Drawer, e-Wallet, and Card tenders |
| **Exports** | Formal Daily Sales PDF reports & accounting CSV spreadsheets |
| **Scalability** | High-density Top Pagination Bars (10 items/page) & Master Header Bars |
