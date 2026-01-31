import 'package:equatable/equatable.dart';

class Author extends Equatable {
  const Author({
    required this.id,
    required this.name,
    required this.bio,
    required this.isFeatured,
    required this.photoUrl,
  });

  final int id;
  final String name;
  final String bio;
  final bool isFeatured;
  final String? photoUrl;

  @override
  List<Object?> get props => [id, name, bio, isFeatured, photoUrl];
}
