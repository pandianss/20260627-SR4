import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import 'package:grading/grading.dart';
import '../components/option_chip.dart';
import '../components/button.dart';
import '../components/card.dart';
import '../theme/tokens.dart';

class QuestionRenderer extends StatefulWidget {
  final QuestionBase question;
  final ValueChanged<Response> onAnswerChecked;
  final VoidCallback onContinue;
  final bool showFeedback;

  const QuestionRenderer({
    super.key,
    required this.question,
    required this.onAnswerChecked,
    required this.onContinue,
    this.showFeedback = true,
  });

  @override
  State<QuestionRenderer> createState() => _QuestionRendererState();
}

class _QuestionRendererState extends State<QuestionRenderer> {
  // Input tracking
  String? _selectedOptionId;
  bool? _selectedBool;
  final TextEditingController _numericController = TextEditingController();
  final Map<String, TextEditingController> _multistepControllers = {};
  final Map<String, String> _matchMapping = {}; // leftId -> rightId

  bool _isChecked = false;
  RawGrade? _grade;

  @override
  void initState() {
    super.initState();
    _initializeInputs();
  }

  @override
  void didUpdateWidget(QuestionRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _isChecked = false;
        _grade = null;
        _selectedOptionId = null;
        _selectedBool = null;
        _numericController.clear();
        _multistepControllers.clear();
        _matchMapping.clear();
        _initializeInputs();
      });
    }
  }

  void _initializeInputs() {
    final payload = widget.question.payload;
    if (payload is NumericMultiStep) {
      for (final step in payload.steps) {
        _multistepControllers[step.id] = TextEditingController();
      }
    } else if (payload is MatchPairs) {
      // initially empty mapping
    }
  }

  @override
  void dispose() {
    _numericController.dispose();
    for (final controller in _multistepControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Response? _buildResponse() {
    final payload = widget.question.payload;
    if (payload is McqSingle) {
      if (_selectedOptionId == null) return null;
      return McqResponse(_selectedOptionId!);
    } else if (payload is TrueFalse) {
      if (_selectedBool == null) return null;
      return TrueFalseResponse(_selectedBool!);
    } else if (payload is NumericEntry) {
      final val = double.tryParse(_numericController.text);
      if (val == null) return null;
      return NumericResponse(val);
    } else if (payload is NumericMultiStep) {
      final Map<String, double> stepValues = {};
      for (final entry in _multistepControllers.entries) {
        final val = double.tryParse(entry.value.text);
        if (val == null) return null;
        stepValues[entry.key] = val;
      }
      return MultiStepResponse(stepValues);
    } else if (payload is MatchPairs) {
      // In tests, ensure we have all left items matched
      if (_matchMapping.length < payload.left.length) return null;
      return MatchResponse(_matchMapping);
    }
    return null;
  }

  void _handleAnswerChanged() {
    if (!widget.showFeedback) {
      final response = _buildResponse();
      if (response != null) {
        widget.onAnswerChecked(response);
      }
    }
  }

  void _checkAnswer() {
    final response = _buildResponse();
    if (response == null) return;

    final grader = const Grader();
    final grade = grader.grade(widget.question, response);

    setState(() {
      _isChecked = true;
      _grade = grade;
    });

    widget.onAnswerChecked(response);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final payload = widget.question.payload;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Stem
        Text(
          _getQuestionStem(),
          style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),

        // Input Fields Area
        _buildInputFields(payload, t),

        if (widget.showFeedback) ...[
          const SizedBox(height: 24),

          // HUD / Grading Feedback Area
          if (_isChecked && _grade != null) _buildFeedbackHud(t),

          const SizedBox(height: 24),

          // Bottom CTA Buttons
          if (!_isChecked)
            CalmButton.primary(
              text: 'Check Answer',
              onPressed: _buildResponse() != null ? _checkAnswer : null,
            )
          else
            CalmButton.primary(
              text: 'Continue',
              onPressed: widget.onContinue,
            ),
        ],
      ],
    );
  }

  String _getQuestionStem() {
    final payload = widget.question.payload;
    if (payload is McqSingle) return payload.stem.resolve('en');
    if (payload is TrueFalse) return payload.stem.resolve('en');
    if (payload is NumericEntry) return payload.stem.resolve('en');
    if (payload is NumericMultiStep) return payload.stem.resolve('en');
    if (payload is MatchPairs) return payload.stem.resolve('en');
    return '';
  }

  Widget _buildInputFields(QuestionPayload payload, AppTokens t) {
    if (payload is McqSingle) {
      return Column(
        children: List.generate(payload.options.length, (index) {
          final option = payload.options[index];
          final id = option.id;

          OptionChipState chipState = OptionChipState.unselected;
          if (_isChecked) {
            if (id == payload.correctOptionId) {
              chipState = OptionChipState.correct;
            } else if (id == _selectedOptionId) {
              chipState = OptionChipState.wrong;
            }
          } else {
            if (id == _selectedOptionId) {
              chipState = OptionChipState.selected;
            }
          }

          return CalmOptionChip(
            identifier: _getOptionLetter(index),
            label: option.content.resolve('en'),
            state: chipState,
            onTap: _isChecked
                ? null
                : () {
                    setState(() => _selectedOptionId = id);
                    _handleAnswerChanged();
                  },
          );
        }),
      );
    } else if (payload is TrueFalse) {
      return Column(
        children: [
          _buildTrueFalseChip(t, true, 'True'),
          const SizedBox(height: 8),
          _buildTrueFalseChip(t, false, 'False'),
        ],
      );
    } else if (payload is NumericEntry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _numericController,
            enabled: !_isChecked,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTypography.body(t),
            decoration: InputDecoration(
              hintText: 'Enter numerical answer',
              hintStyle: AppTypography.bodySm(t).copyWith(color: t.textTertiary),
              suffixText: payload.unit,
              suffixStyle: AppTypography.body(t).copyWith(color: t.accent),
              filled: true,
              fillColor: t.bgSurface,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: t.border),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: t.accent),
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: t.border),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (_) {
              setState(() {});
              _handleAnswerChanged();
            },
          ),
        ],
      );
    } else if (payload is NumericMultiStep) {
      return Column(
        children: List.generate(payload.steps.length, (index) {
          final step = payload.steps[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Step ${index + 1}: ${step.prompt.resolve('en')}',
                  style: AppTypography.bodySm(t).copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _multistepControllers[step.id],
                  enabled: !_isChecked,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTypography.body(t),
                  decoration: InputDecoration(
                    hintText: 'Value',
                    filled: true,
                    fillColor: t.bgSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: t.border),
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {});
                    _handleAnswerChanged();
                  },
                ),
              ],
            ),
          );
        }),
      );
    } else if (payload is MatchPairs) {
      // Draw simple dropdown mapping in vertical rows
      return Column(
        children: List.generate(payload.left.length, (index) {
          final leftOpt = payload.left[index];
          final leftVal = leftOpt.content.resolve('en');

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    leftVal,
                    style: AppTypography.body(t),
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _matchMapping[leftOpt.id],
                    hint: const Text('Match'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: t.bgSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: payload.right.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt.id,
                        child: Text(opt.content.resolve('en')),
                      );
                    }).toList(),
                    onChanged: _isChecked
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() {
                                _matchMapping[leftOpt.id] = val;
                              });
                              _handleAnswerChanged();
                            }
                          },
                  ),
                ),
              ],
            ),
          );
        }),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTrueFalseChip(AppTokens t, bool value, String label) {
    final payload = widget.question.payload as TrueFalse;
    OptionChipState chipState = OptionChipState.unselected;

    if (_isChecked) {
      if (value == payload.answer) {
        chipState = OptionChipState.correct;
      } else if (value == _selectedBool) {
        chipState = OptionChipState.wrong;
      }
    } else {
      if (value == _selectedBool) {
        chipState = OptionChipState.selected;
      }
    }

    return CalmOptionChip(
      identifier: value ? 'T' : 'F',
      label: label,
      state: chipState,
      onTap: _isChecked
          ? null
          : () {
              setState(() => _selectedBool = value);
              _handleAnswerChanged();
            },
    );
  }

  Widget _buildFeedbackHud(AppTokens t) {
    final isCorrect = _grade!.correctness == Correctness.correct;

    return CalmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? t.accent : t.danger,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isCorrect ? 'Correct' : 'Incorrect',
                style: AppTypography.heading(t).copyWith(
                  color: isCorrect ? t.accent : t.danger,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.question.explanation.resolve('en'),
            style: AppTypography.bodySm(t),
          ),
        ],
      ),
    );
  }

  String _getOptionLetter(int index) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    return letters[index % letters.length];
  }
}
