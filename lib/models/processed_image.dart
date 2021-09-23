class ProcessedImage {
  String? s0;

  ProcessedImage({required this.s0});

  ProcessedImage.fromJson(Map<String, dynamic> json) {
    s0 = json['0'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['0'] = s0;
    return data;
  }
}
