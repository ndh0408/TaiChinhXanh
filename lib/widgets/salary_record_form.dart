import 'package:flutter/material.dart';
import '../theme.dart';

class SalaryRecordForm extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onSubmit;
  const SalaryRecordForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<SalaryRecordForm> createState() => _SalaryRecordFormState();
}

class _SalaryRecordFormState extends State<SalaryRecordForm> {
  final _formKey = GlobalKey<FormState>();
  String? _incomeSource;
  double? _grossAmount;
  double? _netAmount;
  double? _bonusAmount;
  double? _deductionsAmount;
  DateTime _receivedDate = DateTime.now();
  int? _workingDays;
  String? _notes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Nguồn thu nhập'),
                items: const [
                  // TODO: Load income source từ DB
                ],
                onChanged: (v) => setState(() => _incomeSource = v),
                validator: (v) => v == null ? 'Chọn nguồn thu nhập' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Gross amount'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Nhập gross amount' : null,
                onSaved: (v) => _grossAmount = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Net amount'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Nhập net amount' : null,
                onSaved: (v) => _netAmount = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Thưởng (bonus)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _bonusAmount = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Khấu trừ (deductions)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _deductionsAmount = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              InputDatePickerFormField(
                initialDate: _receivedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateSubmitted: (d) => setState(() => _receivedDate = d),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số ngày công'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _workingDays = int.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ghi chú'),
                onSaved: (v) => _notes = v,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    widget.onSubmit({
                      'incomeSource': _incomeSource,
                      'grossAmount': _grossAmount,
                      'netAmount': _netAmount,
                      'bonusAmount': _bonusAmount,
                      'deductionsAmount': _deductionsAmount,
                      'receivedDate': _receivedDate,
                      'workingDays': _workingDays,
                      'notes': _notes,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                child: const Text('Lưu chi tiết lương'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 

