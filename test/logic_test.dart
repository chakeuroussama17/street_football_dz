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
    final end = DateTime(2030, 1, 1, 21, 30);
    test('allowed after the game ends', () {
      expect(
          canEnterScore(
              status: 'matched',
              endTime: end,
              now: end.add(const Duration(minutes: 5))),
          isTrue);
    });
    test('blocked before the game ends', () {
      expect(
          canEnterScore(
              status: 'matched',
              endTime: end,
              now: end.subtract(const Duration(hours: 1))),
          isFalse);
    });
    test('blocked for open/cancelled games', () {
      expect(
          canEnterScore(
              status: 'open',
              endTime: end,
              now: end.add(const Duration(hours: 1))),
          isFalse);
    });
  });

  group('canRate (visitor)', () {
    final end = DateTime(2030, 1, 1, 21, 30);
    test('allowed after end, independent of score', () {
      expect(
          canRate(
              status: 'matched',
              endTime: end,
              now: end.add(const Duration(minutes: 1)),
              alreadyRated: false),
          isTrue);
    });
    test('blocked if already rated', () {
      expect(
          canRate(
              status: 'completed',
              endTime: end,
              now: end.add(const Duration(hours: 4)),
              alreadyRated: true),
          isFalse);
    });
    test('blocked before end', () {
      expect(
          canRate(
              status: 'matched',
              endTime: end,
              now: end.subtract(const Duration(minutes: 1)),
              alreadyRated: false),
          isFalse);
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
