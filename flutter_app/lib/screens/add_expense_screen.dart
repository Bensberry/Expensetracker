import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/expense_provider.dart';
import '../services/receipt_service.dart';
import '../models/expense.dart';
import '../core/theme.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0; // 0 = Manual, 1 = Scan
  final _amountCtrl = TextEditingController(text: '0.00');
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _submitting = false;

  // Scan Receipt variables
  File? _receiptImage;
  bool _scanning = false;
  List<Expense> _extractedExpenses = [];
  final Set<int> _selectedIndices = {};
  bool _savingExtracted = false;
  final _imagePicker = ImagePicker();
  String? _rawOcrText;
  bool _showRawOcr = false;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Food', 'emoji': '🍔'},
    {'label': 'Transport', 'emoji': '🚗'},
    {'label': 'Shopping', 'emoji': '🛍️'},
    {'label': 'Utilities', 'emoji': '🏠'},
    {'label': 'Entertainment', 'emoji': '🎬'},
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.surface,
            onSurface: AppTheme.foreground,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitManual() async {
    final raw = _amountCtrl.text.replaceAll(',', '');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      _showSnack('Please enter a valid amount', isError: true);
      return;
    }

    setState(() => _submitting = true);

    final expense = Expense(
      title: _descCtrl.text.trim().isEmpty
          ? _selectedCategory
          : _descCtrl.text.trim(),
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );

    await Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).addExpense(expense);

    if (mounted) {
      setState(() {
        _submitting = false;
        _amountCtrl.text = '0.00';
        _descCtrl.clear();
      });
      _showSnack('Expense added!');
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.destructive : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (pickedFile != null) {
        setState(() {
          _receiptImage = File(pickedFile.path);
          _extractedExpenses.clear();
          _rawOcrText = null;
          _showRawOcr = false;
        });
      }
    } catch (e) {
      _showSnack(
        'Could not access ${source == ImageSource.camera ? "camera" : "gallery"}: $e',
        isError: true,
      );
    }
  }

  Future<void> _uploadAndScan() async {
    if (_receiptImage == null) return;

    setState(() {
      _scanning = true;
      _rawOcrText = null;
      _showRawOcr = false;
    });

    try {
      final result = await ReceiptService().uploadReceipt(_receiptImage!.path);

      if (!mounted) return;

      setState(() {
        _rawOcrText = result.message;
      });

      if (result.success && result.expenses.isNotEmpty) {
        setState(() {
          _extractedExpenses = result.expenses;
          _selectedIndices.clear();
          _selectedIndices.addAll(
            List.generate(result.expenses.length, (index) => index),
          );
        });
        _showSnack(
          '✓ Extracted ${result.expenses.length} item(s) from receipt',
        );
      } else if (result.success && result.expenses.isEmpty) {
        _showSnack(
          'No expense items detected from OCR text',
          isError: true,
        );
      } else {
        _showSnack(result.message, isError: true);
      }
    } catch (e) {
      _showSnack('Upload failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _saveSelectedExpenses() async {
    if (_selectedIndices.isEmpty) {
      _showSnack('Please select at least one expense to save', isError: true);
      return;
    }

    setState(() => _savingExtracted = true);

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      int count = 0;
      for (final index in _selectedIndices) {
        if (index >= 0 && index < _extractedExpenses.length) {
          final expense = _extractedExpenses[index];
          await provider.addExpense(expense);
          count++;
        }
      }
      _showSnack('✓ Saved $count expense(s) to history');
      setState(() {
        _extractedExpenses.clear();
        _selectedIndices.clear();
        _receiptImage = null;
        _rawOcrText = null;
        _showRawOcr = false;
      });
      // Refresh home/history
      await provider.fetchExpenses();
    } catch (e) {
      _showSnack('Failed to save: $e', isError: true);
    } finally {
      setState(() => _savingExtracted = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Add Expense',
            style: TextStyle(
              color: AppTheme.foreground,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Tab Toggle
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _TabButton(
                  label: '✏️  Manual Entry',
                  selected: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                _TabButton(
                  label: '📷  Scan Receipt',
                  selected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_tabIndex == 0)
            _buildManualEntryForm()
          else
            _buildScanReceiptView(),
        ],
      ),
    );
  }

  // ──────────────────────────────── MANUAL FORM ────────────────────────────────

  Widget _buildManualEntryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Amount',
                style: TextStyle(color: AppTheme.mutedForeground, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '\$',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: AppTheme.foreground,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Category
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category',
                style: TextStyle(
                  color: AppTheme.foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['label'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat['label']),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withAlpha(
                                    (0.2 * 255).round(),
                                  )
                                : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat['emoji'],
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat['label'],
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.mutedForeground,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Description
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description (Optional)',
                style: TextStyle(color: AppTheme.mutedForeground, fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descCtrl,
                style: const TextStyle(color: AppTheme.foreground),
                decoration: const InputDecoration(
                  hintText: 'What was it for?',
                  hintStyle: TextStyle(color: AppTheme.mutedForeground),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: AppTheme.primary),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Date
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date',
                style: TextStyle(color: AppTheme.mutedForeground, fontSize: 13),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('dd / MM / yyyy').format(_selectedDate),
                        style: const TextStyle(
                          color: AppTheme.foreground,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: AppTheme.mutedForeground,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _submitting ? null : _submitManual,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.background,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────── SCAN VIEW ────────────────────────────────

  Widget _buildScanReceiptView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload tip banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha((0.08 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primary.withAlpha((0.25 * 255).round()),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Take a photo or upload a screenshot of any bill or receipt — our OCR will extract the items automatically.',
                  style: TextStyle(
                    color: AppTheme.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Image Preview / Placeholder
        _Card(
          child: Column(
            children: [
              if (_receiptImage == null) ...[
                // Placeholder
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.border,
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        color: AppTheme.mutedForeground.withAlpha(120),
                        size: 56,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No receipt selected',
                        style: TextStyle(
                          color: AppTheme.foreground,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Use the buttons below to upload',
                        style: TextStyle(
                          color: AppTheme.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Image preview
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _receiptImage!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _receiptImage = null;
                          _extractedExpenses.clear();
                          _rawOcrText = null;
                          _showRawOcr = false;
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(160),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _receiptImage!.path.split('/').last.split('\\').last,
                  style: const TextStyle(
                    color: AppTheme.mutedForeground,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),

              // Gallery / Camera buttons
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Scan button (only visible after image selected and before scan results)
        if (_receiptImage != null && _extractedExpenses.isEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _scanning ? null : _uploadAndScan,
              child: _scanning
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.background,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Scanning receipt with OCR...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.center_focus_strong_rounded, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Scan & Extract Receipt',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

        // Extracted Expenses Results
        if (_extractedExpenses.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Found ${_extractedExpenses.length} item(s)',
                style: const TextStyle(
                  color: AppTheme.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() {
                    if (_selectedIndices.length == _extractedExpenses.length) {
                      _selectedIndices.clear();
                    } else {
                      _selectedIndices.clear();
                      _selectedIndices.addAll(
                        List.generate(_extractedExpenses.length, (idx) => idx),
                      );
                    }
                  });
                },
                icon: Icon(
                  _selectedIndices.length == _extractedExpenses.length
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 18,
                ),
                label: Text(
                  _selectedIndices.length == _extractedExpenses.length
                      ? 'Deselect All'
                      : 'Select All',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...List.generate(_extractedExpenses.length, (i) {
            final e = _extractedExpenses[i];
            final isSelected = _selectedIndices.contains(i);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedIndices.remove(i);
                  } else {
                    _selectedIndices.add(i);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withAlpha((0.08 * 255).round())
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : AppTheme.mutedForeground,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: AppTheme.background,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.foreground
                                  : AppTheme.mutedForeground,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              decoration: isSelected
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                          if (e.category.isNotEmpty)
                            Text(
                              e.category,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.mutedForeground
                                    : AppTheme.mutedForeground.withAlpha(120),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${e.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isSelected ? AppTheme.primary : AppTheme.mutedForeground,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: isSelected
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: _savingExtracted ? null : _saveSelectedExpenses,
              child: _savingExtracted
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.background,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Save Selected to History (${_selectedIndices.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => setState(() {
                _receiptImage = null;
                _extractedExpenses.clear();
                _rawOcrText = null;
                _showRawOcr = false;
              }),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.document_scanner_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Scan Another Receipt',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ], // ← closes if (_extractedExpenses.isNotEmpty) ...[
        // Raw OCR Debug Panel
        if (_rawOcrText != null) ...[
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => _showRawOcr = !_showRawOcr),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.terminal_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Raw OCR Text (Debug)',
                            style: TextStyle(
                              color: AppTheme.foreground,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        _showRawOcr ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.mutedForeground,
                      ),
                    ],
                  ),
                ),
                if (_showRawOcr) ...[
                  const Divider(color: AppTheme.border, height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: SingleChildScrollView(
                      child: Text(
                        _rawOcrText!,
                        style: const TextStyle(
                          color: AppTheme.mutedForeground,
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ], // ← closes if (_rawOcrText != null) ...[
      ],
    );
  }
}

// ─────────────────────────────── SHARED WIDGETS ────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.foreground,
        side: const BorderSide(color: AppTheme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppTheme.background : AppTheme.mutedForeground,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
