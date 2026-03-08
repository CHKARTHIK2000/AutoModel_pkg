class Items {
  final String name;
  final int price;

  Items({
    required this.name,
    required this.price,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      name: json['name'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}
