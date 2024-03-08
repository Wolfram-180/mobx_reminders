import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx_reminders/dialogs/delete_reminder_dialog.dart';
import 'package:mobx_reminders/state/app_state.dart';
import 'package:provider/provider.dart';

class RemindersListView extends StatelessWidget {
  const RemindersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Observer(
      builder: (context) {
        return ListView.builder(
          itemCount: appState.sortedReminders.length,
          itemBuilder: (context, index) {
            final reminder = appState.sortedReminders[index];
            return Observer(builder: (context) {
              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: reminder.isDone,
                onChanged: (isDone) {
                  context.read<AppState>().modifyReminder(
                        reminderId: reminder.id,
                        isDone: isDone ?? false,
                      );
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
            });
          },
        );
      },
    );
  }
}
