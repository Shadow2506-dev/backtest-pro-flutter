=== lib/widgets/load_csv_dialog.dart ===

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/csv_service.dart';

class LoadCsvDialog extends StatefulWidget {
  const LoadCsvDialog({super.key});

  @override
  State<LoadCsvDialog> createState() => _LoadCsvDialogState();
}

class _LoadCsvDialogState extends State<LoadCsvDialog> {
  final _pathController = TextEditingController();
  final _textController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  int _selectedTab = 0;

  @override
  void dispose() {
    _pathController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Load CSV Data'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Paste Text'),
                    selected: _selectedTab == 0,
                    onSelected: (v) => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('File Path'),
                    selected: _selectedTab == 1,
                    onSelected: (v) => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedTab == 0) ...[
              TextField(
                controller: _textController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Date,Open,High,Low,Close,Volume\n2024-01-01,1.1000,1.1050,...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _loadFromText,
                child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Load Text'),
              ),
            ] else ...[
              TextField(
                controller: _pathController,
                decoration: const InputDecoration(
                  hintText: '/storage/emulated/0/Download/data.csv',
                  labelText: 'File Path',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _loadFromFile,
                child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Load File'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
            const Divider(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadSample,
              icon: const Icon(Icons.auto_fix_high, size: 18),
              label: const Text('Load Sample EURUSD'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _loadFromText() async {
    if (_textController.text.trim().isEmpty) {
      setState(() => _error = 'Please paste CSV data');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final provider = context.read<AppProvider>();
      await provider.loadDatasetFromText(_textController.text, 'pasted_data.csv');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = 'Error: $e'; _isLoading = false; });
    }
  }

  Future<void> _loadFromFile() async {
    if (_pathController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter file path');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final provider = context.read<AppProvider>();
      await provider.loadDatasetFromFile(_pathController.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = 'Error: $e'; _isLoading = false; });
    }
  }

  Future<void> _loadSample() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final provider = context.read<AppProvider>();
      final sample = CsvService.generateSampleData();
      await provider.loadDatasetFromText(sample, 'sample_EURUSD.csv');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = 'Error: $e'; _isLoading = false; });
    }
  }
}
