import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/models/article.dart';
import 'package:flutter_testing_tutorial/screens/article_page.dart';
import 'package:flutter_testing_tutorial/screens/news_page.dart';
import 'package:flutter_testing_tutorial/services/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/services/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articles = [
    Article(title: "Test1", content: "Test Content 1"),
    Article(title: "Test2", content: "Test Content 2"),
    Article(title: "Test3", content: "Test Content 3"),
  ];
  void getNewsArticles() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async => articles);
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: NewsPage(),
      ),
    );
  }

  testWidgets('tapping on the first article and opens article page',
      (WidgetTester tester) async {
    getNewsArticles();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await tester.tap(find.text('Test Content 1'));
    await tester.pumpAndSettle();

    expect(find.byType(NewsPage), findsNothing);
    expect(find.byType(ArticlePage), findsOneWidget);
  });
}
