import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
          _updateGroupsCollection(updatedUserData);
        }
      }
    });
  }

  void destroyUserListener() {
    listener.cancel();
  }

  void _updateGroupsCollection(Map<String, dynamic> updatedUserData) async{
    _db.collection('groups')
      .get()
      .then((QuerySnapshot snapshot) {
        List<QueryDocumentSnapshot> matchingDocuments = snapshot.docs
          .where((documentSnapshot) {
              final data = documentSnapshot.data() as Map<String,dynamic>;
              return data['members'] != null && data['members'].any((member) => member['email'] == updatedUserData['email']);
            })
          .toList();

        for (QueryDocumentSnapshot documentSnapshot in matchingDocuments) {
          print('Matching document ID: ${documentSnapshot.id}');
          print('Document data: ${documentSnapshot.data()}');
          final documentData = documentSnapshot.data() as Map<String, dynamic>;

          if (documentData['owner']['email'] == updatedUserData['email']) {
            documentData['owner']['display_name'] = updatedUserData['display_name'];
            documentData['owner']['email'] = updatedUserData['email'];
            documentData['owner']['username'] = updatedUserData['username'];
            documentData['owner']['username_created_at'] = updatedUserData['username_created_at'];
          }

          documentData['members'].forEach((element) {
            if (element['email'] == updatedUserData['email']) {
              element['display_name'] = updatedUserData['display_name'];
              element['email'] = updatedUserData['email'];
              element['username'] = updatedUserData['username'];
              element['username_created_at'] = updatedUserData['username_created_at'];
            }
          });
          _db.collection('groups').doc(documentSnapshot.id).update(documentData);
        }
    }, onError: (error) {
      print(error);
    });
  }

  void _updateFriendCollection(Map<String, dynamic> updatedUserData) {
    if (updatedUserData['email'] == null) {
      return;
    }

    _db.collection('friends')
      .where('to.email', isEqualTo: updatedUserData['email'])
      .get()
      .then((QuerySnapshot snapshot) {
        for (var doc in snapshot.docs) {
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
      }
    }, onError: (error) {
      print(error);
    });
    _db.collection('friends')
      .where('from.email', isEqualTo: updatedUserData['email'])
      .get()
      .then((QuerySnapshot snapshot) {
        for (var doc in snapshot.docs) {
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
      }
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
    DateTime? updated_at,
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

    if (updated_at != null){
      temp['updated_at'] = updated_at;
    }

    await _db.collection('groups').doc(idDocument).set(temp, SetOptions(merge: true));
  }

  Future<void> removeFriendFromDatabase(String idDocument) async {
    await _db.collection('friends').doc(idDocument).delete();
  }

  Future deleteGroup(String idDocument) async {
    await _db.collection('groups').doc(idDocument).delete();
  }

  Future<String?> findGroupIdByElement(Map<String, dynamic> groupElement) async {
    final querySnapshot = await _db.collection('groups')
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.data().toString() == groupElement.toString()) {
        return doc.id;
      }
    }

    return null;
  }

  Future leaveGroup({String? idDocument, String? email}) async {
    if (idDocument == null || email == null) {
      return;
    }

    final querySnapshot = await _db.collection('groups')
        .doc(idDocument)
        .get();

    if (querySnapshot.exists) {
      final groupData = querySnapshot.data() as Map<String, dynamic>;

      final members = groupData['members'] as List<dynamic>;
      final owner = groupData['owner'] as Map<String, dynamic>;

      members.removeWhere((element) => element['email'] == email);
      if (owner['email'] == email) {
        await _db.collection('groups').doc(idDocument).update({
          'owner': members[0],
          'members': members
        });
      } else {
        await _db.collection('groups').doc(idDocument).update({
          'members': members
        });
      }
    }
  }
}
