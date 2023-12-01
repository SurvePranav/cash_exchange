import 'package:cashxchange/screens/request_module_screens/request_screen.dart';
import 'package:flutter/material.dart';

class EditRequest extends StatelessWidget {
  final Map<String, dynamic> request;
  const EditRequest({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RaiseRequestScreen(
        editRequest: true,
        request: request,
      ),
    );
  }
}
