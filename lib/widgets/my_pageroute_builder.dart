import 'package:flutter/material.dart';

class MyBouncySlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  MyBouncySlideUpPageRoute({required this.page})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.fastOutSlowIn;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Interval(0.0, 0.7, curve: Curves.fastOutSlowIn),
                ),
              ),
              child: child,
            );
          },
        );
}
