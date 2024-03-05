import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx_reminders/dialogs/delete_reminder_dialog.dart';
import 'package:mobx_reminders/dialogs/show_textfield_dialog.dart';
import 'package:mobx_reminders/state/app_state.dart';
import 'package:mobx_reminders/views/main_popup_menu_button.dart';
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
      body: const ReminderListView(),
    );
  }
}

class ReminderListView extends StatelessWidget {
  const ReminderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Observer(
      builder: (context) {
        return ListView.builder(
          itemCount: appState.sortedReminders.length,
          itemBuilder: (context, index) {
            final reminder = appState.sortedReminders[index];
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: reminder.isDone,
              onChanged: (isDone) {
                context.read<AppState>().modify(
                      reminder,
                      isDone: isDone ?? false,
                    );
                // reminder.isDone = isDone ?? false;
              },
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      reminder.text,
                      style: TextStyle(
                        decoration: reminder.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final showDeleteReminder =
                          await showDeleteReminderDialog(context);
                      if (showDeleteReminder) {
                        context.read<AppState>().delete(reminder);
                      }
                    },
                    icon: const Icon(
                      Icons.delete,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
