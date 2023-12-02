import 'package:cashxchange/constants/constant_values.dart';
import 'package:flutter/material.dart';

class MyConstantWidget extends StatelessWidget {
  final Widget? child;
  const MyConstantWidget({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        [
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            height: MediaQuery.of(context).size.height * 0.35,
            child: child ??
                Center(
                  child: CircularProgressIndicator(
                    color: AppColors.deepGreen,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
