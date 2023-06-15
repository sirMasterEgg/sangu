import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreManager {
  late FirebaseFirestore _db;

  FirestoreManager() {
    _db = FirebaseFirestore.instance;
    // _db.settings = const Settings(
    //   persistenceEnabled: true,
    //   cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    // );
  }

  FirebaseFirestore getInstance() {
    return _db;
  }

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> listener;

  void setUserListener () {
    listener = _db.collection('users').snapshots().listen((event) {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.modified){
          Map<String, dynamic> updatedUserData = change.doc.data() ?? {'email': null};

          _updateFriendCollection(updatedUserData);
        }
      }
    });
  }

  void destroyUserListener() {
    listener.cancel();
  }

  void _updateFriendCollection(Map<String, dynamic> updatedUserData) {
    if (updatedUserData['email'] == null) {
      return;
    }

    _db.collection('friends')
      .where('to.email', isEqualTo: updatedUserData['email'])
      .get()
      .then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((DocumentSnapshot doc) {
          Map<String, dynamic> friendData = doc.data() as Map<String, dynamic>;

          friendData['to']['email'] = updatedUserData['email'];
          friendData['to']['display_name'] = updatedUserData['display_name'];
          friendData['to']['username'] = updatedUserData['username'];
          friendData['to']['username_created_at'] = updatedUserData['username_created_at'];

          // Perform the update in the friend collection
          FirebaseFirestore.instance
              .collection('friends')
              .doc(doc.id)
              .update(friendData);
      });
    }, onError: (error) {
      print(error);
    });
    _db.collection('friends')
      .where('from.email', isEqualTo: updatedUserData['email'])
      .get()
      .then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((DocumentSnapshot doc) {
          Map<String, dynamic> friendData = doc.data() as Map<String, dynamic>;

          friendData['from']['email'] = updatedUserData['email'];
          friendData['from']['display_name'] = updatedUserData['display_name'];
          friendData['from']['username'] = updatedUserData['username'];
          friendData['from']['username_created_at'] = updatedUserData['username_created_at'];

          // Perform the update in the friend collection
          FirebaseFirestore.instance
              .collection('friends')
              .doc(doc.id)
              .update(friendData);
      });
    }, onError: (error) {
      print(error);
    });
  }

  Future updateSelectedUser (
      String idDocument, {
        String? display_name,
        String? email,
        String? username,
        DateTime? username_created_at
      }) async {
    Map<String, dynamic> builder = {};
    if (display_name != null) {
      builder['display_name'] = display_name;
    }
    if (email != null) {
      builder['email'] = email;
    }
    if (username != null) {
      builder['username'] = username;
    }
    if (username_created_at != null) {
      builder['username_created_at'] = username_created_at;
    }

    try {
      await _db.collection('users')
          .doc(idDocument)
          .update(builder);
    } catch (_){
      await _db.collection('users')
          .doc(idDocument)
          .set(builder, SetOptions(merge: true));
    }
  }

  Future updateFriend(String idDocument, {
    dynamic from,
    dynamic to,
    int? status,
  }) async {
    Map<String, dynamic> temp = {};

    if (from != null){
      temp['from'] = from;
    }
    if (to != null){
      temp['to'] = to;
    }
    if (status != null){
      temp['status'] = status;
    }

    await _db.collection('friends').doc(idDocument).set(temp, SetOptions(merge: true));

  }

  Future updateGroup (String idDocument, {
    String? name,
    List<dynamic>? members,
    dynamic owner,
    DateTime? created_at,
  }) async {
    Map<String, dynamic> temp = {};

    if (name != null){
      temp['name'] = name;
    }

    if (members != null){
      temp['members'] = members;
    }
    if (owner != null){
      temp['owner'] = owner;
    }

    if (created_at != null){
      temp['created_at'] = created_at;
    }

    await _db.collection('groups').doc(idDocument).set(temp, SetOptions(merge: true));
  }
}