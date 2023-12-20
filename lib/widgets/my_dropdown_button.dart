import 'package:cashxchange/constants/constant_values.dart';
import 'package:flutter/material.dart';

class MyDropdown extends StatelessWidget {
  final String selectedParameter;
  final void Function(String?)? onChange;
  final List<String> parameterItems;
  const MyDropdown(
      {super.key,
      required this.selectedParameter,
      required this.onChange,
      required this.parameterItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.deepGreen, width: 1),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(selectedParameter),
        value: selectedParameter,
        onChanged: onChange,
        // style: TextStyle(),
        borderRadius: BorderRadius.circular(20),
        dropdownColor: AppColors.mintGreen,
        elevation: 4,
        underline: const SizedBox(),
        items: parameterItems.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Row(
              children: [
                item == "Nearby Requests"
                    ? const Icon(Icons.location_pin)
                    : item == "Requests Near Home"
                        ? const Icon(Icons.my_location)
                        : const Icon(Icons.atm),
                const SizedBox(
                  width: 20,
                ),
                Text(item),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
