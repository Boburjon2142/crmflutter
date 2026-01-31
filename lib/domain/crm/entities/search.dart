import 'package:equatable/equatable.dart';

class CrmSearchItem extends Equatable {
  const CrmSearchItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  final int id;
  final String title;
  final String subtitle;
  final String meta;

  @override
  List<Object?> get props => [id, title, subtitle, meta];
}

class CrmSearchSection extends Equatable {
  const CrmSearchSection({
    required this.key,
    required this.title,
    required this.items,
  });

  final String key;
  final String title;
  final List<CrmSearchItem> items;

  @override
  List<Object?> get props => [key, title, items];
}

class CrmSearchResult extends Equatable {
  const CrmSearchResult({
    required this.query,
    required this.sections,
  });

  final String query;
  final List<CrmSearchSection> sections;

  @override
  List<Object?> get props => [query, sections];
}
