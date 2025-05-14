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
    setState(() {});
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
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Report Listing',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: _suggestedReasons.map((reason) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: RadioListTile<String>(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      tileColor: _selectedReason == reason
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.grey[100],
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
                    ),
                  );
                }).toList(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedReason == 'Other'
                    ? Padding(
                        key: const ValueKey('textField'),
                        padding: const EdgeInsets.only(top: 16),
                        child: TextField(
                          controller: _reasonController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Please describe the issue...',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
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
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.flag),
                    label: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white.withOpacity(0.6),
                      disabledBackgroundColor:
                          theme.colorScheme.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
