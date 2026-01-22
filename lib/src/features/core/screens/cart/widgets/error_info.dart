import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:flutter/material.dart';

// Sometimes, I will remove this file
// If I forgot to, please ignore this file, sir

class ErrorInfo extends StatelessWidget {
  const ErrorInfo({
    super.key,
    required this.title,
    required this.description,
    this.button,
    this.btnText,
    required this.press,
  });

  final String title;
  final String description;
  final Widget? button;
  final String? btnText;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Container(
      constraints: BoxConstraints(maxWidth: isDesktop ? 400 : double.infinity),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? aaliyahLightColor : aaliyahDarkColor,
              fontSize: isDesktop ? 32 : 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? aaliyahLightColor : aaliyahDarkColor,
              fontSize: isDesktop ? 18 : 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          button ??
              SizedBox(
                width: isDesktop ? 300 : double.infinity,
                child: ElevatedButton(
                  onPressed: press,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      isDesktop ? 200 : double.infinity,
                      isDesktop ? 56 : 48,
                    ),
                    backgroundColor: isDarkMode
                        ? aaliyahPrimaryColor
                        : aaliyahSecondaryColor,
                    foregroundColor: isDarkMode
                        ? aaliyahLightColor
                        : aaliyahDarkColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    btnText ?? "Retry".toUpperCase(),
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
