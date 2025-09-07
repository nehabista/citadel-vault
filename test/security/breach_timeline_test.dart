import 'package:flutter_test/flutter_test.dart';

import 'package:citadel_password_manager/features/security/data/models/breach_record.dart';
import 'package:citadel_password_manager/features/security/presentation/pages/breach_timeline_page.dart';

void main() {
  group('buildTimeline', () {
    test(
        'merging breach dates with password history timestamps produces correct chronological order',
        () {
      final breaches = [
        BreachRecord(
          name: 'BreachB',
          title: 'Breach B',
          domain: 'b.com',
          breachDate: DateTime(2023, 6, 1),
          dataClasses: ['Email'],
          verified: true,
          isSensitive: false,
        ),
        BreachRecord(
          name: 'BreachA',
          title: 'Breach A',
          domain: 'a.com',
          breachDate: DateTime(2022, 1, 15),
          dataClasses: ['Passwords'],
          verified: true,
          isSensitive: false,
        ),
      ];

      final passwordChangeDates = [
        DateTime(2022, 3, 1), // After Breach A
        DateTime(2023, 8, 15), // After Breach B
      ];

      final timeline = buildTimeline(
        breaches: breaches,
        passwordChangeDates: passwordChangeDates,
      );

      expect(timeline.length, 4);
      // Chronological order
      expect(timeline[0].title, 'Breach A');
      expect(timeline[0].type, TimelineEventType.breach);
      expect(timeline[0].date, DateTime(2022, 1, 15));

      expect(timeline[1].title, 'Password changed');
      expect(timeline[1].type, TimelineEventType.passwordChange);
      expect(timeline[1].date, DateTime(2022, 3, 1));

      expect(timeline[2].title, 'Breach B');
      expect(timeline[2].type, TimelineEventType.breach);
      expect(timeline[2].date, DateTime(2023, 6, 1));

      expect(timeline[3].title, 'Password changed');
      expect(timeline[3].type, TimelineEventType.passwordChange);
      expect(timeline[3].date, DateTime(2023, 8, 15));
    });

    test(
        'gap duration calculation between breach and next password change is correct',
        () {
      final breachDate = DateTime(2023, 1, 1);

      // 3 months gap
      final changeDate3m = DateTime(2023, 4, 1);
      expect(
        exposureGapLabel(breachDate, changeDate3m),
        '3 months exposed',
      );

      // 1 year 2 months gap
      final changeDate1y2m = DateTime(2024, 3, 1);
      expect(
        exposureGapLabel(breachDate, changeDate1y2m),
        '1 yr 2 mo exposed',
      );

      // Same day
      expect(
        exposureGapLabel(breachDate, breachDate),
        'Changed same day',
      );

      // 15 days
      final changeDate15d = DateTime(2023, 1, 16);
      expect(
        exposureGapLabel(breachDate, changeDate15d),
        '15 days exposed',
      );

      // 1 day
      final changeDate1d = DateTime(2023, 1, 2);
      expect(
        exposureGapLabel(breachDate, changeDate1d),
        '1 day exposed',
      );
    });

    test('empty breach list returns password-change-only timeline', () {
      final passwordChangeDates = [
        DateTime(2022, 6, 1),
        DateTime(2023, 1, 1),
      ];

      final timeline = buildTimeline(
        breaches: [],
        passwordChangeDates: passwordChangeDates,
      );

      expect(timeline.length, 2);
      expect(
        timeline.every((e) => e.type == TimelineEventType.passwordChange),
        isTrue,
      );
      // Chronological order
      expect(timeline[0].date.isBefore(timeline[1].date), isTrue);
    });

    test('empty breaches and empty password history returns empty timeline',
        () {
      final timeline = buildTimeline(
        breaches: [],
        passwordChangeDates: [],
      );

      expect(timeline, isEmpty);
    });
  });
}
