import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/income_source_provider.dart';

class TransactionForm extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onSubmit;
  final Transaction? transaction;

  const TransactionForm({Key? key, required this.onSubmit, this.transaction})
    : super(key: key);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  int? _categoryId;
  int? _incomeSourceId;
  String? _description;
  double? _amount;
  late String _paymentMethod;
  String? _location;
  String? _receiptPhoto;
  String? _tags;
  late DateTime _date;
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();

    // Initialize with existing transaction data or defaults
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _type = t.type;
      _categoryId = t.categoryId;
      _incomeSourceId = t.incomeSourceId;
      _description = t.description;
      _amount = t.amount;
      _paymentMethod = t.paymentMethod;
      _location = t.location;
      _receiptPhoto = t.receiptPhoto;
      _tags = t.tags;
      _date = t.transactionDate;
    } else {
      _type = 'expense';
      _paymentMethod = 'cash';
      _date = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.transaction != null ? 'Sửa giao dịch' : 'Thêm giao dịch',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: 'income',
                    groupValue: _type,
                    onChanged: (v) => setState(() {
                      _type = v!;
                      _categoryId = null; // Reset category when type changes
                    }),
                    title: const Text('Thu nhập'),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: 'expense',
                    groupValue: _type,
                    onChanged: (v) => setState(() {
                      _type = v!;
                      _categoryId = null; // Reset category when type changes
                    }),
                    title: const Text('Chi tiêu'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                prefixText: '₫ ',
              ),
              keyboardType: TextInputType.number,
              initialValue: _amount?.toString(),
              validator: (v) => v == null || v.isEmpty ? 'Nhập số tiền' : null,
              onSaved: (v) => _amount = double.tryParse(v ?? ''),
            ),
            const SizedBox(height: 12),
            Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final categories = provider.categories
                    .where((c) => c.type == _type)
                    .toList();

                return DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  value: _categoryId,
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(
                            _getIconData(category.icon),
                            color: Color(
                              int.parse(
                                category.color.replaceFirst('#', '0xFF'),
                              ),
                            ),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null ? 'Chọn danh mục' : null,
                );
              },
            ),
            const SizedBox(height: 12),
            if (_type == 'income')
              Consumer<IncomeSourceProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Nguồn thu nhập',
                    ),
                    value: _incomeSourceId,
                    items: provider.incomeSources.map((source) {
                      return DropdownMenuItem<int>(
                        value: source.id,
                        child: Text(source.name),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _incomeSourceId = v),
                  );
                },
              ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Mô tả'),
              initialValue: _description,
              onSaved: (v) => _description = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Phương thức thanh toán',
              ),
              value: _paymentMethod,
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Tiền mặt')),
                DropdownMenuItem(value: 'card', child: Text('Thẻ')),
                DropdownMenuItem(
                  value: 'bank_transfer',
                  child: Text('Chuyển khoản'),
                ),
                DropdownMenuItem(value: 'e_wallet', child: Text('Ví điện tử')),
                DropdownMenuItem(value: 'other', child: Text('Khác')),
              ],
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tag (phân cách bằng dấu phẩy)',
              ),
              initialValue: _tags,
              onSaved: (v) => _tags = v,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InputDatePickerFormField(
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateSubmitted: (d) => setState(() => _date = d),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: () {
                    // TODO: Implement location picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng vị trí sẽ được thêm sau'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    // TODO: Implement photo picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng chụp ảnh sẽ được thêm sau'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
              title: const Text('Giao dịch định kỳ'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        widget.onSubmit({
                          'type': _type,
                          'amount': _amount,
                          'categoryId': _categoryId,
                          'incomeSourceId': _incomeSourceId,
                          'description': _description,
                          'paymentMethod': _paymentMethod,
                          'tags': _tags,
                          'date': _date,
                          'location': _location,
                          'receiptPhoto': _receiptPhoto,
                          'isRecurring': _isRecurring,
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(
                      widget.transaction != null ? 'Cập nhật' : 'Lưu giao dịch',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      case 'shopping':
        return Icons.shopping_bag;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.money;
    }
  }
}


