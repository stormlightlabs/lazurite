import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/splash/presentation/splash_screen.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('renders LoadingView', (tester) async {
      await tester.pumpApp(const SplashScreen());
      expect(find.byType(LoadingView), findsOneWidget);
    });
  });
}
