import 'package:flutter_test/flutter_test.dart';
import 'package:mobx_reminders/state/app_state.dart';

import 'mocks/mock_auth_service.dart';
import 'mocks/mock_image_upload_service.dart';
import 'mocks/mock_reminders_service.dart';

void main() {
  late AppState appState;
  setUp(
    () {
      appState = AppState(
        authService: MockAuthService(),
        remindersService: MockRemindersService(),
        imageUploadService: MockImageUploadService(),
      );
    },
  );

  test(
    'initial state',
    () {
      expect(
        appState.currentScreen,
        AppScreen.login,
      );
      expect(
        appState.authError,
        null,
      );
      expect(
        appState.isLoading,
        false,
      );
      expect(
        appState.reminders.isEmpty,
        true,
      );
    },
  );

  test(
    'going to screens',
    () {
      appState.goTo(AppScreen.register);
      expect(
        appState.currentScreen,
        AppScreen.register,
      );
      appState.goTo(AppScreen.reminders);
      expect(
        appState.currentScreen,
        AppScreen.reminders,
      );
      appState.goTo(AppScreen.login);
      expect(
        appState.currentScreen,
        AppScreen.login,
      );
    },
  );

  test(
    'initializing the app state',
    () async {
      await appState.initialize();
      expect(
        appState.currentScreen,
        AppScreen.reminders,
      );
      // reminders should be loaded
      expect(
        appState.reminders.length,
        mockReminders.length,
      );
      expect(
        appState.reminders.contains(
          mockReminder1,
        ),
        true,
      );
      expect(
        appState.reminders.contains(
          mockReminder2,
        ),
        true,
      );
    },
  );

  test(
    'modifying reminders',
    () async {
      await appState.initialize();
      await appState.modifyReminder(
        reminderId: mockReminder1Id,
        isDone: false,
      );
      await appState.modifyReminder(
        reminderId: mockReminder2Id,
        isDone: true,
      );
      final reminder1 = appState.reminders.firstWhere(
        (reminder) => reminder.id == mockReminder1Id,
      );
      final reminder2 = appState.reminders.firstWhere(
        (reminder) => reminder.id == mockReminder2Id,
      );
      expect(
        reminder1.isDone,
        false,
      );
      expect(
        reminder2.isDone,
        true,
      );
    },
  );

  test(
    'creating reminders',
    () async {
      await appState.initialize();
      const text = 'text';
      final didCreate = await appState.createReminder(
        text,
      );
      expect(
        didCreate,
        true,
      );
      expect(
        appState.reminders.length,
        mockReminders.length + 1,
      );

      // checking new reminder
      final testReminder = appState.reminders.firstWhere(
        (element) => element.id == mockReminderId,
      );
      expect(
        testReminder.text,
        text,
      );
      expect(
        testReminder.isDone,
        false,
      );
    },
  );

  test(
    'deleting reminders',
    () async {
      await appState.initialize();
      final count = appState.reminders.length;
      final reminder = appState.reminders.first;
      final deleted = await appState.delete(reminder);
      expect(
        deleted,
        true,
      );
      expect(
        appState.reminders.length,
        count - 1,
      );
    },
  );

  test(
    'deleting account',
    () async {
      await appState.initialize();
      final couldDeleteAccount = await appState.deleteAccount();
      expect(
        couldDeleteAccount,
        true,
      );
      expect(
        appState.reminders.isEmpty,
        true,
      );
      expect(
        appState.currentScreen,
        AppScreen.login,
      );
    },
  );

  test(
    'logging out',
    () async {
      await appState.initialize();
      await appState.logOut();
      expect(
        appState.reminders.isEmpty,
        true,
      );
      expect(
        appState.currentScreen,
        AppScreen.login,
      );
    },
  );
}
