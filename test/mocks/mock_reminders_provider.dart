import 'package:mobx_reminders/provider/reminders_provider.dart';
import 'package:mobx_reminders/state/reminder.dart';

import '../utils.dart';

final mockReminder1DateTime = DateTime(2024, 3, 3, 3, 3, 3, 3, 3);
const mockReminder1Id = '1';
const mockReminder1Text = 'Text1';
const mockReminder1IsDone = true;
final mockReminder1 = Reminder(
  id: mockReminder1Id,
  text: mockReminder1Text,
  creationDate: mockReminder1DateTime,
  isDone: mockReminder1IsDone,
  hasImage: false,
);

final mockReminder2DateTime = DateTime(2024, 2, 2, 2, 2, 2, 2, 2);
const mockReminder2Id = '2';
const mockReminder2Text = 'Text2';
const mockReminder2IsDone = false;
final mockReminder2 = Reminder(
  id: mockReminder2Id,
  text: mockReminder2Text,
  creationDate: mockReminder2DateTime,
  isDone: mockReminder2IsDone,
  hasImage: false,
);

final Iterable<Reminder> mockReminders = [
  mockReminder1,
  mockReminder2,
];

const mockReminderId = 'mockReminderId';

class MockRemindersProvider implements RemindersProvider {
  @override
  Future<ReminderId> createReminder({
    required String userId,
    required String text,
    required DateTime creationDate,
  }) =>
      mockReminderId.toFuture(oneSecond);

  @override
  Future<void> deleteAllDocuments({
    required String userId,
  }) =>
      Future.delayed(oneSecond);

  @override
  Future<void> deleteReminderWithId(
    ReminderId id, {
    required String userId,
  }) =>
      Future.delayed(oneSecond);

  @override
  Future<Iterable<Reminder>> loadReminders({
    required String userId,
  }) =>
      mockReminders.toFuture(oneSecond);

  @override
  Future<void> modify({
    required ReminderId reminderId,
    required bool isDone,
    required String userId,
  }) =>
      Future.delayed(oneSecond);
}
