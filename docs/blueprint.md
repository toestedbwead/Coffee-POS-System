**PROJECT LATTE: POS SYSTEM BLUEPRINT**  
Comprehensive Development Plan \&amp; Functional Requirements

**1\. Project Vision**  
A native Windows desktop application designed for high-speed café operations. The system features a custom aesthetic (Cremes \&amp; Mochas) and prioritizes offline reliability, secure admin controls, and automated Philippine tax compliance.

**2\. Technical Stack**  
• Framework: Flutter for Desktop (Native Windows/C++)  
• Database: SQLite (Local-first, no internet required)  
• Theme: Latte (Background: \#F3EFE9, Primary: \#7A6657)  
• Printing: ESC/POS Protocol via USB to 80mm Thermal Printer

**3\. Core Functional Requirements**  
A. Cashier Flow (3-Column Layout)  
• Navigation: Category Pills → Item Grid → Selection Pop-up (Temp: Hot/Iced → Size).  
• Attached Add-ons: Syrups, Sauces, and Shots are nested under parent drinks on the  
receipt and screen.  
• Automated Change: System prompts for &\#39;Amount Tendered&\#39; and displays Big Number  
Change automatically to prevent mental math errors.  
B. Compliance and Discounts  
• SC/PWD Logic: Automated calculation following PH Law (Price ÷ 1.12 × 0.80).  
Requires ID number entry for records.  
• VAT: Prices are VAT-inclusive by default, with a clear breakdown on the printed  
Receipt.  
C. Security \&amp; Admin  
• Roles: Separate Cashier (Sales only) and Admin (Management) accounts.  
• Authorized Voids: Any item deletion or transaction cancellation requires an Admin/Owner Password.  
**4\. Operational Logic (The Decision Tree)**  
The system follows a &\#39;Parent-Child&\#39; structure to keep the UI clean:  
1\. Select Flavor (e.g., Spanish Latte)  
2\. Select Temperature (Hot or Iced)  
3\. Select Size (S/M for Hot, M/L for Iced)  
4\. Attach Add-ons (Optional)

**5\. Output and Reporting**  
• 80mm Receipt: Includes Large Order Number, Itemized List with attached modifiers, Change Amount, and VAT details.  
• EOD Report: Daily summary tracking Cash vs. e-Wallet (GCash/Maya Ref \#s) totals.  
• Export: Button to generate .xlsx files for monthly bookkeeping.  
