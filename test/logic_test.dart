// Pure business-logic unit tests (no Supabase / network / widgets).

import 'package:flutter_test/flutter_test.dart';
import 'package:street_football_dz/core/utils/match_rules.dart';
import 'package:street_football_dz/core/utils/phone.dart';
import 'package:street_football_dz/core/services/auth_service.dart';
import 'package:street_football_dz/core/services/game_service.dart';

Game _game({
  String status = 'matched',
  int? hostScore,
  int? oppScore,
  DateTime? kickoff,
  int duration = 90,
}) =>
    Game(
      id: 'g',
      hostTeamId: 'h',
      hostCaptainId: 'c',
      format: '5',
      kickoff: kickoff ?? DateTime(2030, 1, 1, 20),
      durationMinutes: duration,
      status: status,
      hostScore: hostScore,
      oppScore: oppScore,
    );

void main() {
  group('pointsFor — win 3 / draw 1 / loss 0', () {
    test('host win', () => expect(pointsFor(3, 1), (3, 0)));
    test('host loss', () => expect(pointsFor(0, 2), (0, 3)));
    test('draw', () => expect(pointsFor(2, 2), (1, 1)));
    test('goal margin is irrelevant', () {
      expect(pointsFor(9, 0), pointsFor(1, 0)); // both a win
    });
  });

  group('canEnterScore (host)', () {
    final kickoff = DateTime(2030, 1, 1, 12);
    // 6 minutes after kickoff → past the 5-minute open delay.
    final afterStart = kickoff.add(const Duration(minutes: 6));
    test('blocked before kick-off + 5 min', () {
      expect(
          canEnterScore(
              status: 'matched',
              kickoff: kickoff,
              scoredAt: null,
              now: kickoff.add(const Duration(minutes: 4))),
          isFalse);
    });
    test('allowed once the match has started (kickoff + 5 min)', () {
      expect(
          canEnterScore(
              status: 'matched',
              kickoff: kickoff,
              scoredAt: null,
              now: afterStart),
          isTrue);
    });
    test('editable within 10 minutes of saving', () {
      expect(
          canEnterScore(
              status: 'completed',
              kickoff: kickoff,
              scoredAt: afterStart.subtract(const Duration(minutes: 5)),
              now: afterStart),
          isTrue);
    });
    test('locked after 10 minutes', () {
      expect(
          canEnterScore(
              status: 'completed',
              kickoff: kickoff,
              scoredAt: afterStart.subtract(const Duration(minutes: 11)),
              now: afterStart),
          isFalse);
    });
    test('blocked for open/cancelled games', () {
      expect(
          canEnterScore(
              status: 'open', kickoff: kickoff, scoredAt: null, now: afterStart),
          isFalse);
      expect(
          canEnterScore(
              status: 'cancelled',
              kickoff: kickoff,
              scoredAt: null,
              now: afterStart),
          isFalse);
    });
    test('minutesUntilScoreOpens counts down and floors at 0', () {
      expect(
          minutesUntilScoreOpens(kickoff, kickoff.add(const Duration(minutes: 6))),
          0);
      expect(minutesUntilScoreOpens(kickoff, kickoff) > 0, isTrue);
    });
    test('editMinutesLeft counts down and floors at 0', () {
      expect(
          editMinutesLeft(
              afterStart.subtract(const Duration(minutes: 11)), afterStart),
          0);
      expect(
          editMinutesLeft(
                  afterStart.subtract(const Duration(minutes: 3)), afterStart) >
              0,
          isTrue);
    });
  });

  group('matchPhase (My Games sections)', () {
    final kickoff = DateTime(2030, 1, 1, 20);
    MatchPhase phase(String status, DateTime now) =>
        matchPhase(status: status, kickoff: kickoff, now: now);

    test('before kick-off → upcoming', () {
      expect(phase('matched', kickoff.subtract(const Duration(hours: 1))),
          MatchPhase.upcoming);
    });
    test('within 4h of kick-off → live', () {
      expect(phase('matched', kickoff.add(const Duration(minutes: 30))),
          MatchPhase.live);
      expect(phase('matched', kickoff.add(const Duration(hours: 3))),
          MatchPhase.live);
    });
    test('past the 4h result window → finished (auto 0–0)', () {
      expect(phase('matched', kickoff.add(const Duration(hours: 4, minutes: 1))),
          MatchPhase.finished);
    });
    test('completed / cancelled are always finished', () {
      expect(phase('completed', kickoff.subtract(const Duration(hours: 1))),
          MatchPhase.finished);
      expect(phase('cancelled', kickoff.add(const Duration(minutes: 30))),
          MatchPhase.finished);
    });
  });

  group('canRate (visitor)', () {
    test('allowed once matched, independent of score', () {
      expect(canRate(status: 'matched', alreadyRated: false), isTrue);
      expect(canRate(status: 'completed', alreadyRated: false), isTrue);
    });
    test('blocked if already rated', () {
      expect(canRate(status: 'completed', alreadyRated: true), isFalse);
    });
    test('blocked before matched', () {
      expect(canRate(status: 'open', alreadyRated: false), isFalse);
    });
  });

  group('Game time helpers', () {
    test('endTime = kickoff + duration', () {
      final g = _game(kickoff: DateTime(2030, 1, 1, 20), duration: 90);
      expect(g.endTime, DateTime(2030, 1, 1, 21, 30));
    });
    test('hasScore only when both scores set', () {
      expect(_game(hostScore: 1, oppScore: 0).hasScore, isTrue);
      expect(_game(hostScore: 1).hasScore, isFalse);
      expect(_game().hasScore, isFalse);
    });
    test('status getters', () {
      expect(_game(status: 'open').isOpen, isTrue);
      expect(_game(status: 'matched').isMatched, isTrue);
      expect(_game(status: 'completed').isCompleted, isTrue);
    });
  });

  group('normalizeDzPhone', () {
    test('accepts local 0-prefixed', () {
      expect(normalizeDzPhone('0555 12 34 56'), '+213555123456');
    });
    test('accepts 9-digit mobile', () {
      expect(normalizeDzPhone('661234567'), '+213661234567');
    });
    test('accepts full international', () {
      expect(normalizeDzPhone('+213771234567'), '+213771234567');
      expect(normalizeDzPhone('213771234567'), '+213771234567');
    });
    test('rejects wrong length', () {
      expect(normalizeDzPhone('12345'), isNull);
    });
    test('rejects non-mobile prefix', () {
      expect(normalizeDzPhone('012345678'), isNull); // starts 1 after strip
    });
    test('prettyDzPhone formats E.164', () {
      expect(prettyDzPhone('+213555123456'), '+213 555 12 34 56');
    });
  });

  group('AppUser.age', () {
    AppUser u(DateTime dob) => AppUser(
        id: 'u', phone: '+213555123456', fullName: 'F', role: 'player',
        dateOfBirth: dob);
    test('whole years from DOB', () {
      final now = DateTime.now();
      expect(u(DateTime(now.year - 22, now.month, now.day)).age, 22);
    });
    test('null DOB → null age', () {
      expect(
          const AppUser(
                  id: 'u', phone: '+213', fullName: 'F', role: 'player')
              .age,
          isNull);
    });
  });
}
