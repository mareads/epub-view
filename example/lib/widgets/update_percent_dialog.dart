import 'package:flutter/material.dart';

class UpdatePercentDialog extends StatelessWidget {
  const UpdatePercentDialog({Key? key, required this.value}) : super(key: key);

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Updating..", style: TextStyle(fontWeight: FontWeight.w500)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${(value * 100).toStringAsFixed(1)}%"),
              const Text("100.0%"),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
            backgroundColor: const Color(0xff858baf),
          ),
        ],
      ),
    );
  }
}
