/// Tax Service for Philippine POS compliance
/// Handles VAT calculations and SC/PWD exemptions

class TaxService {
  // Standard VAT rate in Philippines
  static const double VAT_RATE = 0.12; // 12%

  // Senior Citizen / Person with Disability discount
  static const double SC_PWD_DISCOUNT = 0.20; // 20% discount

  /// Calculate tax on subtotal (standard 12% VAT)
  static double calculateVAT(double subtotal) {
    return subtotal * VAT_RATE;
  }

  /// Calculate tax-inclusive total
  static double calculateTotalWithVAT(double subtotal) {
    return subtotal + calculateVAT(subtotal);
  }

  /// Apply SC/PWD exemption (20% discount on VAT-exclusive portion)
  /// Returns: {subtotal, vat, total, discount, scPwdApplied}
  static Map<String, double> calculateWithSCPWDExemption(double subtotal) {
    // SC/PWD gets 20% discount on the VAT-exclusive amount
    final discount = subtotal * SC_PWD_DISCOUNT;
    final discountedSubtotal = subtotal - discount;
    final vat = calculateVAT(discountedSubtotal);
    final total = discountedSubtotal + vat;

    return {
      'originalSubtotal': subtotal,
      'discount': discount,
      'subtotal': discountedSubtotal,
      'vat': vat,
      'total': total,
    };
  }

  /// Detailed breakdown for receipt printing
  static Map<String, dynamic> getReceiptBreakdown(
    double subtotal, {
    bool applySCPWD = false,
  }) {
    if (applySCPWD) {
      final breakdown = calculateWithSCPWDExemption(subtotal);
      return {
        'originalAmount': subtotal,
        'scPwdDiscount': breakdown['discount'],
        'discountedAmount': breakdown['subtotal'],
        'vat': breakdown['vat'],
        'vatRate': '${(VAT_RATE * 100).toStringAsFixed(0)}%',
        'discountRate': '${(SC_PWD_DISCOUNT * 100).toStringAsFixed(0)}%',
        'totalAmount': breakdown['total'],
        'scPwdApplied': true,
      };
    } else {
      final vat = calculateVAT(subtotal);
      return {
        'originalAmount': subtotal,
        'scPwdDiscount': 0.0,
        'discountedAmount': subtotal,
        'vat': vat,
        'vatRate': '${(VAT_RATE * 100).toStringAsFixed(0)}%',
        'discountRate': '0%',
        'totalAmount': subtotal + vat,
        'scPwdApplied': false,
      };
    }
  }

  /// Validate transaction for audit trail
  static Map<String, dynamic> auditTransaction({
    required String transactionId,
    required double amount,
    required String paymentMethod,
    bool scPwdApplied = false,
    String? adminUserName,
    String? notes,
  }) {
    return {
      'transactionId': transactionId,
      'timestamp': DateTime.now().toIso8601String(),
      'amount': amount,
      'paymentMethod': paymentMethod,
      'scPwdApplied': scPwdApplied,
      'adminUserName': adminUserName,
      'notes': notes,
      'auditTrail': true,
    };
  }

  /// Check if transaction qualifies for SC/PWD
  static bool validateSCPWDID(String idNumber) {
    // Basic validation - in production, this would verify actual SC/PWD ID
    // For now, just check if a valid format is provided
    return idNumber.isNotEmpty && idNumber.length >= 5;
  }

  /// Format currency for display
  static String formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  /// Format percentage
  static String formatPercentage(double percent) {
    return '${(percent * 100).toStringAsFixed(1)}%';
  }
}