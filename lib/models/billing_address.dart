class BillingAddress {
  final String city;
  final String zip;

  BillingAddress({
    required this.city,
    required this.zip,
  });

  factory BillingAddress.fromJson(Map<String, dynamic> json) {
    return BillingAddress(
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
