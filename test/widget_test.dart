import 'package:flutter_test/flutter_test.dart';
import 'package:min_project_styleme/main.dart';

void main() {
  testWidgets('StyleMe app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StyleMeApp());
    await tester.pump();

    // ตรวจสอบว่ามีข้อความ StyleMe ปรากฏบนหน้าจอ
    expect(find.text('StyleMe'), findsWidgets);
  });
}
