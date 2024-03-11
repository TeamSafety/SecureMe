import 'package:flutter/material.dart';


class DropdownButtonClass extends StatefulWidget {
  final List<String> contacts;
  final List<String> messages;
  final ValueChanged<String?> onContactChanged;
  final ValueChanged<String?> onMessageChanged;

  DropdownButtonClass({
    required this.contacts,
    required this.messages,
    required this.onContactChanged,
    required this.onMessageChanged,
  });

  @override
  _DropdownButtonClassState createState() => _DropdownButtonClassState();
}

class _DropdownButtonClassState extends State<DropdownButtonClass> {
  String? selectedContact;
  String? selectedMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          value: selectedContact,
          hint: const Text('Select Emergency Contact'),
          onChanged: (String? value) {
            setState(() {
              selectedContact = value;
              widget.onContactChanged(value);
            });
          },
          items: widget.contacts.map((String contact) {
            return DropdownMenuItem<String>(
              value: contact,
              child: Text(contact),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        DropdownButton<String>(
          value: selectedMessage,
          hint: const Text('Select Message'),
          onChanged: (String? value) {
            setState(() {
              selectedMessage = value;
              widget.onMessageChanged(value);
            });
          },
          items: widget.messages.map((String message) {
            return DropdownMenuItem<String>(
              value: message,
              child: Text(message),
            );
          }).toList(),
        ),
      ],
    );
  }
}
