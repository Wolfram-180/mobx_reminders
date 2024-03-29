import 'dart:typed_data';

import 'package:mobx_reminders/services/reminders_service.dart';
import 'package:mobx_reminders/state/reminder.dart';

import '../utils.dart';

final mockReminder1DateTime = DateTime(2024, 3, 3, 3, 3, 3, 3, 3);
const mockReminder1Id = '1';
const mockReminder1Text = 'Text1';
const mockReminder1IsDone = true;
final mockReminder1ImageData = 'image1'.toUint8List();
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
final mockReminder2ImageData = 'image2'.toUint8List();
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

class MockRemindersService implements RemindersService {
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

  @override
  Future<Uint8List?> getReminderImage({
    required ReminderId reminderId,
    required String userId,
  }) async {
    switch (reminderId) {
      case mockReminder1Id:
        return mockReminder1ImageData;
      case mockReminder2Id:
        return mockReminder2ImageData;
      default:
        return null;
    }
  }

  @override
  Future<void> setReminderHasImage({
    required ReminderId reminderId,
    required String userId,
  }) async {
    mockReminders
        .firstWhere(
          (element) => element.id == reminderId,
        )
        .hasImage = true;
  }
}
