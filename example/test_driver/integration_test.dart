import 'package:integration_test/integration_test_driver.dart' as integration_test_driver;
import 'package:surf_flutter_test/surf_flutter_driver_test.dart';

Future<void> main() async {
  integration_test_driver.testOutputsDirectory = 'integration_test/gherkin/reports';

  await androidScreenDuration();

  return fixedIntegrationDriver(
    timeout: const Duration(minutes: 120),
  );
}
