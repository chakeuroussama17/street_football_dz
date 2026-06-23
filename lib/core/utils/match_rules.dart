// Pure scoring/eligibility rules for matches. No goal counting — only the
// result matters: win 3, draw 1 each, loss 0. Kept pure so it can be unit
// tested and mirrors what the `team_standings` view computes in SQL.

/// League points awarded to (host, opponent) for a final score.
(int, int) pointsFor(int hostScore, int oppScore) {
  if (hostScore > oppScore) return (3, 0);
  if (hostScore < oppScore) return (0, 3);
  return (1, 1);
}

/// The host may enter / edit the score once the game is matched (an opponent
/// was picked). We don't force it to wait for the scheduled end time — handy
/// for short games and for testing.
bool canEnterScore(String status) =>
    status == 'matched' || status == 'completed';

/// The visiting captain may rate the host once the game is matched and they
/// haven't rated yet (rating is independent of whether a score was entered, so
/// a no-show host can still be rated).
bool canRate({required String status, required bool alreadyRated}) {
  if (alreadyRated) return false;
  return status == 'matched' || status == 'completed';
}
