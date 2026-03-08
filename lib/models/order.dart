import 'shipping_address.dart';

class Order {
  final int orderId;
  final ShippingAddress shippingAddress;
  final ShippingAddress billingAddress;

  Order({
    required this.orderId,
    required this.shippingAddress,
    required this.billingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      shippingAddress: ShippingAddress.fromJson(json['shipping_address']),
      billingAddress: ShippingAddress.fromJson(json['billing_address']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'shipping_address': shippingAddress.toJson(),
      'billing_address': billingAddress.toJson(),
    };
  }
}
