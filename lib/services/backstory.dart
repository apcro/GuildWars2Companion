import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import '../models/character/backstory.dart';
import '../utils/urls.dart';
import 'package:sprintf/sprintf.dart';

class BackstoryService {

  List<Backstory> _answers;

  Dio dio;

  BackstoryService({
    @required this.dio,
  });

  Future<List<Answer>> getBackstory(String characterName) async {

    final response = await dio.get(sprintf(Urls.backstoryUrl, characterName));

    if (response.statusCode == 200) {
      List answers = response.data;
      _answers = answers.map((a) => Backstory.fromJson(a)).toList();
      return getAnswers();
    }

    throw Exception();
  }

  Future<List<Answer>> getAnswers() async {
    List<String> answerList;
    _answers.forEach((answer) {
      answerList.add(answer.toString());
    });

    final response = await dio.get(Urls.answersUrl + Urls.combineStringIds(answerList));

    if (response.statusCode == 200) {
      List answerEntries = response.data;
      return answerEntries.map((a) => Answer.fromJson(a)).toList();
    }

    throw Exception();
  }
}
