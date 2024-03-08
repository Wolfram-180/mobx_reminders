import 'package:flutter/material.dart';
import 'package:mobx_reminders/dialogs/show_textfield_dialog.dart';
import 'package:mobx_reminders/state/app_state.dart';
import 'package:mobx_reminders/views/main_popup_menu_button.dart';
import 'package:mobx_reminders/views/reminders_list_view.dart';
import 'package:provider/provider.dart';

class RemindersView extends StatelessWidget {
  const RemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            onPressed: () async {
              final reminderText = await showTextFieldDialog(
                context: context,
                title: 'What do you want to be reminded of?',
                hintText: 'Enter your reminder here',
                optionsBuilder: () => {
                  TextFieldDialogButtonType.cancel: 'Cancel',
                  TextFieldDialogButtonType.confirm: 'Save',
                },
              );
              if (reminderText == null) {
                return;
              }
              context.read<AppState>().createReminder(reminderText);
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
          const MainPopupMenuButton(),
        ],
      ),
      body: const RemindersListView(),
    );
  }
}
