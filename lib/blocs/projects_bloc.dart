import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_spark/models/project.dart';

class ProjectsBloc extends ChangeNotifier {
  List<Project> _projectList = [];
  set projectList(newValue) => _projectList = newValue;
  List<Project> get projectList => _projectList;

  ProjectsBloc() {
    getProjectList();
  }

  Future getProjectList() async {
    _projectList.clear();

    final QuerySnapshot result =
        await Firestore.instance.collection('projects').getDocuments();
    final List documents = result.documents;

    documents.forEach((element) {
      _projectList.add(Project.fromMapProject(element.data));
    });

    _projectList.sort((a, b) => a.name.compareTo(b.name));

    notifyListeners();
  }
}
