enum PaymentMethod {
  cash,
  card,
  qr;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.qr:
        return 'Código QR';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.cash:
        return '💵';
      case PaymentMethod.card:
        return '💳';
      case PaymentMethod.qr:
        return '📱';
    }
  }

  String get code {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.qr:
        return 'qr';
    }
  }

  static PaymentMethod fromCode(String code) {
    try {
      return PaymentMethod.values.firstWhere((m) => m.code == code);
    } catch (_) {
      return PaymentMethod.cash;
    }
  }
}
