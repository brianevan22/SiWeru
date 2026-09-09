import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: color != null
            ? ElevatedButton.styleFrom(backgroundColor: color)
            : null,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(label),
      ),
    );
  }
}
