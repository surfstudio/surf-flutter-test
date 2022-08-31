import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin/gherkin.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

void main() {
  group('flutter gherkin tests', () {
    test('contextual world', () {
      final attachments = AttachmentManager();
      final world = ContextualWorld(credentials: {}, profile: {});
      world.setAttachmentManager(attachments);

      world.setContext('key', 'value');
      world.attachText('data');

      expect(attachments.getAttachmentsForContext().first.data, 'data');
      expect('value', world.getContext<String>('key'));
    });
  });
}
