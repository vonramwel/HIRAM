// lib/report_user/widget/report_user_dialog.dart
import 'package:flutter/material.dart';
import '../service/report_user_service.dart';

class ReportUserDialog extends StatefulWidget {
  final String userId;
  const ReportUserDialog({super.key, required this.userId});

  @override
  State<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _selectedReason;

  final List<String> _suggestedReasons = [
    'Spam or Scam',
    'Harassment',
    'Inappropriate Behavior',
    'Fake Profile',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(() => setState(() {}));
  }

  bool get _canSubmit {
    if (_selectedReason == 'Other') {
      return _reasonController.text.trim().isNotEmpty;
    } else {
      return _selectedReason != null;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._suggestedReasons.map((reason) => RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                      if (value != 'Other') {
                        _reasonController.text = value ?? '';
                      } else {
                        _reasonController.clear();
                      }
                    });
                  },
                )),
            if (_selectedReason == 'Other') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Please describe the issue...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: !_canSubmit || _isSubmitting
              ? null
              : () async {
                  setState(() {
                    _isSubmitting = true;
                  });
                  await ReportUserService.reportUser(
                    userId: widget.userId,
                    reason: _reasonController.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
