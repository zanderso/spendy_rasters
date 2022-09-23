// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' as svg;
import 'package:page_flip_builder/page_flip_builder.dart' as flip;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: PainfulTigerGrid(count: 200),
      ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             // const Text(
//             //   'You have pushed the button this many times:',
//             // ),
//             // AnimatedRotatingText(
//             //   text: '$_counter',
//             //   // style: Theme.of(context).textTheme.headlineMedium,
//             // ),
// //             PainfulParagraph(text:
// // "On the other hand, we denounce with righteous indignation and dislike men who "
// // "are so beguiled and demoralized by the charms of pleasure of the moment, so "
// // "blinded by desire, that they cannot foresee the pain and trouble that are bound "
// // "to ensue; and equal blame belongs to those who fail in their duty through "
// // "weakness of will, which is the same as saying through shrinking from toil and "
// // "pain. These cases are perfectly simple and easy to distinguish. In a free hour, "
// // "when our power of choice is untrammelled and when nothing prevents our being "
// // "able to do what we like best, every pleasure is to be welcomed and every pain "
// // "avoided. But in certain circumstances and owing to the claims of duty or the "
// // "obligations of business it will frequently occur that pleasures have to be "
// // "repudiated and annoyances accepted. The wise man therefore always holds in "
// // "these matters to this principle of selection: he rejects pleasures to secure "
// // "other greater pleasures, or else he endures pains to avoid worse pains."),
//             PainfulTigerGrid(count: 1),
//           ],
//         ),
//      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
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
  late AnimationController _scaleController;
  late AnimationController _clipController;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
    ..repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
    ..forward();
    //..repeat(reverse: true);

    _clipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )
    ..addListener(() {
      setState(() {});
    })
    ..repeat();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
    ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _clipController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
    ClipPath(
      clipper: StarClipper(
        32,
        innerScale: 0.55,
      ),
      child: ClipPath(
        clipper: StarClipper(
          32,
          innerScale: 0.55,
        ),
        child: Transform(
          transform: Matrix4.rotationY(0.5)
            ..setEntry(3, 0, 0.0005),
          child: widget.child,
        ),
      ),
    );
  }

  Widget _flippingTiger(Widget clip) {
    return flip.AnimatedPageFlipBuilder(
      animation: _flipController,
      showFrontSide: true,
      frontBuilder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Text(
              'It is a tiger!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            clip,
          ],
        );
      },
      backBuilder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Text(
              'Rawrrrr!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Transform(
              child: clip,
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.1415),
            ),
          ],
        );
      },
    );
  }
}

class PainfulParagraph extends StatelessWidget {
  const PainfulParagraph({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return PainfulAnimation(
      child: Text(text),
    );
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
            crossAxisCount: 1,
            childAspectRatio: 1.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return PainfulTiger(/*width: 250, height: 250*/);
            },
            childCount: count,
          ),
        ),
      ],
    );
  }
}


// This custom clipper help us achieve n-pointed star shape
class StarClipper extends CustomClipper<Path> {
  StarClipper(
    this.points, {
    this.degreesOffset = 0.0,
    this.innerScale = 0.5,
  });

  /// The number of points of the star
  final int points;

  final double degreesOffset;
  final double innerScale;

  // Degrees to radians conversion
  double _degreeToRadian(double deg) => deg * (math.pi / 180.0);

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double max = 2 * math.pi + _degreeToRadian(degreesOffset);

    final double width = size.width;
    final double halfWidth = width / 2;

    final double wingRadius = halfWidth;
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
    return points != starClipper.points || degreesOffset != starClipper.degreesOffset;
  }
}

class RandomBezierClipper extends CustomClipper<Path> {
  RandomBezierClipper(this.points);

  final int points;

  final math.Random rng = math.Random.secure();

  @override
  Path getClip(Size size) {
    final Path path = Path();
    for (int i = 0; i < points; i++) {
      final double x1 = rng.nextDouble() * size.width;
      final double y1 = rng.nextDouble() * size.height;
      final double x2 = rng.nextDouble() * size.width;
      final double y2 = rng.nextDouble() * size.height;
      // final double x3 = rng.nextDouble() * size.width;
      // final double y3 = rng.nextDouble() * size.height;
      //path.cubicTo(x1, y1, x2, y2, x3, y3);
      path.quadraticBezierTo(x1, y1, x2, y2);
    }
    path.close();
    return path;
  }

  // If the new instance represents different information than the old instance,
  // this method will return true, otherwise it should return false.
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    RandomBezierClipper clipper = oldClipper as RandomBezierClipper;
    return points != clipper.points;
  }
}
