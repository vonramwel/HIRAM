import 'package:flutter/material.dart';
import '../service/report_service.dart';

class ReportListingDialog extends StatefulWidget {
  final String listingId;
  const ReportListingDialog({super.key, required this.listingId});

  @override
  _ReportListingDialogState createState() => _ReportListingDialogState();
}

class _ReportListingDialogState extends State<ReportListingDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _selectedReason;

  final List<String> _suggestedReasons = [
    'Fraud or Scam',
    'Inappropriate Content',
    'Incorrect Information',
    'Counterfeit Product',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_onReasonChanged);
  }

  @override
  void dispose() {
    _reasonController.removeListener(_onReasonChanged);
    _reasonController.dispose();
    super.dispose();
  }

  void _onReasonChanged() {
    setState(() {}); // Rebuild the button when text changes
  }

  bool get _canSubmit {
    if (_selectedReason == 'Other') {
      return _reasonController.text.trim().isNotEmpty;
    } else {
      return _selectedReason != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Listing'),
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
                  await ReportService.reportListing(
                    listingId: widget.listingId,
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
