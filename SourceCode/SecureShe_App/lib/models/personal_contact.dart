import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';

class PersonalContact extends StatelessWidget {
  final String contactName;
  final String imagePath; // TODO: WILL CHANGE LATER
  const PersonalContact({
    super.key,
    required this.contactName,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // CONTACT ROW
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppVars.primary,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: AppVars.secondary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2.0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // PROFILE PIC
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              clipBehavior: Clip.hardEdge,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppVars.secondary.withOpacity(0.5),
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(100),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppVars.secondary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2.0),
                  ),
                ],
              ),
              child: Image(
                fit: BoxFit.scaleDown,
                image: AssetImage(imagePath),
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  contactName,
                  style: TextStyle(
                    color: AppVars.secondary,
                    fontSize: AppVars.textTitle,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Expanded(
                  child: Row(
                    children: [
                      // CONTACT BUTTON
                      GestureDetector(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppVars.accent,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(color: Colors.white),
                              boxShadow: [
                                BoxShadow(
                                  color: AppVars.secondary.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 2.0),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.map,
                              color: AppVars.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // CONTACT BUTTON
                      GestureDetector(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppVars.primary,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(
                                  color: AppVars.secondary.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppVars.secondary.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 2.0),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.message,
                              color: AppVars.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // CONTACT BUTTON
                      GestureDetector(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppVars.primary,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(
                                  color: AppVars.secondary.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppVars.secondary.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 2.0),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.phone_callback,
                              color: AppVars.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
