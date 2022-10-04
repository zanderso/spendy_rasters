// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' as svg;

const int kStarPoints = 48;   // Number of points on the star-shaped clips.
                              //   higher -> slower
const int kStarLayers = 10;   // Number of star-shaped clips stacked up.
                              //   higher -> slower
const int kTigerColumns = 1;  // Number of tigers per column in the scroll view
                              // grid.
                              //   higher -> slower
const int kSpinDuration = 5;  // Tiger rotation period in seconds.
                              //   lower -> faster spinning

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: Center(
          child: PainfulTigerGrid(count: 200),
        ),
      ),
    );
  }
}

class PainfulAnimation extends StatefulWidget {
  const PainfulAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<PainfulAnimation> createState() => PainfulAnimationState();
}

class PainfulAnimationState extends State<PainfulAnimation>
                            with TickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: kSpinDuration),
    )
    ..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = RotationTransition(
      turns: _rotationController,
      child: widget.child,
    );
    for (int i = 0; i < kStarLayers; i++) {
      result = ClipPath(
        clipper: StarClipper(
          kStarPoints,
          outerScale: 1.05 + 0.05 * i,
          innerScale: 0.60,
        ),
        child: Container(
          color: i % 2 == 0 ? Colors.black : Colors.orange,
          child: result,
        )
      );
    }
    return result;
  }
}

class PainfulTiger extends StatelessWidget {
  const PainfulTiger({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PainfulAnimation(
      child: svg.SvgPicture.asset(
        'assets/tiger.svg',
      ),
    );
  }
}

class PainfulTigerGrid extends StatelessWidget {
  const PainfulTigerGrid({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: kTigerColumns,
            childAspectRatio: 1.0,
            mainAxisSpacing: 0.0
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return const PainfulTiger();
            },
            childCount: count,
          ),
        ),
      ],
    );
  }
}

class StarClipper extends CustomClipper<Path> {
  StarClipper(
    this.points, {
    this.degreesOffset = 0.0,
    this.outerScale = 1.0,
    this.innerScale = 0.5,
  });

  /// The number of points of the star
  final int points;

  final double degreesOffset;
  final double outerScale;
  final double innerScale;

  // Degrees to radians conversion
  double _degreeToRadian(double deg) => deg * (math.pi / 180.0);

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double max = 2 * math.pi + _degreeToRadian(degreesOffset);

    final double width = size.width;
    final double halfWidth = width / 2;

    final double wingRadius = halfWidth * outerScale;
    final double radius = halfWidth * innerScale;

    final double degreesPerStep = _degreeToRadian(360 / points);
    final double halfDegreesPerStep = degreesPerStep / 2;

    final startStep = _degreeToRadian(degreesOffset);

    path.moveTo(
      halfWidth + radius * math.cos(startStep),
      halfWidth + radius * math.sin(startStep),
    );

    for (double step = startStep; step < max; step += degreesPerStep) {
      path.quadraticBezierTo(
        halfWidth + wingRadius * math.cos(step + halfDegreesPerStep),
        halfWidth + wingRadius * math.sin(step + halfDegreesPerStep),
        halfWidth + radius * math.cos(step + degreesPerStep),
        halfWidth + radius * math.sin(step + degreesPerStep),
      );
    }

    path.close();
    return path;
  }

  // If the new instance represents different information than the old instance,
  // this method will return true, otherwise it should return false.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    StarClipper starClipper = oldClipper as StarClipper;
    return points != starClipper.points ||
           degreesOffset != starClipper.degreesOffset ||
           innerScale != starClipper.innerScale ||
           outerScale != starClipper.outerScale;
  }
}
