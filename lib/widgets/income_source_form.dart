import 'package:flutter/material.dart';
import '../theme.dart';

class IncomeSourceForm extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onSubmit;
  const IncomeSourceForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<IncomeSourceForm> createState() => _IncomeSourceFormState();
}

class _IncomeSourceFormState extends State<IncomeSourceForm> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String _type = 'salary';
  double? _baseAmount;
  String _frequency = 'monthly';
  double? _taxRate;
  bool _isActive = true;

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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tên nguồn thu nhập'),
                validator: (v) => v == null || v.isEmpty ? 'Nhập tên nguồn thu nhập' : null,
                onSaved: (v) => _name = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Loại nguồn thu'),
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'salary', child: Text('Lương cứng')),
                  DropdownMenuItem(value: 'freelance', child: Text('Freelance')),
                  DropdownMenuItem(value: 'business', child: Text('Kinh doanh')),
                  DropdownMenuItem(value: 'investment', child: Text('Đầu tư')),
                  DropdownMenuItem(value: 'other', child: Text('Khác')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số tiền cơ bản'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _baseAmount = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Chu kỳ'),
                value: _frequency,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Hàng ngày')),
                  DropdownMenuItem(value: 'weekly', child: Text('Hàng tuần')),
                  DropdownMenuItem(value: 'monthly', child: Text('Hàng tháng')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Hàng quý')),
                  DropdownMenuItem(value: 'yearly', child: Text('Hàng năm')),
                  DropdownMenuItem(value: 'irregular', child: Text('Bất thường')),
                ],
                onChanged: (v) => setState(() => _frequency = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Thuế suất (%)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _taxRate = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: const Text('Đang hoạt động'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    widget.onSubmit({
                      'name': _name,
                      'type': _type,
                      'baseAmount': _baseAmount,
                      'frequency': _frequency,
                      'taxRate': _taxRate,
                      'isActive': _isActive,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                child: const Text('Lưu nguồn thu nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 

