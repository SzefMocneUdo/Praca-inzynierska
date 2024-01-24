import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({Key? key}) : super(key: key);

  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  Currency? _selectedCurrency;
  late TextEditingController _currencyTextField;
  TextEditingController _descriptionController = TextEditingController();

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
        title: Text('Add New Income'),
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
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
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
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildCurrencyPickerTextField(),
                  ),
                ],
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
                    _addIncome();
                  }
                },
                child: Text('Add Income'),
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

  Widget _buildCurrencyPickerTextField() {
    return TextFormField(
      controller: _currencyTextField,
      readOnly: true,
      decoration: InputDecoration(
        hintText:
            _selectedCurrency != null ? _selectedCurrency!.name : 'Currency',
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

  void _addIncome() {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        firestore.collection('incomes').add({
          'userId': user.uid,
          'name': _nameController.text,
          'date': _selectedDate,
          'amount': double.parse(_amountController.text),
          'description': _descriptionController.text,
          'currency': _selectedCurrency?.code,
        });

        print('Income added successfully!');
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Error adding income: $e');
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
