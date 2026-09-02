import 'package:card_ocr/domain/domain.dart';
import 'package:card_ocr/presentation/cubits/card_form/card_form_cubit.dart';
import 'package:card_ocr/presentation/cubits/scan/scan_cubit.dart';
import 'package:card_ocr/presentation/widgets/ocr_box_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

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
          return BlocProvider(
            create: (_) => CardFormCubit(draft: state.draft),
            child: _ResultView(parsed: state),
          );
        },
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final ScanParsed parsed;

  const _ResultView({required this.parsed});

  @override
  Widget build(BuildContext context) {
    final form = context.read<CardFormCubit>();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        AspectRatio(
          aspectRatio: parsed.ocrResult.imageWidth / parsed.ocrResult.imageHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(parsed.imageBytes, fit: BoxFit.cover),
              CustomPaint(painter: OcrBoxPainter(ocrResult: parsed.ocrResult)),
            ],
          ),
        ),
        const SizedBox(height: 24.0),
        Text('Detected Fields', style: Theme.of(context).textTheme.titleMedium),
        Text('Correct anything the scan got wrong before saving.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12.0),
        TextField(
          controller: form.labelController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Label', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12.0),
        TextField(
          controller: form.nameController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Card Holder', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12.0),
        BlocBuilder<CardFormCubit, CardFormState>(
          builder: (context, formState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: form.panController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    border: const OutlineInputBorder(),
                    errorText: formState.isPanValid ? null : 'Not a valid card number (checksum failed)',
                    suffixText: formState.network == CardNetwork.unknown ? null : formState.network.name,
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: form.expiryController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'Expiry Date (MM/YY)',
                    border: const OutlineInputBorder(),
                    errorText: formState.isExpiryValid ? null : 'Use MM/YY, month 01-12',
                  ),
                ),
                const SizedBox(height: 24.0),
                FilledButton.icon(
                  onPressed: formState.canSave ? () => context.read<ScanCubit>().save(form.buildRecord()) : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Card'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24.0),
        Text('All recognized lines', style: Theme.of(context).textTheme.titleMedium),
        ...parsed.ocrResult.lines.map(
          (line) => ListTile(
            dense: true,
            title: Text(line.text),
            trailing: Text('${(line.confidence * 100).toStringAsFixed(0)}%'),
          ),
        ),
      ],
    );
  }
}
