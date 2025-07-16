import 'package:flutter/material.dart';
import '../theme.dart';

class GoalForm extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onSubmit;
  const GoalForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  double? _targetAmount;
  DateTime _targetDate = DateTime.now();
  String? _description;
  String _status = 'in_progress';
  int _priority = 1;

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
                decoration: const InputDecoration(labelText: 'Tên mục tiêu'),
                validator: (v) => v == null || v.isEmpty ? 'Nhập tên mục tiêu' : null,
                onSaved: (v) => _name = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số tiền mục tiêu'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _targetAmount = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              InputDatePickerFormField(
                initialDate: _targetDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateSubmitted: (d) => setState(() => _targetDate = d),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mô tả'),
                onSaved: (v) => _description = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Trạng thái'),
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'in_progress', child: Text('Đang thực hiện')),
                  DropdownMenuItem(value: 'completed', child: Text('Hoàn thành')),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Độ ưu tiên'),
                value: _priority,
                items: List.generate(5, (i) => DropdownMenuItem(value: i + 1, child: Text('Ưu tiên ${i + 1}'))),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    widget.onSubmit({
                      'name': _name,
                      'targetAmount': _targetAmount,
                      'targetDate': _targetDate,
                      'description': _description,
                      'status': _status,
                      'priority': _priority,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                child: const Text('Lưu mục tiêu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 

