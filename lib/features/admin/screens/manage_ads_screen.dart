import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../l10n/app_localizations.dart';

class ManageAdsScreen extends ConsumerWidget {
  const ManageAdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final ads = ref.watch(adsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.manageAds)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        onPressed: () => _editAd(context, ref, null),
        icon: const Icon(Icons.add_rounded),
        label: Text(t.addAd),
      ),
      body: ads.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green)),
        error: (_, _) => Center(child: Text(t.retry)),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text(t.noAds,
                  style: AppTextStyles.body(AppColors.darkTextSecondary)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final ad = list[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: ad.active
                          ? AppColors.green.withValues(alpha: 0.4)
                          : AppColors.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(ad.title,
                              style: AppTextStyles.title(
                                  AppColors.darkTextPrimary)),
                        ),
                        if (ad.active)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(t.adActive,
                                style:
                                    AppTextStyles.label(AppColors.green)),
                          ),
                      ],
                    ),
                    if ((ad.body ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(ad.body!,
                          style: AppTextStyles.body(
                              AppColors.darkTextSecondary)),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _editAd(context, ref, ad),
                          icon: const Icon(Icons.edit_rounded,
                              size: 16, color: AppColors.green),
                          label: Text(t.edit,
                              style: const TextStyle(color: AppColors.green)),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            await AdminService.deleteAd(ad.id);
                            ref.invalidate(adsProvider);
                            ref.invalidate(activeAdsProvider);
                          },
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 16, color: AppColors.red),
                          label: Text(t.deleteLabel,
                              style: const TextStyle(color: AppColors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editAd(BuildContext context, WidgetRef ref, Ad? ad) async {
    final t = AppLocalizations.of(context);
    final title = TextEditingController(text: ad?.title ?? '');
    final body = TextEditingController(text: ad?.body ?? '');
    final link = TextEditingController(text: ad?.link ?? '');
    var active = ad?.active ?? true;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 18, 20, 18 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ad == null ? t.addAd : t.edit,
                  style: AppTextStyles.headline(AppColors.darkTextPrimary)),
              const SizedBox(height: 16),
              CustomInput(label: t.adTitleField, controller: title),
              const SizedBox(height: 12),
              CustomInput(
                  label: t.adBodyField, controller: body, maxLines: 3),
              const SizedBox(height: 12),
              CustomInput(
                  label: t.adLinkField,
                  controller: link,
                  keyboardType: TextInputType.url),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.green,
                title: Text(t.adActive,
                    style: AppTextStyles.body(AppColors.darkTextPrimary)),
                value: active,
                onChanged: (v) => setLocal(() => active = v),
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: t.save,
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && title.text.trim().isNotEmpty) {
      await AdminService.saveAd(
        id: ad?.id,
        title: title.text.trim(),
        body: body.text.trim().isEmpty ? null : body.text.trim(),
        link: link.text.trim().isEmpty ? null : link.text.trim(),
        active: active,
      );
      ref.invalidate(adsProvider);
      ref.invalidate(activeAdsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.adSaved)));
      }
    }
  }
}
