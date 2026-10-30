import 'package:flutter/material.dart';

import '../../../core/state/campus_state.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/dates.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final DateTime? selected;
  final ValueChanged<DateTime?> onSelected;

  @override
  Widget build(BuildContext context) {
    final state = CampusScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final aujourdhui = Dates.jour(DateTime.now());
    final cardColor = Theme.of(context).cardTheme.color;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s4),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Builder(
              builder: (context) {
                final jour = aujourdhui.add(Duration(days: i));
                final nombre = state.taches
                    .where(
                      (t) => !t.terminee && Dates.memeJour(t.echeance, jour),
                    )
                    .length;
                final choisi = selected;
                final actif = choisi != null && Dates.memeJour(choisi, jour);
                final fond = actif ? scheme.primary : cardColor;
                final encre = actif ? scheme.onPrimary : scheme.onSurface;
                return Padding(
                  padding: const EdgeInsets.only(right: AppTokens.s2),
                  child: Semantics(
                    button: true,
                    selected: actif,
                    label:
                        '${Dates.jourComplet(jour)}, $nombre échéance${nombre > 1 ? 's' : ''}',
                    excludeSemantics: true,
                    child: Material(
                      color: fond,
                      borderRadius: BorderRadius.circular(AppTokens.radiusM),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTokens.radiusM),
                        onTap: () => onSelected(actif ? null : jour),
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 54),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTokens.s3,
                            horizontal: AppTokens.s2,
                          ),
                          decoration: i == 0 && !actif
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppTokens.radiusM,
                                  ),
                                  border: Border.all(
                                    color: scheme.primary,
                                    width: 1.5,
                                  ),
                                )
                              : null,
                          child: Column(
                            children: [
                              Text(
                                Dates.capitaliser(
                                  Dates.jourCourt(jour).replaceAll('.', ''),
                                ),
                                style: text.labelMedium?.copyWith(
                                  color: actif
                                      ? encre
                                      : scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${jour.day}',
                                style: text.titleLarge?.copyWith(color: encre),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: nombre == 0
                                      ? Colors.transparent
                                      : actif
                                      ? scheme.onPrimary
                                      : scheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
