import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/main.dart';
import 'package:flutter_testing_tutorial/models/article.dart';
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

  void getNewsArticlesAfter2Seconds() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 2));
      return articles;
    });
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

  testWidgets('widget-test : title is displayed', (WidgetTester tester) async {
    getNewsArticles();
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text("News"), findsOneWidget);
  });

  testWidgets('widget-test : loading is displayed',
      (WidgetTester tester) async {
    getNewsArticlesAfter2Seconds();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('widget-test : articles are displayed',
      (WidgetTester tester) async {
    getNewsArticles();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    for (final article in articles) {
      expect(find.text(article.title), findsOneWidget);
      expect(find.text(article.content), findsOneWidget);
    }
  });
}
