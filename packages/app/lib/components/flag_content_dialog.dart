import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'button.dart';

void showFlagContentDialog({
  required BuildContext context,
  required String contentId,
  required String contentType,
  required String userId,
  required String examContext,
  required Future<void> Function({
    required String userId,
    required String examContext,
    required String contentId,
    required String contentType,
    required String reason,
  }) onFlagSubmitted,
}) {
  showDialog(
    context: context,
    builder: (context) => _FlagContentDialog(
      contentId: contentId,
      contentType: contentType,
      userId: userId,
      examContext: examContext,
      onFlagSubmitted: onFlagSubmitted,
    ),
  );
}

class _FlagContentDialog extends StatefulWidget {
  final String contentId;
  final String contentType;
  final String userId;
  final String examContext;
  final Future<void> Function({
    required String userId,
    required String examContext,
    required String contentId,
    required String contentType,
    required String reason,
  }) onFlagSubmitted;

  const _FlagContentDialog({
    required this.contentId,
    required this.contentType,
    required this.userId,
    required this.examContext,
    required this.onFlagSubmitted,
  });

  @override
  State<_FlagContentDialog> createState() => _FlagContentDialogState();
}

class _FlagContentDialogState extends State<_FlagContentDialog> {
  String? _selectedReason;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  final List<String> _reasons = [
    'Incorrect information',
    'Typo / spelling error',
    'Broken formula / rendering',
    'Wrong answer key',
    'Other issue',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;
    setState(() => _submitting = true);
    
    final fullReason = _commentController.text.trim().isEmpty 
        ? _selectedReason! 
        : '${_selectedReason!}: ${_commentController.text.trim()}';

    try {
      await widget.onFlagSubmitted(
        userId: widget.userId,
        examContext: widget.examContext,
        contentId: widget.contentId,
        contentType: widget.contentType,
        reason: fullReason,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you. Content flagged for review.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit flag: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Dialog(
      backgroundColor: t.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Report an issue',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: t.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us improve the study material. Let us know what is incorrect with this ${widget.contentType}.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: t.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ..._reasons.map((r) => RadioListTile<String>(
                  title: Text(
                    r,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: t.textPrimary,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: r,
                  groupValue: _selectedReason,
                  activeColor: t.accent,
                  onChanged: (val) => setState(() => _selectedReason = val),
                )),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Additional details (optional)...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: t.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: t.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: t.accent),
                ),
              ),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: t.textPrimary,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: t.textSecondary, fontFamily: 'Inter'),
                  ),
                ),
                const SizedBox(width: 12),
                CalmButton.primary(
                  text: 'Submit',
                  onPressed: _selectedReason == null || _submitting ? null : _submit,
                  expand: false,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
