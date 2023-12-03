import 'package:cashxchange/constants/constant_values.dart';
import 'package:flutter/material.dart';

class MyLargeText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final double? height;
  final double? wordspacing;
  final String? fontFamily;
  const MyLargeText({
    super.key,
    required this.text,
    this.size,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.height,
    this.wordspacing,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      style: TextStyle(
        fontSize: size ?? 16,
        color: color ?? Colors.white,
        fontWeight: fontWeight ?? FontWeight.normal,
        wordSpacing: wordspacing,
        height: height,
      ),
    );
  }
}

class MyMediumText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final double? height;
  final double? wordspacing;
  final String? fontFamily;
  const MyMediumText({
    super.key,
    required this.text,
    this.size,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.height,
    this.wordspacing,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      style: TextStyle(
        fontSize: size ?? 16,
        color: color ?? AppColors.dimBlack,
        fontWeight: fontWeight ?? FontWeight.normal,
        wordSpacing: wordspacing,
        height: height,
      ),
    );
  }
}
