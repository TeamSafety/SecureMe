import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/models/AppColors.dart';

class PresetMessage extends StatelessWidget {
  final String message;
  const PresetMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 8,
          ),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                  color: AppColors.secondary.withOpacity(0.8), fontSize: 12),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          GestureDetector(
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.09),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/icons/send_icon.svg',
                    height: 25,
                    width: 25,
                  ),
                  Text(
                    "Send to",
                    style: TextStyle(
                        fontSize: 6,
                        color: AppColors.secondary.withOpacity(0.8)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
