import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/budget.dart';

class BudgetForm extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onSubmit;
  final Budget? budget; // For editing existing budgets

  const BudgetForm({Key? key, required this.onSubmit, this.budget})
    : super(key: key);

  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String _type = 'expense';
  Color _color = AppTheme.primaryColor;
  String _icon = 'money';
  double? _budgetLimit;
  bool _isEssential = false;
  int _priority = 1;

  @override
  void initState() {
    super.initState();

    // Initialize with existing budget data if editing
    if (widget.budget != null) {
      _name = widget.budget!.name;
      _type = widget.budget!.type.toString().split('.').last;
      _budgetLimit = widget.budget!.budgetLimit;
      _isEssential = widget.budget!.isEssential;
      _priority = widget.budget!.priority;
    }
  }

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
                decoration: const InputDecoration(labelText: 'Tên ngân sách'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nhập tên ngân sách' : null,
                onSaved: (v) => _name = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Loại'),
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Thu nhập')),
                  DropdownMenuItem(value: 'expense', child: Text('Chi tiêu')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // TODO: Hiện color picker
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: _color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Text(
                            'Chọn màu',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Icon'),
                      value: _icon,
                      items: const [
                        DropdownMenuItem(
                          value: 'money',
                          child: Icon(Icons.attach_money),
                        ),
                        DropdownMenuItem(
                          value: 'food',
                          child: Icon(Icons.fastfood),
                        ),
                        DropdownMenuItem(
                          value: 'home',
                          child: Icon(Icons.home),
                        ),
                        DropdownMenuItem(
                          value: 'car',
                          child: Icon(Icons.directions_car),
                        ),
                        DropdownMenuItem(
                          value: 'shopping',
                          child: Icon(Icons.shopping_cart),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Icon(Icons.category),
                        ),
                      ],
                      onChanged: (v) => setState(() => _icon = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Hạn mức ngân sách',
                ),
                keyboardType: TextInputType.number,
                onSaved: (v) => _budgetLimit = double.tryParse(v ?? ''),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isEssential,
                onChanged: (v) => setState(() => _isEssential = v),
                title: const Text('Thiết yếu'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Độ ưu tiên'),
                value: _priority,
                items: List.generate(
                  5,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('Ưu tiên ${i + 1}'),
                  ),
                ),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    widget.onSubmit({
                      'name': _name,
                      'type': _type,
                      'color': _color.value,
                      'icon': _icon,
                      'budgetLimit': _budgetLimit,
                      'isEssential': _isEssential,
                      'priority': _priority,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Lưu ngân sách'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


