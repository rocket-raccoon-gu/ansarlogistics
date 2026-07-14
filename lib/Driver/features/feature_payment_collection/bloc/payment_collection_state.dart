abstract class PaymentCollectionState {}

class PaymentCollectionInitial extends PaymentCollectionState {}

class PaymentCollectionLoaded extends PaymentCollectionState {
  final double totalAmount;
  final double cashAmount;
  final double cardAmount;
  final String paymentMethod; // 'cash', 'card', 'split'
  final String orderPaymentMethod; // default payment method from order response
  final double balanceRemaining;

  PaymentCollectionLoaded({
    required this.totalAmount,
    required this.cashAmount,
    required this.cardAmount,
    required this.paymentMethod,
    required this.orderPaymentMethod,
    required this.balanceRemaining,
  });

  PaymentCollectionLoaded copyWith({
    double? totalAmount,
    double? cashAmount,
    double? cardAmount,
    String? paymentMethod,
    String? orderPaymentMethod,
    double? balanceRemaining,
  }) {
    return PaymentCollectionLoaded(
      totalAmount: totalAmount ?? this.totalAmount,
      cashAmount: cashAmount ?? this.cashAmount,
      cardAmount: cardAmount ?? this.cardAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderPaymentMethod: orderPaymentMethod ?? this.orderPaymentMethod,
      balanceRemaining: balanceRemaining ?? this.balanceRemaining,
    );
  }
}

class PaymentCollectionInProgress extends PaymentCollectionState {}

class PaymentCollectionSuccess extends PaymentCollectionState {}

class PaymentCollectionError extends PaymentCollectionState {
  final String message;
  PaymentCollectionError(this.message);
}
