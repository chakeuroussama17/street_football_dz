// Pure scoring/eligibility rules for matches. No goal counting — only the
// result matters: win 3, draw 1 each, loss 0. Kept pure so it can be unit
// tested and mirrors what the `team_standings` view computes in SQL.

/// After submitting a score, the host can still edit it for this long; after
/// that it's locked forever.
const scoreEditWindow = Duration(minutes: 10);

/// League points awarded to (host, opponent) for a final score.
(int, int) pointsFor(int hostScore, int oppScore) {
  if (hostScore > oppScore) return (3, 0);
  if (hostScore < oppScore) return (0, 3);
  return (1, 1);
}

/// The host may enter the score once matched, and may keep editing it for
/// [scoreEditWindow] after the first submission — then it's final.
bool canEnterScore({
  required String status,
  DateTime? scoredAt,
  required DateTime now,
}) {
  if (status == 'matched') return true; // not scored yet
  if (status == 'completed') {
    if (scoredAt == null) return true;
    return now.isBefore(scoredAt.add(scoreEditWindow));
  }
  return false;
}

/// Whole minutes left in the edit window (0 once locked).
int editMinutesLeft(DateTime? scoredAt, DateTime now) {
  if (scoredAt == null) return scoreEditWindow.inMinutes;
  final left = scoredAt.add(scoreEditWindow).difference(now);
  return left.isNegative ? 0 : left.inMinutes + 1;
}

/// The visiting captain may rate the host once matched and they haven't rated
/// yet (rating is independent of the score, so a no-show host can still be rated).
bool canRate({required String status, required bool alreadyRated}) {
  if (alreadyRated) return false;
  return status == 'matched' || status == 'completed';
}
