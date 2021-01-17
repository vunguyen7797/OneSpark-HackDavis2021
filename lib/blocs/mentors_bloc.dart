import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:one_spark/models/user.dart';

class MentorsBloc extends ChangeNotifier {
  List<UserModel> _mentorsList = [];
  List<UserModel> get mentorsList => _mentorsList;
  set mentorsList(newMentorsList) => _mentorsList = newMentorsList;

  MentorsBloc() {
    getMentorsFirestore();
  }

  Future getMentorsFirestore() async {
    _mentorsList.clear();

    final QuerySnapshot result =
        await Firestore.instance.collection('users').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    documents.forEach((element) {
      if (List.from(element.data['role']).contains('Mentor'))
        _mentorsList.add(UserModel.fromMapUser(element.data));
    });

    _mentorsList.sort((a, b) => a.displayName.compareTo(b.displayName));

    print('Mentor list: ${_mentorsList.length}');
    notifyListeners();
  }
}
