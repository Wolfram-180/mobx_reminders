import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_reminders/auth/auth_error.dart';
import 'package:mobx_reminders/state/reminder.dart';
part 'app_state.g.dart';

class AppState = _AppState with _$AppState;

abstract class _AppState with Store {
  @observable
  AppScreen currentScreen = AppScreen.login;

  @observable
  bool isLoading = false;

  @observable
  User? currentUser;

  @observable
  AuthError? authError;

  @observable
  ObservableList<Reminder> reminders = ObservableList<Reminder>();

  @computed
  ObservableList<Reminder> get sortedReminders => ObservableList.of(
        reminders.sorted(),
      );

  @action
  void goTo(AppScreen screen) {
    currentScreen = screen;
  }

  @action
  Future<bool> delete(Reminder reminder) async {
    isLoading = true;
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) {
      isLoading = false;
      return false;
    } else {
      final userId = user.uid;
      final collection =
          await FirebaseFirestore.instance.collection(userId).get();

      try {
        // delete from firebase
        final firebaseReminder = collection.docs.firstWhere(
          (element) => element.id == reminder.id,
        );
        await firebaseReminder.reference.delete();

        // delete locally
        reminders.removeWhere(
          (element) => element.id == reminder.id,
        );
        return true;
      } catch (_) {
        return false;
      } finally {
        isLoading = false;
      }
    }
  }

  @action
  Future<bool> deleteAccount() async {
    isLoading = true;
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) {
      isLoading = false;
      return false;
    } else {
      final userId = user.uid;
      try {
        final store = FirebaseFirestore.instance;
        final operation = store.batch();
        final collection = await store.collection(userId).get();
        for (final document in collection.docs) {
          operation.delete(document.reference);
        }
        // delete all user`s documents
        await operation.commit();
        // user delete
        await user.delete();
        // log the user out
        await auth.signOut();
        currentScreen = AppScreen.login;
        return true;
      } on FirebaseAuthException catch (e) {
        authError = AuthError.from(e);
        return false;
      } catch (_) {
        return false;
      } finally {
        isLoading = false;
      }
    }
  }

  @action
  Future<void> logOut() async {
    isLoading = true;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // ignoring errors for sign out
    }
    isLoading = false;
    reminders.clear();
    currentScreen = AppScreen.login;
  }

  @action
  Future<bool> createReminder(String text) async {
    isLoading = true;
    // check user
    final userId = currentUser?.uid;
    if (userId == null) {
      isLoading = false;
      return false;
    }

    final creationDate = DateTime.now();

    // create firebase reminder
    final firebaseReminder =
        await FirebaseFirestore.instance.collection(userId).add(
      {
        _DocumentKeys.text: text,
        _DocumentKeys.creationDate: creationDate,
        _DocumentKeys.isDone: false,
      },
    );

    // create local reminder
    final reminder = Reminder(
      creationDate: creationDate,
      id: firebaseReminder.id,
      isDone: false,
      text: text,
    );

    reminders.add(reminder);
    isLoading = false;
    return true;
  }
}

abstract class _DocumentKeys {
  static const text = 'text';
  static const creationDate = 'creation_date';
  static const isDone = 'is_done';
}

typedef LoginOrRegisterFunction = Future<UserCredential> Function({
  required String email,
  required String password,
});

extension ToInt on bool {
  int toInt() => this ? 1 : 0;
}

extension Sorted on List<Reminder> {
  List<Reminder> sorted() => [...this]..sort(
      (lhs, rhs) {
        final isDone = lhs.isDone.toInt().compareTo(
              rhs.isDone.toInt(),
            );
        if (isDone != 0) return isDone;
        return lhs.creationDate.compareTo(rhs.creationDate);
      },
    );
}

enum AppScreen { login, register, reminders }
