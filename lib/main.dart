import 'package:flutter/material.dart';

void main() => runApp(const Lab3App());
const studentName = 'Шмаков Владислав Ярославович';

double? parseNumber(String text) {
  final number = double.tryParse(text.trim().replaceAll(',', '.'));
  return number != null && number.isFinite ? number : null;
}

String? validateNumber(String? text, {required bool positive}) {
  if (text == null || text.trim().isEmpty) return 'Заполните поле';
  final value = parseNumber(text);
  if (value == null) return 'Введите конечное число';
  if (positive ? value <= 0 : value < 0) {
    return positive
        ? 'Значение должно быть больше нуля'
        : 'Значение не может быть отрицательным';
  }
  return null;
}

class InterestInput {
  const InterestInput({
    required this.capital,
    required this.years,
    required this.rate,
  });
  final double capital;
  final double years;
  final double rate;
  // Простые проценты без капитализации.
  double get interest => capital * (rate / 100) * years;
  double get total => capital + interest;
}

class Lab3App extends StatelessWidget {
  const Lab3App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ЛР 3 — Простые проценты',
    theme: ThemeData(fontFamily: 'LabRoboto',
      useMaterial3: true,
      colorSchemeSeed: Colors.teal,
      scaffoldBackgroundColor: const Color(0xFFF5F8F7),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: const InputPage(),
  );
}

class InputPage extends StatefulWidget {
  const InputPage({super.key});
  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  final _capital = TextEditingController();
  final _years = TextEditingController();
  final _rate = TextEditingController();
  bool _consent = false;
  String? _calculationError;
  @override
  void dispose() {
    _capital.dispose();
    _years.dispose();
    _rate.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() => _calculationError = null);
    if (!_formKey.currentState!.validate()) return;
    final input = InterestInput(
      capital: parseNumber(_capital.text)!,
      years: parseNumber(_years.text)!,
      rate: parseNumber(_rate.text)!,
    );
    if (!input.interest.isFinite || !input.total.isFinite) {
      setState(
        () => _calculationError =
            'Слишком большие значения. Уменьшите исходные данные.',
      );
      return;
    }
    FocusScope.of(context).unfocus();
    // Передаём исходные данные на второй экран через конструктор.
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ResultPage(input: input)),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    bool positive,
    String hint,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: (value) => validateNumber(value, positive: positive),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(studentName, maxLines: 2),
      toolbarHeight: 80,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Лабораторная работа 3 · Вариант 3'),
                  const SizedBox(height: 12),
                  const Text(
                    'Простые проценты',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Доход и итоговая сумма без капитализации. Ставка — годовая, срок — в годах.',
                  ),
                  const SizedBox(height: 28),
                  _field(
                    'Исходный капитал, ₽',
                    _capital,
                    true,
                    'Например, 10000',
                  ),
                  _field('Срок, лет', _years, true, 'Например, 2 или 0,5'),
                  _field('Годовая ставка, %', _rate, false, 'Например, 10'),
                  FormField<bool>(
                    initialValue: false,
                    validator: (_) => _consent
                        ? null
                        : 'Подтвердите согласие на обработку данных',
                    builder: (state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Согласен на обработку данных'),
                          subtitle: const Text(
                            'Расчёт выполняется на устройстве.',
                          ),
                          value: _consent,
                          onChanged: (value) {
                            setState(() => _consent = value ?? false);
                            state.didChange(_consent);
                          },
                        ),
                        if (state.hasError)
                          Text(
                            state.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_calculationError != null)
                    Text(
                      _calculationError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Padding(
                      padding: EdgeInsets.all(14),
                      child: Text('Рассчитать'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

String amount(double value) =>
    (value.abs() >= 1e12
            ? value.toStringAsExponential(4)
            : value.toStringAsFixed(2))
        .replaceAll('.', ',');

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.input});
  final InterestInput input;
  @override
  Widget build(BuildContext context) {
    // Рассчитываем результат из параметров, переданных первым экраном.
    final interest = input.interest;
    final total = input.total;
    return Scaffold(
      appBar: AppBar(
        title: const Text(studentName, maxLines: 2),
        toolbarHeight: 80,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Результат расчёта',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text('Итоговая сумма', style: TextStyle(fontSize: 18)),
                  Text(
                    '${amount(total)} ₽',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Начисленные проценты: ${amount(interest)} ₽',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 28),
                  Text('Исходный капитал: ${amount(input.capital)} ₽'),
                  const SizedBox(height: 12),
                  Text('Срок: ${amount(input.years)} лет'),
                  const SizedBox(height: 12),
                  Text('Годовая ставка: ${amount(input.rate)} %'),
                  const SizedBox(height: 28),
                  const Text(
                    'Формула простых процентов',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'I = P × r × t / 100\nS = P + I',
                    style: TextStyle(fontSize: 20, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'P — капитал, r — годовая ставка в процентах, t — срок в годах, I — доход, S — итоговая сумма.',
                  ),
                  const SizedBox(height: 28),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Изменить данные'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

