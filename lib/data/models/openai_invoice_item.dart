class OpenAIInvoiceItem {
  final String name;
  final int quantity; // Total tokens
  final double cost; // In USD cents

  OpenAIInvoiceItem({
    required this.name,
    required this.quantity,
    required this.cost,
  });

  factory OpenAIInvoiceItem.fromJson(Map<String, dynamic> json) {
    return OpenAIInvoiceItem(
      name: json['name'],
      quantity: json['quantity'],
      cost: json['cost'] / 100.0, // Convert cents to dollars
    );
  }
}
