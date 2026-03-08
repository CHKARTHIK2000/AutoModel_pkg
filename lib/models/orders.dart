import 'items.dart';

class Orders {
  final int id;
  final List<Items> items;

  Orders({
    required this.id,
    required this.items,
  });

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      id: json['id'],
      items: (json['items'] as List).map((i) => Items.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
