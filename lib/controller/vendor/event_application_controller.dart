import 'package:get/get.dart';
import 'package:vendor/model/event.dart';

class EventApplicationController extends GetxController {
  var questions = <Question>[].obs;

  // Initialize the questions list
  void setQuestions(List<Question> questionList) {
    questions.assignAll(questionList);
  }

  // Update answer in a specific question
  void updateAnswer(int index, String answer) {
    questions[index].answer = answer;
    questions.refresh(); // Notify listeners to update UI
  }

  // Check if all questions are answered
  bool areAllQuestionsAnswered() {
    return questions.every((q) => q.answer.isNotEmpty);
  }

  // Get the list of answered questions (if needed)
  List<Question> getAnsweredQuestions() {
    return questions.where((q) => q.answer.isNotEmpty).toList();
  }
}
