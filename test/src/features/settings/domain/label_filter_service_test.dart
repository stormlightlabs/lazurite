import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/content_label.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/features/settings/domain/label_filter_service.dart';

void main() {
  late LabelFilterService service;

  ContentLabel createLabel(String val, {String src = 'did:plc:labeler'}) {
    return ContentLabel(src: src, uri: 'at://did:plc:test/post/1', val: val, cts: DateTime.now());
  }

  group('LabelFilterService', () {
    group('with adult content disabled', () {
      setUp(() {
        service = const LabelFilterService(
          adultContentEnabled: false,
          labelPrefs: ContentLabelPrefs.empty,
        );
      });

      test('hides porn label', () {
        final label = createLabel('porn');
        expect(service.getEffectiveBehavior(label), LabelBehavior.hide);
      });

      test('hides sexual label', () {
        final label = createLabel('sexual');
        expect(service.getEffectiveBehavior(label), LabelBehavior.hide);
      });

      test('hides nudity label', () {
        final label = createLabel('nudity');
        expect(service.getEffectiveBehavior(label), LabelBehavior.hide);
      });

      test('does not hide non-adult labels', () {
        final label = createLabel('spam');
        expect(service.getEffectiveBehavior(label), LabelBehavior.inform);
      });
    });

    group('with adult content enabled', () {
      setUp(() {
        service = const LabelFilterService(
          adultContentEnabled: true,
          labelPrefs: ContentLabelPrefs.empty,
        );
      });

      test('uses default behavior for porn', () {
        final label = createLabel('porn');
        expect(service.getEffectiveBehavior(label), LabelBehavior.warn);
      });

      test('uses default behavior for nudity', () {
        final label = createLabel('nudity');
        expect(service.getEffectiveBehavior(label), LabelBehavior.blur);
      });
    });

    group('with user preferences', () {
      test('respects user preference to hide spam', () {
        service = const LabelFilterService(
          adultContentEnabled: true,
          labelPrefs: ContentLabelPrefs(
            items: [ContentLabelPref(label: 'spam', visibility: LabelVisibility.hide)],
          ),
        );

        final label = createLabel('spam');
        expect(service.getEffectiveBehavior(label), LabelBehavior.hide);
      });

      test('respects user preference to ignore porn', () {
        service = const LabelFilterService(
          adultContentEnabled: true,
          labelPrefs: ContentLabelPrefs(
            items: [ContentLabelPref(label: 'porn', visibility: LabelVisibility.ignore)],
          ),
        );

        final label = createLabel('porn');
        expect(service.getEffectiveBehavior(label), LabelBehavior.inform);
      });

      test('respects user preference to warn on impersonation', () {
        service = const LabelFilterService(
          adultContentEnabled: true,
          labelPrefs: ContentLabelPrefs(
            items: [ContentLabelPref(label: 'impersonation', visibility: LabelVisibility.warn)],
          ),
        );

        final label = createLabel('impersonation');
        expect(service.getEffectiveBehavior(label), LabelBehavior.warn);
      });
    });

    group('system labels', () {
      test('always respects system label behavior', () {
        service = const LabelFilterService(
          adultContentEnabled: false,
          labelPrefs: ContentLabelPrefs.empty,
        );

        final label = createLabel('!hide');
        expect(service.getEffectiveBehavior(label), LabelBehavior.hide);
      });

      test('ignores user preferences for system labels', () {
        service = const LabelFilterService(
          adultContentEnabled: true,
          labelPrefs: ContentLabelPrefs(
            items: [ContentLabelPref(label: '!hide', visibility: LabelVisibility.ignore)],
          ),
        );

        final label = createLabel('!hide');
        expect(service.getEffectiveBehavior(label), LabelBehavior.hide);
      });
    });

    group('helper methods', () {
      test('anyLabelHides returns true when any label hides', () {
        service = const LabelFilterService(
          adultContentEnabled: false,
          labelPrefs: ContentLabelPrefs.empty,
        );

        final labels = [createLabel('spam'), createLabel('porn')];
        expect(service.anyLabelHides(labels), isTrue);
      });

      test('anyLabelHides returns false when no labels hide', () {
        service = const LabelFilterService(
          adultContentEnabled: true,
          labelPrefs: ContentLabelPrefs.empty,
        );

        final labels = [createLabel('spam')];
        expect(service.anyLabelHides(labels), isFalse);
      });

      test('anyLabelWarns returns true for warning labels', () {
        service = const LabelFilterService(
          adultContentEnabled: true,
          labelPrefs: ContentLabelPrefs.empty,
        );

        final labels = [createLabel('porn')];
        expect(service.anyLabelWarns(labels), isTrue);
      });
    });
  });
}
