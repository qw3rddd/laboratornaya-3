import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab3_navigation/main.dart';

void main() {
  test('Простые проценты и дробный срок', () {
    const input = InterestInput(capital: 10000, years: 2, rate: 10);
    expect(input.interest, 2000);
    expect(input.total, 12000);
    expect(
      const InterestInput(capital: 10000, years: 0.5, rate: 10).interest,
      500,
    );
    expect(const InterestInput(capital: 10000, years: 2, rate: 0).total, 10000);
  });
  test('Проверка чисел', () {
    expect(parseNumber(' 0,5 '), 0.5);
    for (final text in ['', 'abc', 'NaN', 'Infinity', '-1', '0']) {
      expect(validateNumber(text, positive: true), isNotNull);
    }
    expect(validateNumber('0', positive: false), isNull);
    expect(validateNumber('1e309', positive: true), isNotNull);
  });
  testWidgets('Валидация формы, согласие, результат и возврат', (tester) async {
    await tester.pumpWidget(const Lab3App());
    final button = find.text('Рассчитать');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Заполните поле'), findsNWidgets(3));
    expect(
      find.text('Подтвердите согласие на обработку данных'),
      findsOneWidget,
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '10000');
    await tester.enterText(fields.at(1), '2');
    await tester.enterText(fields.at(2), '10');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(ResultPage), findsNothing);
    await tester.tap(find.byType(Checkbox));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('12000,00 ₽'), findsOneWidget);
    expect(find.text('Начисленные проценты: 2000,00 ₽'), findsOneWidget);
    final back = find.text('Изменить данные');
    await tester.ensureVisible(back);
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.byType(InputPage), findsOneWidget);
    expect(find.text('10000'), findsOneWidget);
  });
  testWidgets('Переполнение расчёта не открывает экран результата', (
    tester,
  ) async {
    await tester.pumpWidget(const Lab3App());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '1e308');
    await tester.enterText(fields.at(1), '100');
    await tester.enterText(fields.at(2), '100');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.ensureVisible(find.text('Рассчитать'));
    await tester.tap(find.text('Рассчитать'));
    await tester.pumpAndSettle();
    expect(find.byType(ResultPage), findsNothing);
    expect(
      find.text('Слишком большие значения. Уменьшите исходные данные.'),
      findsOneWidget,
    );
  });
}
