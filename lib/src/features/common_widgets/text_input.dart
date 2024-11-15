import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';

class TextFieldInputF extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData icon;
  final String? errorText; // Added errorText parameter

  const TextFieldInputF({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.icon,
    this.errorText, // Include in constructor
  });

  @override
  TextFieldInputFState createState() => TextFieldInputFState(); // No underscore here
}

// Remove the underscore to make it public
class TextFieldInputFState extends State<TextFieldInputF> {
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Padding(
      padding:  EdgeInsets.all(height*0.0089),
      child: Column( // Change to Column to include error text
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            obscureText: widget.isPass && _isPasswordHidden,
            controller: widget.textEditingController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: Color.fromARGB(115, 58, 48, 48),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: Colors.black45,
              ),
              suffixIcon: widget.isPass
                  ? IconButton(
                      icon: Icon(
                        _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black45,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 2, color: AppColors.titleColor),
                  borderRadius: BorderRadius.circular(5)),
            ),
          ),
          if (widget.errorText != null) // Show error text if available
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                widget.errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
