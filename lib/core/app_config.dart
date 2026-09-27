class AppConfig {
  AppConfig._();
  static const organisationName = 'UTM Paws-itive';
  static const bankName = String.fromEnvironment('BANK_NAME');
  static const accountHolder = String.fromEnvironment('BANK_ACCOUNT_HOLDER');
  static const accountNumber = String.fromEnvironment('BANK_ACCOUNT_NUMBER');
  static bool get manualPaymentsConfigured =>
      bankName.isNotEmpty &&
      accountHolder.isNotEmpty &&
      accountNumber.isNotEmpty;
}
