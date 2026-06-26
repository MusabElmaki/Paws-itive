/// App-wide configuration values that an admin/dev should customise before
/// going live. Kept in one place so there are no magic strings scattered
/// across the UI.
class AppConfig {
  AppConfig._();

  /// Organisation name shown on the donation screen / QR.
  static const String organisationName = 'UTM Paws-itive';

  /// DuitNow / bank identifier the donor scans in their banking app.
  /// TODO: replace this placeholder with the real DuitNow ID or bank account
  /// number for the organisation.
  static const String duitNowId = 'DUITNOW-PLACEHOLDER-0123456789';

  /// Bank name + account holder shown alongside the QR for manual transfers.
  static const String bankName = 'Maybank';
  static const String accountHolder = 'UTM Paws-itive Society';
  static const String accountNumber = '5123 4567 8901'; // placeholder

  /// Builds the textual payload encoded into the donation QR code. A real
  /// DuitNow QR would use the EMVCo payload format; for now we encode a clear,
  /// human-readable reference that banking apps / donors can act on.
  static String donationQrPayload({double? amount}) {
    final amountPart = amount != null && amount > 0 ? '|AMOUNT:RM${amount.toStringAsFixed(2)}' : '';
    return 'DUITNOW|ID:$duitNowId|NAME:$organisationName$amountPart';
  }
}
