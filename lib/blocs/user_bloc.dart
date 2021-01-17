import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:one_spark/blocs/mentors_bloc.dart';
import 'package:one_spark/blocs/projects_bloc.dart';
import 'package:one_spark/models/project.dart';
import 'package:one_spark/models/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserBloc extends ChangeNotifier {
  String _name;
  String get name => _name;
  set setName(newName) => _name = newName;

  String _uid;
  String get uid => _uid;
  set setUid(newUid) => _uid = newUid;

  String _email;
  String get email => _email;
  set setEmail(newEmail) => _email = newEmail;

  String _photoUrl;
  String get photoUrl => _photoUrl;
  set setPhotoUrl(newPhotoUrl) => _photoUrl = newPhotoUrl;

  String _bio;
  String get bio => _bio;
  set setBio(newBio) => _bio = newBio;

  String _location;
  String get location => _location;
  set setLocation(newLocation) => _location = newLocation;

  String _position;
  String get position => _position;
  set setPosition(newPosition) => _position = newPosition;

  String _organization;
  String get organization => _organization;
  set setOrganization(newOrganization) => _organization = newOrganization;

  List _interests = [];
  List get interests => _interests;
  set setInterests(newInterests) => _interests = newInterests;

  List<UserModel> _inboxListMentor = [];
  List<UserModel> get inboxListMentor => _inboxListMentor;
  set setInboxList(newInboxList) => _inboxListMentor = newInboxList;

  List<Project> _inboxListProject = [];
  List<Project> get inboxListProject => _inboxListProject;
  set setInboxListProject(newInboxListProject) =>
      _inboxListProject = newInboxListProject;

  List<ListInboxItem> _inbox = [];
  List<ListInboxItem> get inbox => _inbox;
  set setInbox(List<ListInboxItem> newInbox) => _inbox = newInbox;

  UserBloc() {
    getUserFirestore();
  }

  getUserFirestore() async {
    final SharedPreferences localDb = await SharedPreferences.getInstance();
    String _userUid = localDb.getString('uid');
    try {
      await Firestore.instance
          .collection('users')
          .document(_userUid)
          .get()
          .then((DocumentSnapshot snap) {
        _uid = snap.data['uid'];
        _name = snap.data['displayName'];
        _email = snap.data['email'];
        _photoUrl = snap.data['photoUrl'];
        _interests = List.from(snap.data['interests']);
        _location = snap.data['location'];
        _organization = snap.data['organization'];
        _bio = snap.data['bio'];
        _position = snap.data['position'];
      });
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  getInboxMentorsList(context) async {
    final userBloc = Provider.of<UserBloc>(context);
    String userUid = userBloc.uid;

    _inboxListMentor.clear();
    try {
      final QuerySnapshot result =
          await Firestore.instance.collection('messages').getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      final mentorsBloc = Provider.of<MentorsBloc>(context);

      documents.forEach((element) {
        for (UserModel mentor in mentorsBloc.mentorsList) {
          if (element.documentID.contains(userUid) &&
              element.documentID.contains(mentor.uid) &&
              userUid != mentor.uid) {
            _inboxListMentor.add(mentor);
          } else
            print(element.data['displayName']);
        }
      });
      _inbox.addAll(_inboxListMentor);
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  getInboxProjectsList(context) async {
    final userBloc = Provider.of<UserBloc>(context);
    String userUid = userBloc.uid;

    _inboxListProject.clear();
    try {
      final QuerySnapshot result =
          await Firestore.instance.collection('messages').getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      final projectBloc = Provider.of<ProjectsBloc>(context);

      documents.forEach((element) {
        for (Project project in projectBloc.projectList) {
          String id1 = userUid + '-' + project.pid;
          String id2 = project.pid + '-' + userUid;

          if (element.documentID.contains(id1) ||
              element.documentID.contains(id2)) {
            _inboxListProject.add(project);
            print(project.pid);
          }
        }
      });

      _inbox.addAll(_inboxListProject);
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }
}

abstract class ListInboxItem {
  String get name;

  String get photoUrl;
  String get id;

  Widget buildTitle(BuildContext context);

  Widget buildImage(BuildContext context);
}
