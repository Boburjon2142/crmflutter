import '../../../domain/crm/entities/search.dart';

class CrmSearchResultModel {
  CrmSearchResultModel({
    required this.query,
    required this.sections,
  });

  final String query;
  final Map<String, List<CrmSearchItemModel>> sections;

  factory CrmSearchResultModel.fromJson(Map<String, dynamic> json) {
    final query = json['query']?.toString() ?? '';
    final sectionsRaw = json['sections'];
    final Map<String, List<CrmSearchItemModel>> sections = {};
    if (sectionsRaw is Map<String, dynamic>) {
      for (final entry in sectionsRaw.entries) {
        final list = entry.value is List ? entry.value as List : [];
        sections[entry.key] = list
            .whereType<Map<String, dynamic>>()
            .map(CrmSearchItemModel.fromJson)
            .toList();
      }
    }
    return CrmSearchResultModel(query: query, sections: sections);
  }

  CrmSearchResult toEntity() {
    return CrmSearchResult(
      query: query,
      sections: sections.entries
          .map(
            (entry) => CrmSearchSection(
              key: entry.key,
              title: _titleForKey(entry.key),
              items: entry.value.map((item) => item.toEntity()).toList(),
            ),
          )
          .toList(),
    );
  }
}

class CrmSearchItemModel {
  CrmSearchItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  final int id;
  final String title;
  final String subtitle;
  final String meta;

  factory CrmSearchItemModel.fromJson(Map<String, dynamic> json) {
    return CrmSearchItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      meta: json['meta']?.toString() ?? '',
    );
  }

  CrmSearchItem toEntity() => CrmSearchItem(
        id: id,
        title: title,
        subtitle: subtitle,
        meta: meta,
      );
}

String _titleForKey(String key) {
  switch (key) {
    case 'orders':
      return 'Buyurtmalar';
    case 'customers':
      return 'Mijozlar';
    case 'couriers':
      return 'Kuryerlar';
    case 'books':
      return 'Kitoblar';
    case 'categories':
      return 'Kategoriyalar';
    case 'authors':
      return 'Mualliflar';
    case 'expenses':
      return 'Chiqimlar';
    case 'debts':
      return 'Qarzlar';
    default:
      return key;
  }
}
