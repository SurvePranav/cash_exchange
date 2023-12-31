import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:flutter/material.dart';

class RequestSuccessScreen extends StatelessWidget {
  final RequestModel request;
  const RequestSuccessScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              flex: 10,
              child: Container(
                  color: Colors.green,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 35,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Request Raised",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text("for ${request.type} of Rs.${request.amount}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ],
                  ))),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Text(
                  "Done",
                  style: TextStyle(color: AppColors.deepGreen, fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
