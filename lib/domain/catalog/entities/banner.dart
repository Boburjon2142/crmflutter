import 'package:equatable/equatable.dart';

class BannerItem extends Equatable {
  const BannerItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.link,
  });

  final int id;
  final String title;
  final String? imageUrl;
  final String? link;

  @override
  List<Object?> get props => [id, title, imageUrl, link];
}
