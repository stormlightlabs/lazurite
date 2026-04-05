import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lazurite/features/tips/cubit/tip_cubit.dart';
import 'package:lazurite/features/tips/cubit/tip_state.dart';
import 'package:lazurite/features/tips/presentation/tip_sheet.dart';
import 'package:mocktail/mocktail.dart';

class MockTipCubit extends MockCubit<TipState> implements TipCubit {}

void main() {
  late MockTipCubit cubit;
  late ProductDetails coffee;
  late ProductDetails latte;

  setUp(() {
    cubit = MockTipCubit();
    coffee = ProductDetails(
      id: 'tip_coffee',
      title: 'Coffee',
      description: 'Small tip',
      price: r'$1.99',
      rawPrice: 1.99,
      currencyCode: 'USD',
      currencySymbol: r'$',
    );
    latte = ProductDetails(
      id: 'tip_latte',
      title: 'Latte',
      description: 'Large tip',
      price: r'$4.99',
      rawPrice: 4.99,
      currencyCode: 'USD',
      currencySymbol: r'$',
    );
    registerFallbackValue(coffee);

    when(() => cubit.loadProducts()).thenAnswer((_) async {});
    when(() => cubit.purchaseTip(any())).thenAnswer((_) async {});
  });

  Widget buildSubject(TipState state) {
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<TipState>.empty(), initialState: state);

    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<TipCubit>.value(value: cubit, child: const TipSheet()),
      ),
    );
  }

  testWidgets('renders loading skeletons while products load', (tester) async {
    await tester.pumpWidget(buildSubject(const TipState(storeStatus: TipStoreStatus.loading)));

    expect(find.byKey(const Key('tip_skeleton_0')), findsOneWidget);
    expect(find.byKey(const Key('tip_skeleton_1')), findsOneWidget);
  });

  testWidgets('renders products with localized prices and ads note', (tester) async {
    await tester.pumpWidget(
      buildSubject(TipState(storeStatus: TipStoreStatus.available, products: [latte, coffee], adsRemoved: false)),
    );

    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Latte'), findsOneWidget);
    expect(find.text(r'$1.99'), findsOneWidget);
    expect(find.text(r'$4.99'), findsOneWidget);
    expect(find.text('Your first tip removes ads forever.'), findsOneWidget);
  });

  testWidgets('renders thank-you banner when ads are already removed', (tester) async {
    await tester.pumpWidget(
      buildSubject(TipState(storeStatus: TipStoreStatus.available, products: [coffee, latte], adsRemoved: true)),
    );

    expect(find.text('Ads removed — thanks for your support!'), findsOneWidget);
    expect(find.text('Your first tip removes ads forever.'), findsNothing);
  });

  testWidgets('renders store unavailable state and retries', (tester) async {
    await tester.pumpWidget(buildSubject(const TipState(storeStatus: TipStoreStatus.unavailable)));

    expect(find.text('Store unavailable'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(() => cubit.loadProducts()).called(1);
  });

  testWidgets('shows pending spinner and disables other purchases', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        TipState(
          storeStatus: TipStoreStatus.available,
          products: [coffee, latte],
          purchaseStatus: TipPurchaseStatus.pending,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    expect(find.byType(FilledButton), findsNothing);
  });
}
