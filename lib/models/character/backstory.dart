class Backstory {
  List<String> answers;

  Backstory(
      {this.answers});

  Backstory.fromJson(Map<String, dynamic> json) {
    json['backstory'].forEach((v) {
      this.answers.cast<String>();
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.answers != null) {
      data['backstory'] = this.answers.toList();
    }
    return data;
  }
}

class Answer {
  String id;
  String title;
  String description;
  String journal;

  Answer({
    this.id,
    this.title,
    this.description,
    this.journal
  });

  Answer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    journal = json['journal'];
  }
}