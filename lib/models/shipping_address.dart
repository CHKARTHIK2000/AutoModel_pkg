class ShippingAddress {
  final String city;
  final String zip;

  ShippingAddress({
    required this.city,
    required this.zip,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      city: json['city'],
      zip: json['zip'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'zip': zip,
    };
  }
}
