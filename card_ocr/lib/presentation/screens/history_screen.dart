import 'package:card_ocr/core/injection.dart';
import 'package:card_ocr/domain/entities/card_record.dart';
import 'package:card_ocr/presentation/cubits/history/history_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<HistoryCubit>()..load(), child: const _HistoryView());
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  String _mask(String pan) {
    if (pan.length < 10) return '****';
    return '**** **** **** ${pan.substring(pan.length - 4)}';
  }

  String _group(String pan) {
    final buffer = StringBuffer();
    for (var i = 0; i < pan.length; i += 4) {
      if (i > 0) buffer.write(' ');
      buffer.write(pan.substring(i, i + 4 > pan.length ? pan.length : i + 4));
    }
    return buffer.toString();
  }

  String _expiry(CardExpiry e) => '${e.month.toString().padLeft(2, '0')}/${e.year.toString().substring(2)}';

  Future<void> _confirmDelete(BuildContext context, CardRecord card) async {
    final cubit = context.read<HistoryCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('${card.label} - ${_mask(card.pan)}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && card.id != null) {
      await cubit.delete(card.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Cards')),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          return switch (state) {
            HistoryLoading() => const Center(child: CircularProgressIndicator()),
            HistoryError(:final errorMessage) => Center(child: Text(errorMessage)),
            HistoryLoaded(:final cards, :final revealedId) => ListView.separated(
              itemCount: cards.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final card = cards[index];
                final isRevealed = card.id != null && revealedId == card.id;
                return ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text(isRevealed ? _group(card.pan) : _mask(card.pan)),
                  subtitle: Text(
                    '${card.cardholderName} . ${_expiry(card.expiry)} . ${card.network.name.toUpperCase()}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isRevealed ? Icons.visibility_off : Icons.visibility),
                        onPressed: card.id == null ? null : () => context.read<HistoryCubit>().toggleReveal(card.id),
                      ),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(context, card)),
                    ],
                  ),
                );
              },
            ),
          };
        },
      ),
    );
  }
}
