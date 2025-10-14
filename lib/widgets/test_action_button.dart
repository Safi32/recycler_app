import 'package:flutter/material.dart';
import 'package:recycler/utils/colors.dart';

class TestActionButton extends StatelessWidget {
	final String label;
	final VoidCallback? onPressed;
	final Color? backgroundColor;
	final Color? foregroundColor;
	final Color? disabledBackgroundColor;

	const TestActionButton({
		super.key,
		required this.label,
		this.backgroundColor,
		this.foregroundColor,
		this.onPressed,
		this.disabledBackgroundColor,
	});

	@override
	Widget build(BuildContext context) {
		// When onPressed is null the button is disabled; use disabledBackgroundColor if provided
		final isEnabled = onPressed != null;
		final bgColor = backgroundColor ?? AppColors.householdButton;
		final fgColor = foregroundColor ?? Colors.white;
		final bg = isEnabled ? bgColor : (disabledBackgroundColor ?? bgColor.withOpacity(0.5));

		return SizedBox(
			width: double.infinity,
			child: ElevatedButton(
				onPressed: onPressed,
				style: ElevatedButton.styleFrom(
					backgroundColor: bg,
					foregroundColor: fgColor,
					padding: const EdgeInsets.symmetric(vertical: 14),
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(8),
					),
				),
				child: Text(label),
			),
		);
	}
}
