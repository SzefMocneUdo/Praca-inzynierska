// AddExpenseScreen class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  Currency? _selectedCurrency;
  late TextEditingController _currencyTextField;
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String? selectedPaymentMethod;
  List<String> paymentMethods = ['Cash', 'Card'];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currencyTextField = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Expense'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                label: 'Name',
                controller: _nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _dateController.text =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: _buildTextField(
                    label: 'Date',
                    controller: _dateController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Date is required';
                      }
                      return null;
                    },
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(
                label: 'Amount',
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Amount is required';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Invalid amount format';
                  }
                  return null;
                },
                prefixIcon: Icon(Icons.attach_money),
              ),
              _buildCurrencyPickerTextField(),
              SizedBox(height: 10),
              _buildDropdownButtonFormField(
                value: selectedPaymentMethod,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue;
                  });
                },
                items: paymentMethods
                    .map<DropdownMenuItem<String>>((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                labelText: 'Payment Method',
                validator: (value) {
                  if (value == null) {
                    return 'Payment Method is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              _buildTextField(
                label: 'Category',
                controller: _categoryController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Category is required';
                  }
                  if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                    return 'Only letters are allowed';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              _buildTextField(
                label: 'Description',
                controller: _descriptionController,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addExpense();
                  }
                },
                child: Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.grey, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      style: TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownButtonFormField({
    required String? value,
    required Function(String?)? onChanged,
    required List<DropdownMenuItem<String>> items,
    required String labelText,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items,
      decoration: InputDecoration(labelText: labelText),
      validator: validator,
    );
  }

  Widget _buildCurrencyPickerTextField() {
    return TextFormField(
      controller: _currencyTextField,
      readOnly: true,
      decoration: InputDecoration(
        hintText: _selectedCurrency != null ? _selectedCurrency!.name : 'Currency',
        prefixIcon: Icon(
          Icons.attach_money,
          color: Colors.grey,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.arrow_drop_down,
            color: Colors.grey,
          ),
          onPressed: () {
            _openCurrencyPicker();
          },
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.grey, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      style: TextStyle(color: Colors.black),
    );
  }

  void _addExpense() {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        firestore.collection('expenses').add({
          'userId': user.uid,
          'name': _nameController.text,
          'date': _selectedDate,
          'amount': double.parse(_amountController.text),
          'category': _categoryController.text,
          'description': _descriptionController.text,
          'currency': _selectedCurrency?.code,
          'paymentMethod': selectedPaymentMethod,
        });

        print('Expense added successfully!');
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Error adding expense: $e');
    }

    Navigator.pop(context);
  }

  void _openCurrencyPicker() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        setState(() {
          _selectedCurrency = currency;
          _currencyTextField.text = currency.name;
        });
      },
    );
  }
}
