import 'package:flutter/material.dart';

class RaiseRequestScreen extends StatefulWidget {
  const RaiseRequestScreen({super.key});

  @override
  _RaiseRequestScreenState createState() => _RaiseRequestScreenState();
}

class _RaiseRequestScreenState extends State<RaiseRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _requestType = 'Cash';
  double _amount = 0.0;
  final String _description = '';
  String _preferredLocation = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Select Request Type:',
              style: TextStyle(fontSize: 16.0),
            ),
            DropdownButtonFormField<String>(
              value: _requestType,
              onChanged: (value) {
                setState(() {
                  _requestType = value!;
                });
              },
              items: ['Cash', 'Online Money']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter the amount',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the amount';
                }
                return null;
              },
              onSaved: (value) {
                _amount = double.parse(value!);
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Icon(
                  Icons.location_on, // Location icon
                  color:
                      Theme.of(context).primaryColor, // Use the primary color
                ),
                const SizedBox(width: 8.0), // Add spacing
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Preferred Location (optional)',
                      hintText: 'Enter your preferred location',
                    ),
                    onSaved: (value) {
                      _preferredLocation = value!;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Preferred Location (optional)',
                hintText: 'Enter your preferred location',
              ),
              onSaved: (value) {
                _preferredLocation = value!;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Handle the request submission here
                  // You can access _requestType, _amount, and _description for further processing
                }
              },
              child: const Text('Raise Request'),
            ),
          ],
        ),
      ),
    );
  }
}
