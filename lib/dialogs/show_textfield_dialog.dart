import 'package:flutter/material.dart';

enum TextFieldDialogButtonType {
  cancel,
  confirm,
}

typedef DialogOptionBuilder = Map<TextFieldDialogButtonType, String> Function();

final controller = TextEditingController();

Future<String?> showTextFieldDialog({
  required BuildContext context,
  required String title,
  required String? hintText,
  required DialogOptionBuilder optionsBuilder,
}) {
  controller.clear();
  final options = optionsBuilder();

  return showDialog<String?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          autofocus: true,
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
          ),
        ),
        actions: options.entries
            .map(
              (option) => TextButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    option.key == TextFieldDialogButtonType.confirm
                        ? controller.text
                        : null,
                  );
                },
                child: Text(option.value),
              ),
            )
            .toList(),
      );
    },
  );
}
