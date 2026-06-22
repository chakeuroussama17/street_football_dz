// Pure scoring/eligibility rules for matches. No goal counting — only the
// result matters: win 3, draw 1 each, loss 0. Kept pure so it can be unit
// tested and mirrors what the `team_standings` view computes in SQL.

/// League points awarded to (host, opponent) for a final score.
(int, int) pointsFor(int hostScore, int oppScore) {
  if (hostScore > oppScore) return (3, 0);
  if (hostScore < oppScore) return (0, 3);
  return (1, 1);
}

/// The host may enter / edit the score once the game has ended.
/// (We don't hard-lock at the 3-hour mark, so a late-but-honest score still
/// counts; the 3 hours is the window in which it's expected.)
bool canEnterScore({
  required String status, // matched | completed | ...
  required DateTime endTime,
  required DateTime now,
}) {
  if (status != 'matched' && status != 'completed') return false;
  return now.isAfter(endTime);
}

/// The visiting captain may rate the host once the game has ended — regardless
/// of whether the host entered a score (so a no-show host can still be rated).
bool canRate({
  required String status,
  required DateTime endTime,
  required DateTime now,
  required bool alreadyRated,
}) {
  if (status == 'cancelled' || status == 'open') return false;
  if (alreadyRated) return false;
  return now.isAfter(endTime);
}
