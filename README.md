# Project Latte
**A Premium Native Windows Desktop POS System for Coffee Shops**

---

## Overview

Project Latte is a high-speed, offline-first Point of Sale (POS) system built with Flutter for Windows desktop. Designed with a premium "Latte" aesthetic and full compliance with Philippine Bureau of Internal Revenue (BIR) tax regulations, it streamlines coffee shop operations from order management to thermal receipt printing, auditing, and enterprise-grade financial reporting.

**Target Platform**: Windows 11+  
**Development Status**: Production Release (v1.0.0)

---

## Features

### Fully Implemented Core Modules

#### Phase 1: Design System & Styling
- [x] Curated Latte color palette (`#F3EFE9` Crema background, `#7A6657` Espresso primary, `#D4A574` Caramel accents, `#C84B31` Terracotta highlights)
- [x] Custom typography hierarchy (Headings, body text, labels, large price tags)
- [x] Reusable UI components:
  - `LatteButton` - Primary action button
  - `CategoryPill` - Touch-friendly category selector
  - `ItemCard` - High-density product display card
  - `OrderSummaryCard` - Live active order totals display
- [x] Material 3 design system integration

#### Phase 2: Data Models & SQLite Seeding
- [x] `Product` model with variant pricing, sizes, temperatures, and add-ons
- [x] `Category` model for menu organization
- [x] `OrderItem` model tracking real-time customizations
- [x] `Order` model for transaction persistence
- [x] `AddOn` model for extras (syrups, extra espresso shots, heavy cream)
- [x] Automated SQLite seeding of 48 realistic coffee & cafe products
- [x] Dynamic base price calculation by size (Small/Medium/Large pricing tiers)

#### Phase 3: Core Cashier UI (3-Column Ergonomics)
- [x] **Left Column**: Category navigation rail with visual category identifiers
- [x] **Center Column**: Responsive, high-density product grid
- [x] **Right Column**: Live active order summary with instant subtotaling
- [x] Interactive Product Selection Modal:
  - Size selection (Small, Medium, Large)
  - Temperature selection (Hot, Iced)
  - Add-on selection with optional extra pricing
  - Real-time price preview updates
- [x] Order Cart Management:
  - Add/remove items instantly
  - Auto-combine identical product variants and customizations
  - Clear entire active order instantly
- [x] **Philippine Tax Compliance (BIR)**:
  - Automatic 12% VAT calculation included in base prices
  - Clear itemized tax breakdown in the order summary

#### Phase 4: Database & Business Logic
- [x] Offline-first SQLite database initialization via `sqflite_common_ffi`
- [x] Centralized Provider state management (`OrderProvider`)
- [x] Complete CRUD operations for Products, Orders, and Daily Sales Data
- [x] BIR Tax Logic Refinement:
  - Automated Senior Citizen / PWD ID verification & 20% discount + VAT exemption calculation
  - PIN-protected transaction voiding (`1234`) with instant SQLite status updates
  - Complete transaction audit trails

#### Phase 5: Payments & Thermal Receipts
- [x] Split-Screen Payment Modal:
  - **Cash Tender**: Built-in big-number change calculator to eliminate cashier math errors
  - **e-Wallet Tender**: Interactive on-screen touch numpad with quick prefix buttons (`GCash-`, `Maya-`, `QR-`) for rapid reference logging
- [x] ESC/POS Thermal Printer Integration:
  - Simulated USB buffer printing (`USB001`)
  - Direct standalone PDF generation and saving via native Windows dialogs
- [x] Thermal Receipt Preview Dock:
  - Fixed-height, scroll-isolated 80mm thermal paper preview matching physical hardware outputs
  - Complete receipt itemization with tax breakdowns and applied discount notes

#### Phase 6: Admin Management Console & Enterprise UI
- [x] **Secure Access**: Protected by 4-digit Admin PIN authorization from the cashier dashboard
- [x] **Sales Analytics & Reconciliation**:
  - Real-time KPI cards for Gross Revenue, Net Revenue (Gross - VAT - Discounts), VAT collected, SC/PWD discounts applied, Transaction Counts, and Average Order Value
  - Tender Reconciliation: Visual breakdown of Cash Drawer (Physical Cash), E-Wallet (GCash/Maya transfers), and Credit/Debit Card terminal totals for shift-end audits
  - Sales by Menu Category: SQL `JOIN`-powered breakdown of quantity sold and gross revenue per category
  - Animated Revenue Charts: Custom hourly sales bar chart tracking peak business hours with interactive tooltips
  - Top Products Ranking: Aggregated ranking table for the top 10 best-selling items
  - Responsive Layout Scaling: Bulletproof desktop scaling utilizing `Expanded` and `TextOverflow.ellipsis` to eliminate `RenderFlex` overflow exceptions
- [x] **Export & Accounting Reports**:
  - Interactive Report Filter Bar: Enterprise multi-criteria filtering by custom Date Range, Payment Method (`All`, `Cash`, `E-Wallet`, `Card`), and Transaction Status (`All`, `Completed`, `Voided`)
  - High-Density Export List View: Streamlined vertical layout for generating reports
  - Daily Sales Report (PDF): Multi-page formal accounting report embedding financial summaries, tender reconciliation, and category sales tables
  - Filtered Accounting (CSV): Master transaction spreadsheet dynamically injecting shop credentials (`Store Name`, `Address`, `TIN`) and applied filter metadata for QuickBooks / Excel import
  - Filtered Inventory (CSV): Granular itemized line-item spreadsheet tracking every individual cup, size, and add-on sold for precise inventory depletion audits
- [x] **System Settings Panel**: Live configuration of shop credentials, tax/discount rates, and hardware peripheral settings, dynamically injected into all generated reports
- [x] **Enterprise Pagination & Navigation**:
  - Top Pagination Bars implemented in both Menu Management and Transaction History modules (10 items per page)
  - Horizontal scroll protection for numbered page selectors to ensure bulletproof UI scaling
  - Master Header Bars combining filter dropdowns and pagination controls into a single elegant, space-saving layout

---

## Project Structure

```
Project-Latte/
├── lib/
│   ├── main.dart                 # App entry point & MultiProvider setup
│   ├── theme/
│   │   └── app_theme.dart        # Design system (colors, typography, themes)
│   ├── widgets/
│   │   ├── latte_components.dart # Reusable UI components
│   │   ├── payment_modal.dart    # Cash calculator & e-Wallet numpad
│   │   ├── scpwd_dialog.dart     # BIR Tax Exemption verification
│   │   └── receipt_preview.dart  # 80mm thermal paper preview & PDF dock
│   ├── screens/
│   │   ├── cashier_screen.dart   # Main 3-column POS interface
│   │   ├── history_screen.dart   # Transaction auditing, PIN voiding & Master Header Bar
│   │   └── admin_screen.dart     # Admin management console & sales charts
│   ├── models/
│   │   └── product_model.dart    # Data models (Product, Order, AddOn)
│   ├── data/
│   │   ├── mock_menu.dart        # Complete Project Latte Menu
│   │   └── database.dart         # SQLite FFI database helper
│   ├── services/
│   │   ├── tax_service.dart      # Philippine tax calculations (VAT/SC/PWD)
│   │   └── order_service.dart    # Order orchestration & persistence
│   └── utils/
│       └── constants.dart        # App-wide constants
├── pubspec.yaml                  # Dependencies
├── windows/                       # Windows desktop configuration
├── README.md                      # This file
└── docs/                          # Documentation
    └── coffee-menu/              # Coffee menu reference files
```

---

## Technology Stack

- **Framework**: Flutter 3.41.9
- **Platform**: Windows (Desktop Native C++ Compilation)
- **State Management**: Provider (`ChangeNotifier` + `MultiProvider`)
- **Database**: SQLite via `sqflite_common_ffi`
- **Printing**: ESC/POS via `flutter_pos_printer_platform`
- **PDF Generation**: `pdf` & `printing` packages
- **Date/Currency Formatting**: `intl`
- **Window Management**: `window_manager`

---

## Installation & Setup

### Prerequisites
- Windows 11 or higher (24H2)
- Visual Studio Community 2022+ with "Desktop development with C++" workload
- Flutter SDK 3.41.9+ (stable channel)
- Git

### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Project-Latte
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Enable Windows desktop (if not already enabled)**
   ```bash
   flutter config --enable-windows-desktop
   ```

4. **Run the app**
   ```bash
   flutter run -d windows
   ```

5. **Build for release** (Standalone Windows Executable)
   ```bash
   flutter build windows --release
   ```

---

## Current Known Issues

- None. Fully optimized for production cafe deployment.

---

## Philippine Tax Compliance (BIR)

**Fully Implemented & Audited**:
- 12% VAT calculation on all transactions
- Itemized tax breakdown in order summary
- Automated SC/PWD exemption handling (VAT deduction + 20% discount)
- PIN-protected void transaction logging with complete audit trail
- BIR-compliant thermal receipt formatting

---


## Peripherals Support

- **Thermal Printer**: 80mm USB ESC/POS compatible (`USB001` buffer & direct PDF printing)
- **Barcode Scanner**: USB HID compatible
- **Cash Drawer**: USB/Serial ESC/POS compatible

---

## Testing Checklist

### Functional Testing
- [x] Add items to order with various customizations
- [x] Remove items from order
- [x] Verify tax calculations (12% VAT & SC/PWD discounts)
- [x] Category filtering works correctly
- [x] Order totals update in real-time
- [x] Admin PIN authorization works securely
- [x] SQLite database persists across app restarts

### UI/UX Testing
- [x] Theme colors render correctly across all screens
- [x] Typography is readable across all sizes
- [x] Responsive layout scales flawlessly on 1280x720 and 1920x1080
- [x] Dialog animations are smooth and responsive
- [x] Top pagination bars prevent horizontal and vertical overflow

### Edge Cases
- [x] Large orders (50+ items)
- [x] Decimal pricing calculations
- [x] Add-ons with high quantity orders
- [x] Rapid category switching and filter resets

---

## Performance Targets

- App startup: < 2 seconds
- Product grid load: < 500ms
- Order calculation: < 50ms
- Receipt generation: < 1 second
- Database queries: < 100ms

---

## License

Proprietary - Project Latte (Coffee Shop POS System)

---

---

## Changelog

### v1.0.0 (Production Release)
- 100% Core Features Complete
- Enterprise Admin Dashboard with live SQLite synchronization
- Master Header Bars & Top Pagination in Menu Management and Transaction History
- Formal PDF & CSV Export Suite with dynamic metadata injection
- Complete BIR Tax Compliance & e-Wallet Numpad Integration

---
