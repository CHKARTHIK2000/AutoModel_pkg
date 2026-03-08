class Address {
  final String city;
  final String zip;

  Address({
    required this.city,
    required this.zip,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
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
