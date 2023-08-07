import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../Provider/value.dart';

class loadSlider extends StatefulWidget {
  final int max, min, step, interval;
  const loadSlider({
    super.key,
    required this.max,
    required this.min,
    required this.step,
    required this.interval,
  });
  @override
  State<loadSlider> createState() => _loadSliderState();
}

class _loadSliderState extends State<loadSlider> {
  int _value = 40;
  @override
  Widget build(BuildContext context) {
    return SfSlider(
      min: widget.min,
      max: widget.max,
      value: _value,
      interval: widget.interval.toDouble(),
      showTicks: true,
      stepSize: widget.step.toDouble(),
      showLabels: true,
      // enableTooltip: true,
      // minorTicksPerInterval: 1,
      onChanged: (value) {
        setState(() {
          _value = value.toInt();
          context.read<loadValue>().lchange(value.toInt());
        });
      },
    );
  }
}
