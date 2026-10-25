/// One page of a server-paginated list.
class Paginated<T> {
  const Paginated({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;

  int get totalPages => total == 0 ? 1 : ((total + limit - 1) ~/ limit);
  bool get hasPrevious => page > 1;
  bool get hasNext => page < totalPages;

  /// 1-based index of the first row on this page (0 when empty).
  int get firstIndex => total == 0 ? 0 : (page - 1) * limit + 1;
  int get lastIndex => total == 0 ? 0 : firstIndex + items.length - 1;

  Paginated<T> mapItems(List<T> Function(List<T>) f) =>
      Paginated(items: f(items), page: page, limit: limit, total: total);
}
