import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../theme.dart';

class BillForm extends StatefulWidget {
  final Bill? bill;
  final Function(Map<String, dynamic>) onSubmit;

  const BillForm({Key? key, this.bill, required this.onSubmit})
    : super(key: key);

  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _merchantInfoController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = 'utilities';
  String _frequency = 'monthly';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String _reminderType = 'notification';
  int _reminderDaysBefore = 3;
  bool _isFixed = true;
  String? _paymentMethod;

  final List<String> _categories = [
    'utilities',
    'internet',
    'phone',
    'insurance',
    'loan',
    'subscription',
    'rent',
    'credit_card',
    'other',
  ];

  final List<String> _frequencies = [
    'weekly',
    'monthly',
    'quarterly',
    'yearly',
    'custom',
  ];

  final List<String> _paymentMethods = [
    'cash',
    'bank_transfer',
    'credit_card',
    'debit_card',
    'e_wallet',
    'auto_pay',
    'check',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      _initializeWithBill();
    }
  }

  void _initializeWithBill() {
    final bill = widget.bill!;
    _nameController.text = bill.name;
    _descriptionController.text = bill.description;
    _amountController.text = bill.amount.toString();
    _merchantInfoController.text = bill.merchantInfo ?? '';
    _accountNumberController.text = bill.accountNumber ?? '';
    _websiteController.text = bill.website ?? '';
    _notesController.text = bill.notes ?? '';

    _category = bill.category;
    _frequency = bill.frequency;
    _dueDate = bill.dueDate;
    _reminderType = bill.reminderType;
    _reminderDaysBefore = bill.reminderDaysBefore;
    _isFixed = bill.isFixed;
    _paymentMethod = bill.paymentMethod;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _merchantInfoController.dispose();
    _accountNumberController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bill == null ? 'Thêm hóa đơn' : 'Sửa hóa đơn',
          style: AppTheme.headlineMedium,
        ),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: Text(
              'Lưu',
              style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information Section
                _buildSectionTitle('Thông tin cơ bản'),
                _buildBasicInfoSection(),

                SizedBox(height: AppTheme.spacing6),

                // Amount and Frequency Section
                _buildSectionTitle('Số tiền và tần suất'),
                _buildAmountSection(),

                SizedBox(height: AppTheme.spacing6),

                // Due Date and Reminders Section
                _buildSectionTitle('Ngày đáo hạn và nhắc nhở'),
                _buildDueDateSection(),

                SizedBox(height: AppTheme.spacing6),

                // Payment Information Section
                _buildSectionTitle('Thông tin thanh toán'),
                _buildPaymentInfoSection(),

                SizedBox(height: AppTheme.spacing6),

                // Additional Information Section
                _buildSectionTitle('Thông tin bổ sung'),
                _buildAdditionalInfoSection(),

                SizedBox(height: AppTheme.spacing8),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Text(
        title,
        style: AppTheme.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên hóa đơn *',
                hintText: 'VD: Hóa đơn điện',
                prefixIcon: Icon(Icons.receipt),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên hóa đơn';
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.spacing4),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Mô tả chi tiết về hóa đơn',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),

            SizedBox(height: AppTheme.spacing4),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Danh mục *',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category), size: 20),
                      SizedBox(width: AppTheme.spacing2),
                      Text(_getCategoryDisplayName(category)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Số tiền *',
                hintText: '0',
                prefixIcon: Icon(Icons.monetization_on),
                suffixText: 'đ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số tiền';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Số tiền phải lớn hơn 0';
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.spacing4),

            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Tần suất thanh toán *',
                prefixIcon: Icon(Icons.schedule),
              ),
              items: _frequencies.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(_getFrequencyDisplayName(frequency)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _frequency = value!),
            ),

            SizedBox(height: AppTheme.spacing4),

            SwitchListTile(
              title: const Text('Số tiền cố định'),
              subtitle: Text(
                _isFixed
                    ? 'Số tiền không thay đổi hàng tháng'
                    : 'Số tiền có thể thay đổi',
              ),
              value: _isFixed,
              onChanged: (value) => setState(() => _isFixed = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueDateSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          children: [
            ListTile(
              title: const Text('Ngày đáo hạn'),
              subtitle: Text(_formatDate(_dueDate)),
              leading: const Icon(Icons.calendar_today),
              trailing: const Icon(Icons.edit),
              onTap: _selectDueDate,
            ),

            SizedBox(height: AppTheme.spacing4),

            DropdownButtonFormField<String>(
              value: _reminderType,
              decoration: const InputDecoration(
                labelText: 'Loại nhắc nhở',
                prefixIcon: Icon(Icons.notifications),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'notification',
                  child: Text('Thông báo trong ứng dụng'),
                ),
                DropdownMenuItem(value: 'email', child: Text('Email')),
                DropdownMenuItem(value: 'sms', child: Text('SMS')),
              ],
              onChanged: (value) => setState(() => _reminderType = value!),
            ),

            SizedBox(height: AppTheme.spacing4),

            DropdownButtonFormField<int>(
              value: _reminderDaysBefore,
              decoration: const InputDecoration(
                labelText: 'Nhắc nhở trước',
                prefixIcon: Icon(Icons.timer),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 ngày')),
                DropdownMenuItem(value: 2, child: Text('2 ngày')),
                DropdownMenuItem(value: 3, child: Text('3 ngày')),
                DropdownMenuItem(value: 5, child: Text('5 ngày')),
                DropdownMenuItem(value: 7, child: Text('1 tuần')),
                DropdownMenuItem(value: 14, child: Text('2 tuần')),
              ],
              onChanged: (value) =>
                  setState(() => _reminderDaysBefore = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Phương thức thanh toán',
                prefixIcon: Icon(Icons.payment),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Chọn phương thức'),
                ),
                ..._paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(_getPaymentMethodDisplayName(method)),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _paymentMethod = value),
            ),

            SizedBox(height: AppTheme.spacing4),

            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Số tài khoản/Mã khách hàng',
                hintText: 'VD: 123456789',
                prefixIcon: Icon(Icons.account_box),
              ),
            ),

            SizedBox(height: AppTheme.spacing4),

            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website thanh toán',
                hintText: 'VD: https://example.com',
                prefixIcon: Icon(Icons.web),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          children: [
            TextFormField(
              controller: _merchantInfoController,
              decoration: const InputDecoration(
                labelText: 'Thông tin nhà cung cấp',
                hintText: 'VD: Công ty điện lực Hà Nội',
                prefixIcon: Icon(Icons.business),
              ),
            ),

            SizedBox(height: AppTheme.spacing4),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                hintText: 'Ghi chú thêm về hóa đơn...',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: EdgeInsets.symmetric(vertical: AppTheme.spacing4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: Text(
          widget.bill == null ? 'Thêm hóa đơn' : 'Cập nhật hóa đơn',
          style: AppTheme.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() => _dueDate = selectedDate);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'amount': double.parse(_amountController.text),
        'category': _category,
        'frequency': _frequency,
        'dueDate': _dueDate,
        'reminderType': _reminderType,
        'reminderDaysBefore': _reminderDaysBefore,
        'isFixed': _isFixed,
        'paymentMethod': _paymentMethod,
        'merchantInfo': _merchantInfoController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'website': _websiteController.text.trim(),
        'notes': _notesController.text.trim(),
      };

      widget.onSubmit(data);
    }
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'utilities':
        return Icons.electrical_services;
      case 'internet':
        return Icons.wifi;
      case 'phone':
        return Icons.phone_android;
      case 'insurance':
        return Icons.security;
      case 'loan':
        return Icons.account_balance;
      case 'subscription':
        return Icons.subscriptions;
      case 'rent':
        return Icons.home;
      case 'credit_card':
        return Icons.credit_card;
      default:
        return Icons.receipt;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'utilities':
        return 'Tiện ích (điện, nước, gas)';
      case 'internet':
        return 'Internet/TV';
      case 'phone':
        return 'Điện thoại';
      case 'insurance':
        return 'Bảo hiểm';
      case 'loan':
        return 'Vay/Nợ';
      case 'subscription':
        return 'Đăng ký dịch vụ';
      case 'rent':
        return 'Thuê nhà';
      case 'credit_card':
        return 'Thẻ tín dụng';
      case 'other':
        return 'Khác';
      default:
        return 'Khác';
    }
  }

  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'weekly':
        return 'Hàng tuần';
      case 'monthly':
        return 'Hàng tháng';
      case 'quarterly':
        return 'Hàng quý';
      case 'yearly':
        return 'Hàng năm';
      case 'custom':
        return 'Tùy chỉnh';
      default:
        return 'Hàng tháng';
    }
  }

  String _getPaymentMethodDisplayName(String method) {
    switch (method) {
      case 'cash':
        return 'Tiền mặt';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      case 'credit_card':
        return 'Thẻ tín dụng';
      case 'debit_card':
        return 'Thẻ ghi nợ';
      case 'e_wallet':
        return 'Ví điện tử';
      case 'auto_pay':
        return 'Thanh toán tự động';
      case 'check':
        return 'Séc';
      case 'other':
        return 'Khác';
      default:
        return 'Khác';
    }
  }
}


