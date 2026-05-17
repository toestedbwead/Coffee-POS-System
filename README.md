# Project Latte ☕
**A Premium Native Windows Desktop POS System for Coffee Shops**

---

## Overview

Project Latte is a high-speed, offline-first Point of Sale (POS) system built with Flutter for Windows desktop. Designed with a premium "Latte" aesthetic and full compliance with Philippine tax regulations, it streamlines coffee shop operations from order management to receipts and reporting.

**Target Platform**: Windows 11+  
**Development Status**: Phase 3 (Core UI Complete)

---

## Features

### ✅ Implemented

#### Phase 1: Design System
- [x] Latte color palette (#F3EFE9 background, #7A6657 primary, #D4A574 caramel accents)
- [x] Custom typography system (headings, body text, labels, price tags)
- [x] Reusable UI components:
  - `LatteButton` - Primary action button
  - `CategoryPill` - Category selector
  - `ItemCard` - Product display card
  - `OrderSummaryCard` - Order totals display
- [x] Material 3 theme integration

#### Phase 2: Data Models & Mock Data
- [x] `Product` model with pricing, sizes, temperatures, add-ons
- [x] `Category` model for menu organization
- [x] `OrderItem` model with customization tracking
- [x] `Order` model for transaction recording
- [x] `AddOn` model for extras (syrup, extra shots, etc.)
- [x] Mock menu with 11 realistic coffee products
- [x] Price calculation by size (Small/Medium/Large pricing)

#### Phase 3: Core Cashier UI (3-Column Layout)
- [x] **Left Column**: Category navigation with emoji icons
- [x] **Center Column**: Responsive product grid (3 columns)
- [x] **Right Column**: Live order summary with real-time calculations
- [x] Product selection dialog with:
  - Size selection (Small, Medium, Large)
  - Temperature selection (Hot, Iced)
  - Add-ons selection with optional extras
  - Real-time price preview
- [x] Order management:
  - Add items to current order
  - Remove items from order
  - Auto-combine duplicate items (same product + customization)
  - Clear entire order
- [x] **Philippine Tax Compliance**:
  - 12% VAT calculation included in totals
  - Tax shown separately in order summary

---

### 🔄 In Progress / Planned

#### Phase 4: Database & Business Logic
- [x] SQLite database initialization for Windows desktop
- [x] Provider state management integration (`OrderProvider`)
- [x] CRUD operations for:
  - [x] Products (admin panel)
  - [x] Orders (transaction history)
  - [x] Daily sales data
- [x] PH Tax Logic refinement:
  - [x] SC/PWD exemption handling (Senior Citizen / Person with Disability)
  - [x] Void transaction logging with admin password
  - [x] Tax audit trail
- [x] Admin authentication:
  - [x] Password-protected admin actions
  - [x] Audit logging for voids and discounts

#### Phase 5: Payments & Receipts
- [x] Payment method selection:
  - [x] Cash payment with change calculator
  - [x] e-Wallet payment with reference number capture
- [ ] Receipt generation:
  - 80mm thermal printer format
  - Receipt preview before printing
  - Receipt itemization with tax breakdown
- [ ] ESC/POS printer integration:
  - USB thermal printer support
  - Print to file option
  - Printer status detection
- [ ] Receipt storage:
  - Receipt templates customization
  - Receipt archiving in database

#### Phase 6: Admin & Reporting
- [ ] Admin dashboard:
  - Daily sales summary
  - Top-selling items
  - Revenue trends
  - Transaction history
- [ ] Export functionality:
  - CSV export for accounting
  - Excel reports
  - Daily/weekly/monthly reports
- [ ] Settings panel:
  - Shop info configuration
  - Tax settings
  - Printer settings
  - Product management (add/edit/delete)

#### Phase 7: Advanced Features (Post-MVP)
- [ ] Multi-terminal support (network syncing)
- [ ] Customer loyalty program
- [ ] Inventory tracking
- [ ] Staff management & performance tracking
- [ ] SMS/Email receipt sending
- [ ] Dark mode toggle
- [ ] Keyboard shortcuts for power users

---

## Project Structure

```
Project-Latte/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── theme/
│   │   └── app_theme.dart        # Design system (colors, typography, themes)
│   ├── widgets/
│   │   └── latte_components.dart # Reusable UI components
│   ├── screens/
│   │   ├── cashier_screen.dart   # Main 3-column POS interface
│   │   ├── checkout_screen.dart  # (Phase 5)
│   │   ├── admin_screen.dart     # (Phase 6)
│   │   └── reports_screen.dart   # (Phase 6)
│   ├── models/
│   │   └── product_model.dart    # Data models (Product, Order, etc.)
│   ├── data/
│   │   ├── mock_menu.dart        # Mock data for development
│   │   └── database.dart         # (Phase 4) SQLite helper
│   ├── services/
│   │   ├── tax_service.dart      # (Phase 4) PH tax calculations
│   │   ├── printer_service.dart  # (Phase 5) ESC/POS printing
│   │   └── order_service.dart    # (Phase 4) Order management
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
- **Platform**: Windows (Desktop)
- **State Management**: Provider (Phase 4+)
- **Database**: SQLite via `sqflite_common_ffi`
- **Printing**: ESC/POS via `flutter_pos_printer_platform` (Phase 5)
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

5. **Build for release** (when ready)
   ```bash
   flutter build windows --release
   ```

---

## Development Roadmap

| Phase | Focus | Status | ETA |
|-------|-------|--------|-----|
| 0 | Environment Setup | ✅ Complete | - |
| 1 | Design System | ✅ Complete | - |
| 2 | Data Models & Mock Data | ✅ Complete | - |
| 3 | Core Cashier UI | ✅ Complete | - |
| 4 | Database & Business Logic | ✅ Complete | - |
| 5 | Payments & Receipts | 🔄 In Progress | Week 3-4 |
| 6 | Admin & Reporting | ⏳ Planned | Week 5-6 |
| 7 | Advanced Features | ⏳ Backlog | Post-MVP |

---

## Current Known Issues

- None yet! Report issues via GitHub Issues.

---

## Philippine Tax Compliance

✅ **Implemented**:
- 12% VAT calculation on all transactions
- Tax breakdown in order summary

🔄 **In Development**:
- SC/PWD exemption handling
- Void transaction logging with audit trail
- BIR-compliant receipt format (Phase 5)

---

## Hardware Requirements

### Minimum
- Intel Core i5 / AMD Ryzen 5
- 8 GB RAM
- 500 MB SSD storage
- 1280x720 display (landscape recommended)

### Recommended
- Intel Core i7 / AMD Ryzen 7
- 16 GB RAM
- 1 GB SSD storage
- 1920x1080+ display (for multi-terminal future)

---

## Peripherals (Phase 5+)

- **Thermal Printer**: 80mm USB ESC/POS compatible
- **Barcode Scanner**: USB HID compatible
- **Cash Drawer**: USB/Serial ESC/POS compatible
- **Customer Display**: (Future feature)

---

## Testing Checklist

### Functional Testing
- [ ] Add items to order with various customizations
- [ ] Remove items from order
- [ ] Verify tax calculations (12% VAT)
- [ ] Category filtering works correctly
- [ ] Order totals update in real-time

### UI/UX Testing
- [ ] Theme colors render correctly
- [ ] Typography is readable across all sizes
- [ ] Responsive layout on 1280x720, 1920x1080
- [ ] Dialog animations are smooth
- [ ] Error messages are clear

### Edge Cases
- [ ] Large orders (50+ items)
- [ ] Decimal pricing calculations
- [ ] Add-ons with high quantity orders
- [ ] Rapid category switching

---

## Performance Targets

- App startup: < 2 seconds
- Product grid load: < 500ms
- Order calculation: < 50ms
- Receipt generation: < 1 second
- Database queries: < 100ms

---

## Contributing

This is a solo project currently. For major feature requests, open an issue with:
- Feature description
- Use case / business need
- Proposed solution

---

## License

Proprietary - Project Latte (Coffee Shop POS System)

---

## Contact & Support

**Developer**: Your Name  
**Email**: your.email@example.com  
**Last Updated**: May 12, 2026

---

## Changelog

### v0.3.0 (Current - Phase 3 Complete)
- ✅ Core 3-column cashier UI
- ✅ Product selection with customization
- ✅ Real-time order calculation
- ✅ PH tax compliance (12% VAT)

### v0.2.0 (Phase 2 Complete)
- ✅ Data models and mock menu
- ✅ 11 coffee products with realistic pricing

### v0.1.0 (Phase 1 Complete)
- ✅ Design system and theme
- ✅ Reusable UI components

---

## Quick Tips for Users

1. **Category Switching**: Click category pills on the left to filter products
2. **Product Selection**: Click any coffee to open customization dialog
3. **Add-ons**: Select optional add-ons (syrups, extra shots) before adding to order
4. **Order Management**: Click the X button on items to remove them
5. **Clear Order**: Use "CLEAR ORDER" button to start fresh
6. **Pricing**: Prices automatically adjust based on size selection

---

## Planned Enhancements

- [ ] Keyboard shortcuts (Ctrl+1 for Category 1, etc.)
- [ ] Barcode scanning for products
- [ ] Customer loyalty points
- [ ] Discount code system
- [ ] Multi-shift support
- [ ] Sales analytics dashboard
- [ ] Inventory auto-reorder alerts

---

**Happy Selling! ☕💰**