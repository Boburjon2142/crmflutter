import 'package:equatable/equatable.dart';

class CrmCourier extends Equatable {
  const CrmCourier({
    required this.id,
    required this.name,
    required this.phone,
    required this.telegramUsername,
    required this.isActive,
  });

  final int id;
  final String name;
  final String phone;
  final String telegramUsername;
  final bool isActive;

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        telegramUsername,
        isActive,
      ];
}
