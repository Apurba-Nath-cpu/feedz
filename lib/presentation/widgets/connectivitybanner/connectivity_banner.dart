import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool isVisible;
  final bool isRestored;

  const ConnectivityBanner({
    super.key,
    required this.isVisible,
    required this.isRestored,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final color = isRestored ? Colors.green : Colors.red;
    final message =
        isRestored ? 'Internet restored' : 'No internet connection';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: color,
        padding: EdgeInsets.only(
          top: 8.0,
          bottom: 8.0 + MediaQuery.of(context).padding.bottom,
          left: 8.0,
          right: 8.0,
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
