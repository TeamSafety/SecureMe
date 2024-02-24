import 'package:flutter/material.dart';
import 'package:my_app/models/AppColors.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityContact extends StatelessWidget {
  final String contactName;
  final String phoneNumber;
  const CommunityContact({
    super.key,
    required this.contactName,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return // CONTACT ROW
        Container(
      width: double.infinity,
      height: 90,
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
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppVars.secondary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2.0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contactName,
                  style: TextStyle(
                    color: AppVars.secondary,
                    fontSize: AppVars.textTitle,
                  ),
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
                              Icons.add,
                              color: AppVars.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // CONTACT BUTTON
                      GestureDetector(
                        onTap: () {
                          _makePhoneCall(phoneNumber);
                        },
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
                              Icons.map,
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

Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}
