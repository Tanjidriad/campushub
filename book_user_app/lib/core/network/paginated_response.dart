class PaginatedResponse<T> {
  final List<T> items;
  final int totalItems;
  final int currentPage;
  final int totalPages;

  PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
  });
}
