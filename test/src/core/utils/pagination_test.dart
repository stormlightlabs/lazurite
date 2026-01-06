import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/pagination.dart';

void main() {
  group('PaginatedResult', () {
    test('hasMore returns true when cursor is present', () {
      const result = PaginatedResult<String>(items: ['a', 'b', 'c'], cursor: 'next_page');

      expect(result.hasMore, isTrue);
      expect(result.cursor, 'next_page');
      expect(result.items, hasLength(3));
    });

    test('hasMore returns false when cursor is null', () {
      const result = PaginatedResult<String>(items: ['a', 'b'], cursor: null);

      expect(result.hasMore, isFalse);
    });

    test('works with empty items list', () {
      const result = PaginatedResult<int>(items: [], cursor: null);

      expect(result.hasMore, isFalse);
      expect(result.items, isEmpty);
    });

    test('can be const constructed', () {
      const result1 = PaginatedResult<String>(items: [], cursor: 'test');
      const result2 = PaginatedResult<String>(items: [], cursor: 'test');

      expect(identical(result1, result2), isTrue);
    });
  });

  group('CursorPaginationMixin', () {
    late _TestPaginatedNotifier notifier;

    setUp(() {
      notifier = _TestPaginatedNotifier();
    });

    test('initial state has no cursor and hasMore is true', () {
      expect(notifier.cursor, isNull);
      expect(notifier.hasMore, isTrue);
      expect(notifier.canLoadMore, isTrue);
    });

    test('updatePagination sets cursor and hasMore', () {
      const result = PaginatedResult<String>(items: ['a'], cursor: 'page2');
      notifier.updatePagination(result);

      expect(notifier.cursor, 'page2');
      expect(notifier.hasMore, isTrue);
    });

    test('updatePagination with null cursor sets hasMore to false', () {
      const result = PaginatedResult<String>(items: ['a'], cursor: null);
      notifier.updatePagination(result);

      expect(notifier.cursor, isNull);
      expect(notifier.hasMore, isFalse);
      expect(notifier.canLoadMore, isFalse);
    });

    test('resetPagination clears state', () {
      const result = PaginatedResult<String>(items: ['a'], cursor: 'page2');
      notifier.updatePagination(result);
      expect(notifier.cursor, 'page2');

      notifier.resetPagination();

      expect(notifier.cursor, isNull);
      expect(notifier.hasMore, isTrue);
    });

    test('canLoadMore reflects hasMore state', () {
      expect(notifier.canLoadMore, isTrue);

      notifier.updatePagination(const PaginatedResult(items: [], cursor: null));
      expect(notifier.canLoadMore, isFalse);

      notifier.resetPagination();
      expect(notifier.canLoadMore, isTrue);
    });
  });
}

class _TestPaginatedNotifier with CursorPaginationMixin<String> {}
