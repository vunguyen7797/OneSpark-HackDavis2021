import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:one_spark/blocs/user_bloc.dart';
import 'package:provider/provider.dart';

class ProjectFeedsBloc extends ChangeNotifier {
  String date;
  String timestamp;

  List _data;
  set data(newData) => _data = newData;
  List get data => _data;

  Future<void> getFeedsData(id) async {
    QuerySnapshot snap = await Firestore.instance
        .collection('projects/$id/feeds')
        .getDocuments();
    var x = snap.documents;
    List temp = [];

    x.forEach((f) {
      temp.add(f);
    });

    temp.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    data = temp;
    print('FEEDS : ${data.length}');
    notifyListeners();
  }

  Future saveNewFeeds(projectId, feed, context) async {
    final userBloc = Provider.of<UserBloc>(context);
    String _uid = userBloc.uid;
    String _name = userBloc.name;
    String _imageUrl = userBloc.photoUrl;

    await _getDate().then((_) {
      Firestore.instance
          .collection('projects/$projectId/feeds')
          .document('$_uid$timestamp')
          .setData({
        'name': _name,
        'feed': feed,
        'date': date,
        'photoUrl': _imageUrl,
        'timestamp': timestamp,
        'uid': _uid,
      });
    });

    getFeedsData(projectId);
  }

  Future _getDate() async {
    DateTime now = DateTime.now();
    String _date = DateFormat('dd MMMM yyyy').format(now);
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    date = _date;
    timestamp = _timestamp;
  }
}
