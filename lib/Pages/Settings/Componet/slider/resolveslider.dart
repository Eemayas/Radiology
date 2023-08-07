import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../Provider/value.dart';

class ResolveSlider extends StatefulWidget {
  final int max, min, step, interval;
  const ResolveSlider({
    super.key,
    required this.max,
    required this.min,
    required this.step,
    required this.interval,
  });

  @override
  State<ResolveSlider> createState() => _ResolveSliderState();
}

class _ResolveSliderState extends State<ResolveSlider> {
  int? rvalue;
  @override
  void initState() {
    rvalue = context.read<ResolveValue>().rvalue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfSlider(
      min: widget.min,
      max: widget.max,
      value: rvalue,
      interval: widget.interval.toDouble(),
      showTicks: true,
      stepSize: widget.step.toDouble(),
      showLabels: true,
      // enableTooltip: true,
      // minorTicksPerInterval: 1,
      onChanged: (value) {
        setState(() {
          rvalue = value.toInt();
          context.read<ResolveValue>().rchange(value.toInt());
        });
      },
    );
  }
}
