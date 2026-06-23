import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import 'package:store/store.dart';
import 'package:grading/grading.dart';
import 'question_renderer.dart';
import '../theme/tokens.dart';

class CaseletRenderer extends StatefulWidget {
  final Stimulus stimulus;
  final List<QuestionBase> childQuestions;
  final Function(String questionId, Response response) onQuestionAnswered;
  final VoidCallback onComplete;

  const CaseletRenderer({
    super.key,
    required this.stimulus,
    required this.childQuestions,
    required this.onQuestionAnswered,
    required this.onComplete,
  });

  @override
  State<CaseletRenderer> createState() => _CaseletRendererState();
}

class _CaseletRendererState extends State<CaseletRenderer> {
  int _currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    if (widget.childQuestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentQuestion = widget.childQuestions[_currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Pinned Stimulus Section
        Container(
          decoration: BoxDecoration(
            color: t.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment_outlined, color: t.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Caselet Scenario',
                    style: AppTypography.heading(t).copyWith(
                      fontWeight: FontWeight.w500,
                      color: t.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.stimulus.content.resolve('en'),
                style: AppTypography.bodySm(t).copyWith(height: 1.6),
              ),
              if (widget.stimulus.chartSpec != null) ...[
                const SizedBox(height: 16),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: t.bgBase,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  // Mock draw simple lines
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(5, (index) {
                      return Container(
                        width: 16,
                        height: 20.0 + (index * 15.0),
                        decoration: BoxDecoration(
                          color: t.accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Sublabel showing child question progress
        Text(
          'Question ${_currentQuestionIndex + 1} of ${widget.childQuestions.length}',
          style: AppTypography.caption(t),
        ),
        const SizedBox(height: 8),

        // 2. Active Child Question
        QuestionRenderer(
          key: ValueKey(currentQuestion.id),
          question: currentQuestion,
          onAnswerChecked: (response) {
            widget.onQuestionAnswered(currentQuestion.id, response);
          },
          onContinue: () {
            if (_currentQuestionIndex + 1 < widget.childQuestions.length) {
              setState(() {
                _currentQuestionIndex += 1;
              });
            } else {
              widget.onComplete();
            }
          },
        ),
      ],
    );
  }
}
