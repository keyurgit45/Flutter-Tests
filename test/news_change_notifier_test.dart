import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/models/article.dart';
import 'package:flutter_testing_tutorial/services/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/services/news_service.dart';
import 'package:mocktail/mocktail.dart';

class BadMockNewsService implements NewsService {
  bool isGetArticlesCalled = false;
  @override
  Future<List<Article>> getArticles() async {
    isGetArticlesCalled = true;
    return [
      Article(title: "Test1", content: "Test Content 1"),
      Article(title: "Test2", content: "Test Content 2"),
      Article(title: "Test3", content: "Test Content 3"),
    ];
  }
}

class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut; //system under test
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test('initial values', () {
    expect(sut.articles, []);
    expect(sut.isLoading, false);
  });

  group('get-articles', () {
    final articles = [
      Article(title: "Test1", content: "Test Content 1"),
      Article(title: "Test2", content: "Test Content 2"),
      Article(title: "Test3", content: "Test Content 3"),
    ];
    void getNewsArticles() {
      when(() => mockNewsService.getArticles())
          .thenAnswer((_) async => articles);
    }

    test('gets articles using news service', () async {
      getNewsArticles();
      await sut.getArticles();
      verify(() => mockNewsService.getArticles()).called(1);
    });

    test('indicates loading of data, gets articles', () async {
      getNewsArticles();
      final future = sut.getArticles();
      expect(sut.isLoading, true);
      await future;
      expect(sut.articles, articles);
      expect(sut.isLoading, false);
    });
  });
}
