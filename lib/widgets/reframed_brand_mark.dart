import 'package:flutter/material.dart';

class ReframedBrandMark extends StatelessWidget {
  final double fontSize;
  final double underlineWidth;

  const ReframedBrandMark({
    super.key,
    this.fontSize = 68,
    this.underlineWidth = 110,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFA78BFA);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Reframed',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accent,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            height: 0.95,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: Container(
            width: underlineWidth,
            height: 5,
            margin: EdgeInsets.only(left: fontSize * 0.14, top: 8),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }
}
