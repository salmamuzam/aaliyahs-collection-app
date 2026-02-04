import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isLogout;

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLogout ? Colors.red.withValues(alpha: 0.1) : iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isLogout ? Colors.red : iconColor, size: 20),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isLogout ? Colors.red : (isDarkMode ? Colors.white : Colors.grey.shade700),
                  ),
                ),
              ),
              if (!isLogout)
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
