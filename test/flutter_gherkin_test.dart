import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin/gherkin.dart';
import 'package:surf_flutter_test/surf_flutter_test.dart';

class _StubUser extends User {}

Map<String, _StubUser> _stubCredentials = {'stub': _StubUser()};

void main() {
  group('flutter gherkin tests', () {
    test('contextual world', () {
      final attachments = AttachmentManager();
      final world = ContextualWorld(_stubCredentials)
        ..setAttachmentManager(attachments)
        ..setContext('key', 'value')
        ..attachText('data');

      expect(attachments.getAttachmentsForContext().first.data, 'data');
      expect('value', world.getContext<String>('key'));
    });
  });
}
