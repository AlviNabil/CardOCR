import 'package:card_ocr/domain/domain.dart';
import 'package:card_ocr/presentation/cubits/scan_cubit.dart';
import 'package:card_ocr/presentation/widgets/ocr_box_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  String _formatExpiry(CardExpiry expiry) {
    final mm = expiry.month.toString().padLeft(2, '0');
    final yy = (expiry.year % 100).toString().padLeft(2, '0');
    return '$mm/$yy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: BlocConsumer<ScanCubit, ScanState>(
        listener: (context, state) {
          if (state is ScanSaved) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is ScanError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state is! ScanParsed) {
            return const Center(child: CircularProgressIndicator());
          }

          final draft = state.draft;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              AspectRatio(
                aspectRatio: state.ocrResult.imageWidth / state.ocrResult.imageHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(state.imageBytes, fit: BoxFit.cover),
                    CustomPaint(painter: OcrBoxPainter(ocrResult: state.ocrResult)),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Text("Detected Fields", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8.0),
              _FieldRow(label: "Card Number", value: draft.pan.isEmpty ? '-- Not Found --' : draft.pan),
              _FieldRow(
                label: "Card Holder",
                value: draft.cardholderName.isEmpty ? '-- Not Found --' : draft.cardholderName,
              ),
              _FieldRow(label: "Expiry Date", value: _formatExpiry(draft.expiry)),
              _FieldRow(label: "Network", value: draft.network.name),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.read<ScanCubit>().save(draft),
                icon: const Icon(Icons.save),
                label: const Text("Save Card"),
              ),
              const SizedBox(height: 24),
              Text('All recognized lines', style: Theme.of(context).textTheme.titleMedium),
              ...state.ocrResult.lines.map(
                (line) => ListTile(
                  dense: true,
                  title: Text(line.text),
                  trailing: Text('${(line.confidence * 100).toStringAsFixed(0)}%'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;

  const _FieldRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
