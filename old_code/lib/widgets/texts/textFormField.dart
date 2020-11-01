import 'package:flutter/material.dart';

// INCLUDED VALIDATOR PROPERTY AND CONTROLLER TO EXTRACT TEXT FROM THE TEXT FIELD
class OurTextFormField extends StatelessWidget {
  final String label;
  final Function savedFunction; //should be returning a string
  final bool isPassword;
  final FormFieldValidator<String> formValidator;
  final TextEditingController controller;
  final Icon icon;
  final bool multipleLines;

  OurTextFormField({
    @required this.label,
    this.savedFunction,
    this.isPassword,
    this.formValidator,
    this.controller,
    this.icon,
    this.multipleLines = false,
  }) : assert(label != null);

  @override
  Widget build(BuildContext context) {
    InputDecoration _inputDecoration = InputDecoration(
      labelText: label,
      prefixIcon: icon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
    );
    if (multipleLines) {
      return TextFormField(
        decoration: _inputDecoration,
        obscureText: isPassword ?? false,
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        minLines: 1,
        validator: (value) => formValidator(value),
        onSaved: (value) => savedFunction(),
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        maxLength: 1000,
      );
    } else {
      return TextFormField(
        decoration: _inputDecoration,
        obscureText: isPassword ?? false,
        validator: (value) => formValidator(value),
        onSaved: (value) => savedFunction(),
        controller: controller,
      );
    }
  }
}
