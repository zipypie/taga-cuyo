import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class DropdownInputF extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final Function(String?)? onChanged;

  const DropdownInputF({
    super.key,
    this.value,
    required this.items,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Check if an item is selected to determine the container color
    bool isSelected = value != null && value!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? AppColors.accentColor : Colors.white, // Change color when selected
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(25),
            value: value,
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft, // Align hint to the left
                child: Text(
                  hintText,
                  style: const TextStyle(
                    color: Color.fromARGB(115, 39, 32, 32), // Hint text color
                    fontSize: 18, // Font size
                    fontWeight: FontWeight.w100, // Font weight
                    fontFamily: AppFonts.fcb, // Replace with your font family
                  ),
                ),
              ),
            ),
            items: items.map((String item) {
              // Check if the item is selected
              bool isItemSelected = item == value;

              return DropdownMenuItem<String>(
                value: item,
                child: Container(
                  alignment: Alignment.center, // Centers the item text
                  decoration: BoxDecoration(
                    color: isItemSelected ? AppColors.accentColor : Colors.transparent, // Set background color for selected item
                    borderRadius: BorderRadius.circular(25), // Rounded corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: isItemSelected ? Colors.white : AppColors.titleColor, // Change text color for selected item
                        fontSize: 18, // Font size
                        fontWeight: FontWeight.w100, // Font weight
                        fontFamily: AppFonts.fcb, // Font family
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            style: const TextStyle(
                color: AppColors.titleColor), // Selected item text color
            icon: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.arrow_drop_down, color: Colors.black45),
            ),
          ),
        ),
      ),
    );
  }
}
