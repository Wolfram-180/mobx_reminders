import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx_reminders/state/reminder.dart';

typedef ReminderId = String;

abstract class RemindersService {
  Future<void> deleteReminderWithId(
    ReminderId id, {
    required String userId,
  });

  Future<void> deleteAllDocuments({
    required String userId,
  });

  Future<ReminderId> createReminder({
    required String userId,
    required String text,
    required DateTime creationDate,
  });

  Future<void> modify({
    required ReminderId reminderId,
    required bool isDone,
    required String userId,
  });

  Future<Iterable<Reminder>> loadReminders({
    required String userId,
  });

  Future<void> setReminderHasImage({
    required ReminderId reminderId,
    required String userId,
  });

  Future<Uint8List?> getReminderImage({
    required ReminderId reminderId,
    required String userId,
  });
}

class FirestoreRemindersService implements RemindersService {
  @override
  Future<ReminderId> createReminder({
    required String userId,
    required String text,
    required DateTime creationDate,
  }) async {
    final creationDate = DateTime.now();

    // create firebase reminder
    final firebaseReminder =
        await FirebaseFirestore.instance.collection(userId).add(
      {
        _DocumentKeys.text: text,
        _DocumentKeys.creationDate: creationDate.toIso8601String(),
        _DocumentKeys.isDone: false,
        _DocumentKeys.hasImage: false,
      },
    );

    return firebaseReminder.id;
  }

  @override
  Future<void> deleteAllDocuments({
    required String userId,
  }) async {
    final store = FirebaseFirestore.instance;
    final operation = store.batch();
    final collection = await store.collection(userId).get();
    for (final document in collection.docs) {
      operation.delete(document.reference);

      // delete image assigned with that reminder
      try {
        await FirebaseStorage.instance.ref(userId).child(document.id).delete();
      } catch (e) {
        // not handling exceptions for now
      }
    }
    // commit for delete all user`s documents
    await operation.commit();
  }

  @override
  Future<void> deleteReminderWithId(
    ReminderId id, {
    required String userId,
  }) async {
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();

    // delete from firebase
    final firebaseReminder = collection.docs.firstWhere(
      (element) => element.id == id,
    );
    await firebaseReminder.reference.delete();

    // delete image assigned with that reminder
    try {
      await FirebaseStorage.instance
          .ref(userId)
          .child(firebaseReminder.id)
          .delete();
    } catch (e) {
      // not handling exceptions for now
    }
  }

  @override
  Future<Iterable<Reminder>> loadReminders({
    required String userId,
  }) async {
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();

    final reminders = collection.docs.map(
      (doc) => Reminder(
        id: doc.id,
        creationDate: DateTime.parse(doc[_DocumentKeys.creationDate] as String),
        isDone: doc[_DocumentKeys.isDone] as bool,
        text: doc[_DocumentKeys.text] as String,
        hasImage: doc[_DocumentKeys.hasImage] as bool,
      ),
    );
    return reminders;
  }

  @override
  Future<void> _modify({
    required ReminderId reminderId,
    required String userId,
    required Map<String, Object?> keyValues,
  }) async {
    // update the remote reminder
    final collection =
        await FirebaseFirestore.instance.collection(userId).get();

    final firebaseReminder = collection.docs
        .where((element) => element.id == reminderId)
        .first
        .reference;

    await firebaseReminder.update(
      keyValues,
    );
  }

  @override
  Future<void> modify({
    required String userId,
    required ReminderId reminderId,
    required bool isDone,
  }) =>
      _modify(
        reminderId: reminderId,
        userId: userId,
        keyValues: {
          _DocumentKeys.isDone: isDone,
        },
      );

  @override
  Future<Uint8List?> getReminderImage({
    required ReminderId reminderId,
    required String userId,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref(userId).child(reminderId);
      final data = await ref.getData();
      return data;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setReminderHasImage({
    required ReminderId reminderId,
    required String userId,
  }) =>
      _modify(
        reminderId: reminderId,
        userId: userId,
        keyValues: {
          _DocumentKeys.hasImage: true,
        },
      );
}

abstract class _DocumentKeys {
  static const text = 'text';
  static const creationDate = 'creation_date';
  static const isDone = 'is_done';
  static const hasImage = 'has_image';
}
