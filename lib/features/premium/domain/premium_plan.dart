enum PremiumPlan {
  monthly(label: 'Hàng tháng', price: '\$3', period: 'tháng'),
  yearly(label: 'Hàng năm', price: '\$33', period: 'năm');

  const PremiumPlan({
    required this.label,
    required this.price,
    required this.period,
  });
  final String label;
  final String price;
  final String period;
  String get priceWithPeriod => '$price / $period';
}
