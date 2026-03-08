import 'orders.dart';

class Root {
  final List<Orders> orders;

  Root({
    required this.orders,
  });

  factory Root.fromJson(Map<String, dynamic> json) {
    return Root(
      orders: (json['orders'] as List).map((i) => Orders.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((i) => i.toJson()).toList(),
    };
  }
}
