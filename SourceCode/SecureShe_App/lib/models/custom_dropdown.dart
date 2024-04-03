import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';

class CustomDropdown extends StatefulWidget {
  final String title;
  final ValueChanged<String?> dropdownValue;
  final List<String> listItems;

  CustomDropdown({
    required this.title,
    required this.listItems,
    required this.dropdownValue,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      alignment: Alignment.centerLeft,
      iconSize: AppVars.bigHeader,
      iconEnabledColor: AppVars.accent,
      value: selected,
      hint: Text(
        widget.title,
        style: TextStyle(fontSize: AppVars.smallText),
      ),
      onChanged: (String? value) {
        setState(() {
          selected = value;
          widget.dropdownValue(value);
        });
      },
      items: widget.listItems.map((String element) {
        return DropdownMenuItem<String>(
          value: element,
          child: Text(
            element,
            style: TextStyle(
              color: AppVars.secondary,
              fontSize: AppVars.textTitle,
            ),
          ),
        );
      }).toList(),
    );
  }
}
