import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/algeria.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/team_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/team_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../l10n/app_localizations.dart';

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final myTeam = ref.watch(myTeamProvider);

    return SafeArea(
      bottom: false,
      child: myTeam.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green)),
        error: (_, _) => Center(child: Text(t.retry)),
        data: (team) {
          if (team == null) return _noTeam(context, t);
          return _TeamBody(team: team);
        },
      ),
    );
  }

  Widget _noTeam(BuildContext context, AppLocalizations t) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.group_off_rounded,
                  size: 56, color: AppColors.darkTextMuted),
              const SizedBox(height: 12),
              Text(t.noTeamYet,
                  style: AppTextStyles.body(AppColors.darkTextSecondary)),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: CustomButton(
                  label: t.getStarted,
                  onPressed: () => context.goNamed('role-choice'),
                ),
              ),
            ],
          ),
        ),
      );
}

class _TeamBody extends ConsumerWidget {
  final Team team;
  const _TeamBody({required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final myId = ref.watch(currentUserProvider).valueOrNull?.id;
    final isCaptain = myId != null && team.captainId == myId;
    final standing = ref.watch(teamStandingProvider(team.id)).valueOrNull;
    final roster = ref.watch(rosterProvider(team.id));
    final localeCode = Localizations.localeOf(context).languageCode;

    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () async {
        ref.invalidate(myTeamProvider);
        ref.invalidate(myTeamsProvider);
        ref.invalidate(teamStandingProvider(team.id));
        ref.invalidate(rosterProvider(team.id));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // Team switcher (a player can belong to many teams).
          _TeamSwitcher(activeId: team.id),

          Row(
            children: [
              TeamAvatar(name: team.name, imageUrl: team.logoUrl, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name,
                        style:
                            AppTextStyles.headline(AppColors.darkTextPrimary)),
                    if ((team.city ?? '').isNotEmpty)
                      Text(Algeria.labelFor(team.city, localeCode),
                          style: AppTextStyles.body(
                              AppColors.darkTextSecondary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _chip('${t.rankHash}${standing?.rank ?? '-'}',
                            AppColors.gold),
                        const SizedBox(width: 6),
                        _chip('${standing?.points ?? 0} ${t.pts}',
                            AppColors.green),
                        const SizedBox(width: 6),
                        if ((standing?.ratingCount ?? 0) > 0)
                          StarRating(value: standing!.ratingAvg, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Team code card (everyone can see + share it).
          _codeCard(context, t),

          const SizedBox(height: 16),
          if (isCaptain)
            CustomButton(
              label: t.editTeam,
              icon: Icons.edit_rounded,
              variant: ButtonVariant.ghost,
              onPressed: () =>
                  context.pushNamed('team-edit', pathParameters: {'id': team.id}),
            ),

          const SizedBox(height: 24),
          Text(t.rosterTitle,
              style: AppTextStyles.title(AppColors.darkTextPrimary)),
          const SizedBox(height: 8),
          roster.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.green)),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (members) => Column(
              children: [
                for (final m in members)
                  _memberTile(
                    t,
                    m,
                    // Captains can remove anyone except themselves / the captain.
                    canRemove: isCaptain && m.role != 'captain',
                    onRemove: () => _confirmRemove(context, ref, t, m),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          CustomButton(
            label: t.joinAnotherTeam,
            icon: Icons.group_add_rounded,
            variant: ButtonVariant.ghost,
            onPressed: () => context.pushNamed('join-team'),
          ),

          const SizedBox(height: 8),
          if (!isCaptain)
            TextButton.icon(
              onPressed: () => _confirmLeave(context, ref, t),
              icon: const Icon(Icons.logout_rounded, color: AppColors.red),
              label: Text(t.leaveTeam,
                  style: const TextStyle(color: AppColors.red)),
            ),
        ],
      ),
    );
  }

  Widget _codeCard(BuildContext context, AppLocalizations t) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.yourTeamCode,
                style: AppTextStyles.label(AppColors.darkTextSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(team.teamCode,
                      style: AppTextStyles.display(AppColors.green)
                          .copyWith(letterSpacing: 6, fontSize: 28)),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: team.teamCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.codeCopied)));
                  },
                  icon: const Icon(Icons.copy_rounded, color: AppColors.green),
                ),
                IconButton(
                  onPressed: () => Share.share(
                      '${t.appName}\n${team.name} — ${t.teamCodeLabel}: ${team.teamCode}'),
                  icon: const Icon(Icons.ios_share_rounded,
                      color: AppColors.green),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: AppTextStyles.label(color)),
      );

  Widget _memberTile(
    AppLocalizations t,
    TeamMember m, {
    required bool canRemove,
    required VoidCallback onRemove,
  }) {
    final cap = m.role == 'captain';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          TeamAvatar(name: m.fullName, imageUrl: m.avatarUrl, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(m.fullName,
                style: AppTextStyles.body(AppColors.darkTextPrimary)),
          ),
          if (m.age != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('${m.age}',
                  style: AppTextStyles.label(AppColors.darkTextMuted)),
            ),
          if (cap)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Text(t.captainTag, style: AppTextStyles.label(AppColors.green)),
            ),
          if (canRemove)
            IconButton(
              tooltip: t.removeMember,
              onPressed: onRemove,
              icon: const Icon(Icons.person_remove_rounded,
                  color: AppColors.red, size: 20),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref,
      AppLocalizations t, TeamMember m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(t.removeMember,
            style: AppTextStyles.title(AppColors.darkTextPrimary)),
        content: Text(t.removeMemberConfirm(m.fullName),
            style: AppTextStyles.body(AppColors.darkTextSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.removeMember,
                  style: const TextStyle(color: AppColors.red))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await TeamService.removeMember(team.id, m.id);
      ref.invalidate(rosterProvider(team.id));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.memberRemoved)));
    } on TeamFailure catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.red));
    }
  }

  Future<void> _confirmLeave(
      BuildContext context, WidgetRef ref, AppLocalizations t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(t.leaveTeamConfirm,
            style: AppTextStyles.title(AppColors.darkTextPrimary)),
        content: Text(t.leaveTeamBody,
            style: AppTextStyles.body(AppColors.darkTextSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.leave,
                  style: const TextStyle(color: AppColors.red))),
        ],
      ),
    );
    if (ok != true) return;
    await TeamService.leaveTeam(team.id);
    final me = await AuthService.currentAppUser();
    if (!context.mounted) return;
    applySessionStateW(ref, me);
    ref.invalidate(myTeamProvider);
    ref.invalidate(myTeamsProvider);
    // Still in another team? Stay on My Team. Otherwise onboard a new one.
    if (me?.teamId == null) {
      ref.read(onboardingDraftProvider.notifier).state = me == null
          ? null
          : OnboardingDraft(
              fullName: me.fullName,
              dateOfBirth: me.dateOfBirth ?? DateTime(2000),
              city: me.city ?? '',
              phone: me.phone,
            );
      context.goNamed('role-choice');
    }
  }
}

/// Horizontal chips of every team the user belongs to; tap to switch active.
class _TeamSwitcher extends ConsumerWidget {
  final String activeId;
  const _TeamSwitcher({required this.activeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final teams = ref.watch(myTeamsProvider).valueOrNull ?? const [];
    // Nothing to switch between — hide the strip.
    if (teams.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.yourTeams,
              style: AppTextStyles.label(AppColors.darkTextSecondary)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final m in teams)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _teamChip(context, ref, m),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamChip(BuildContext context, WidgetRef ref, TeamMembership m) {
    final active = m.team.id == activeId;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: active ? null : () => _switch(context, ref, m.team.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppColors.green.withValues(alpha: 0.18)
              : AppColors.darkCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active ? AppColors.green : AppColors.darkBorder,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TeamAvatar(name: m.team.name, imageUrl: m.team.logoUrl, size: 24),
            const SizedBox(width: 8),
            Text(m.team.name,
                style: AppTextStyles.label(
                    active ? AppColors.green : AppColors.darkTextPrimary)),
            if (m.isCaptain) ...[
              const SizedBox(width: 4),
              const Icon(Icons.shield_rounded,
                  size: 14, color: AppColors.gold),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _switch(
      BuildContext context, WidgetRef ref, String teamId) async {
    await TeamService.setActiveTeam(teamId);
    final me = await AuthService.currentAppUser();
    if (!context.mounted) return;
    applySessionStateW(ref, me); // updates myTeamIdProvider → refetches
    ref.invalidate(myTeamProvider);
    ref.invalidate(myTeamsProvider);
  }
}
