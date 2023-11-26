import 'package:cashxchange/constants/color_constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Widget? child;
  final Color? color;
  const CustomButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.child,
      this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation: MaterialStateProperty.all<double?>(7.0),
        foregroundColor: const MaterialStatePropertyAll<Color>(Colors.white),
        backgroundColor:
            MaterialStatePropertyAll<Color>(color ?? AppColors.deepGreen),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      child: child ??
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
    );
  }
}
