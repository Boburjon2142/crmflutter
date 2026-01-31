class PaginatedResponse<T> {
  PaginatedResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    final items = (json['results'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(fromJsonT)
        .toList();
    return PaginatedResponse(
      count: (json['count'] as num?)?.toInt() ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: items,
    );
  }
}
