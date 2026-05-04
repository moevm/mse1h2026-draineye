import 'dart:io' if (dart.library.html) 'package:drain_eye/stubs/dart_io_stub.dart';

import 'package:drain_eye/core/confidence_accent_color.dart';
import 'package:drain_eye/core/constants.dart';
import 'package:drain_eye/core/damage_type_labels.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/presentation/blocs/new_inspection/new_inspection_bloc.dart';
import 'package:drain_eye/presentation/screens/user/low_confidence_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _teal = Color(0xFF0D9488);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);

// экран результата модели (UC-8)
class ModelResultScreen extends StatelessWidget {
  final List<String>? photoPaths;
  final String? photoPath;
  final ModelInferenceResult? modelResult;
  final int userId;

  const ModelResultScreen({
    super.key,
    this.photoPaths,
    this.photoPath,
    this.modelResult,
    this.userId = kStubInspectionUserId,
  });

  List<String> get _effectivePaths {
    final fromList = photoPaths;
    if (fromList != null && fromList.isNotEmpty) return fromList;
    if (photoPath != null && photoPath!.isNotEmpty) return [photoPath!];
    return const [];
  }

  String _orQuestion(String? v) => v ?? '?';

  bool _isLowConfidence(ModelInferenceResult? result) {
    if (result == null) return false;
    final percent = (result.accuracyModel * 100).round();
    return confidenceAccentColorFromPercent(percent) == kConfidenceRed;
  }

  Future<void> _handleSave(BuildContext context, ModelInferenceResult mr) async {
    var resultToSubmit = mr;
    if (_isLowConfidence(mr)) {
      final decision = await Navigator.push<LowConfidenceDecision>(
        context,
        MaterialPageRoute(
          builder: (_) => LowConfidenceScreen(result: mr),
        ),
      );
      if (!context.mounted || decision == null) return;

      switch (decision.action) {
        case LowConfidenceAction.retakePhoto:
          Navigator.pop(context, false);
          return;
        case LowConfidenceAction.manualReview:
          resultToSubmit = decision.correctedResult ?? mr;
      }
    }

    context.read<NewInspectionBloc>().add(
          SubmitNewInspection(
            userId: userId,
            photoPaths: _effectivePaths,
            modelResult: resultToSubmit,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final mr = modelResult;
    final accentColor = mr == null
        ? _gray400
        : confidenceAccentColorFromPercent((mr.accuracyModel * 100).round());

    return BlocListener<NewInspectionBloc, NewInspectionState>(
      listenWhen: (prev, curr) =>
          curr is NewInspectionSubmitSuccess ||
          curr is NewInspectionSubmitFailure,
      listener: (context, state) {
        if (state is NewInspectionSubmitSuccess) {
          if (context.mounted) {
            context.read<NewInspectionBloc>().add(ResetNewInspection());
            Navigator.pop(context, true);
          }
        } else if (state is NewInspectionSubmitFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FDFA),
        appBar: AppBar(
          title: const Text('Результат'),
          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          backgroundColor: _teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _ResultPhotoCarousel(paths: _effectivePaths),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(left: BorderSide(color: accentColor, width: 4)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Результат анализа', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accentColor)),
                    const SizedBox(height: 12),
                    _row('Материал', _orQuestion(mr?.material)),
                    _row('Состояние', _orQuestion(mr?.state?.toString())),
                    _row('Тип повреждения', mr != null ? damageTypeLabelRu(mr.damageType) : '?'),
                    _row('Степень повреждения', mr?.damageDegree != null ? mr!.damageDegree!.toStringAsFixed(2) : '?'),
                    _row(
                      'Уверенность модели',
                      mr != null ? '${(mr.accuracyModel * 100).toStringAsFixed(1)}%' : '?',
                      valueColor: mr != null ? accentColor : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<NewInspectionBloc, NewInspectionState>(
                buildWhen: (p, c) =>
                    c is NewInspectionSubmitting ||
                    c is NewInspectionSubmitSuccess ||
                    c is NewInspectionSubmitFailure ||
                    c is NewInspectionInitial,
                builder: (context, state) {
                  final submitting = state is NewInspectionSubmitting;
                  return SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: submitting
                          ? null
                          : () {
                              if (mr == null) {
                                Navigator.pop(context, false);
                                return;
                              }
                              _handleSave(context, mr);
                            },
                      child: submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              mr == null ? 'Готово' : 'Сохранить',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  );
                },
              ),
              if (mr == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Анализ не выполнялся (заглушка)',
                    style: TextStyle(fontSize: 12, color: _gray500),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: _gray500)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _ResultPhotoCarousel extends StatefulWidget {
  final List<String> paths;

  const _ResultPhotoCarousel({required this.paths});

  @override
  State<_ResultPhotoCarousel> createState() => _ResultPhotoCarouselState();
}

class _ResultPhotoCarouselState extends State<_ResultPhotoCarousel> {
  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paths = widget.paths;
    if (paths.isEmpty || kIsWeb) {
      return _resultPhotoPlaceholder();
    }
    if (paths.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: double.infinity,
          height: 160,
          child: Image.file(
            File(paths.first),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _resultPhotoPlaceholder(),
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: paths.length,
              itemBuilder: (context, i) {
                return Image.file(
                  File(paths[i]),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 160,
                  errorBuilder: (_, __, ___) => _resultPhotoPlaceholder(),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Фото ${_page + 1} из ${paths.length}',
          style: const TextStyle(fontSize: 12, color: _gray400),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(paths.length, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _page ? _teal : _gray400.withOpacity(0.35),
              ),
            );
          }),
        ),
      ],
    );
  }
}

Widget _resultPhotoPlaceholder() {
  return Container(
    width: double.infinity,
    height: 160,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Icon(Icons.camera_alt, color: _gray400, size: 40),
  );
}
