// Pure scoring/eligibility rules for matches. No goal counting — only the
// result matters: win 3, draw 1 each, loss 0. Kept pure so it can be unit
// tested and mirrors what the `team_standings` view computes in SQL.

/// Score entry opens this long after kick-off — the match needs to have started
/// before anyone records a result.
const scoreOpensDelay = Duration(minutes: 5);

/// After submitting a score, the host can still edit it for this long; after
/// that it's locked forever.
const scoreEditWindow = Duration(minutes: 10);

/// The first moment the host may record the result: [scoreOpensDelay] past
/// kick-off.
DateTime scoreOpensAt(DateTime kickoff) => kickoff.add(scoreOpensDelay);

/// Where a match sits on the timeline — drives the My Games sections.
enum MatchPhase { upcoming, live, finished }

/// Classifies a game so the UI can group it under upcoming / live / finished.
/// Completed and cancelled games are always finished; otherwise it's by time:
/// before kick-off → upcoming, during the match window → live, after → finished.
MatchPhase matchPhase({
  required String status,
  required DateTime kickoff,
  required DateTime endTime,
  required DateTime now,
}) {
  if (status == 'completed' || status == 'cancelled') return MatchPhase.finished;
  if (now.isBefore(kickoff)) return MatchPhase.upcoming;
  if (!now.isAfter(endTime)) return MatchPhase.live; // kickoff ≤ now ≤ endTime
  return MatchPhase.finished; // played out, awaiting the result
}

/// League points awarded to (host, opponent) for a final score.
(int, int) pointsFor(int hostScore, int oppScore) {
  if (hostScore > oppScore) return (3, 0);
  if (hostScore < oppScore) return (0, 3);
  return (1, 1);
}

/// The host may enter the score only once the match has started
/// ([scoreOpensDelay] after kick-off), and may keep editing it for
/// [scoreEditWindow] after the first submission — then it's final.
bool canEnterScore({
  required String status,
  required DateTime kickoff,
  DateTime? scoredAt,
  required DateTime now,
}) {
  if (status == 'matched') {
    return !now.isBefore(scoreOpensAt(kickoff)); // opens at kickoff + delay
  }
  if (status == 'completed') {
    if (scoredAt == null) return true;
    return now.isBefore(scoredAt.add(scoreEditWindow));
  }
  return false;
}

/// Whole minutes until score entry opens (0 once open). Lets the host see how
/// long before they can record the result.
int minutesUntilScoreOpens(DateTime kickoff, DateTime now) {
  final left = scoreOpensAt(kickoff).difference(now);
  return left.isNegative ? 0 : left.inMinutes + 1;
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
