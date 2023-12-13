import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/screens/main_body.dart';
import 'package:flutter/material.dart';

typedef MyCallBack = Function(RequestModel request);

class TransactionsList extends StatelessWidget {
  final List<RequestModel> requests;
  final MyCallBack onTap;
  const TransactionsList(
      {super.key, required this.requests, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("You don't have any active requests"),
            const SizedBox(
              height: 140,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 100,
                height: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: AppColors.deepGreen),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MainBody(
                        currentIndex: 2,
                      ),
                    ));
                  },
                  child: const Icon(
                    Icons.add,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Text(
              "Raise A Request",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests.elementAt(index);
          return Card(
            color: AppColors.blue_8,
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                "Request for ${request.type}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                    'Rs.${request.amount}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  SizedBox(
                    width: 50,
                    child: Row(
                      children: [
                        const Icon(Icons.remove_red_eye,
                            size: 18, color: Colors.white70),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "${request.views}",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 30,
              ),
              onTap: () {
                onTap(request);
              },
            ),
          );
        },
      );
    }
  }
}
