/// A learner's answer to a question. Sealed so the grader dispatches on a
/// single discriminant, mirroring the question-type union in `domain`.
sealed class Response {
  const Response();

  String get type;
  Map<String, dynamic> toJson();

  factory Response.fromJson(Map<String, dynamic> j) {
    final t = j['type'] as String;
    return switch (t) {
      'mcq' => McqResponse(j['optionId'] as String),
      'true_false' => TrueFalseResponse(j['value'] as bool),
      'match' => MatchResponse((j['mapping'] as Map)
          .map((k, v) => MapEntry(k.toString(), v.toString()))),
      'numeric' => NumericResponse((j['value'] as num).toDouble()),
      'multistep' => MultiStepResponse((j['steps'] as Map)
          .map((k, v) => MapEntry(k.toString(), (v as num).toDouble()))),
      'passage' => PassageResponse(
          Response.fromJson((j['inner'] as Map).cast<String, dynamic>())),
      _ => throw FormatException('Unknown response type: $t'),
    };
  }
}

class McqResponse extends Response {
  final String optionId;
  const McqResponse(this.optionId);
  @override
  String get type => 'mcq';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'optionId': optionId};
}

class TrueFalseResponse extends Response {
  final bool value;
  const TrueFalseResponse(this.value);
  @override
  String get type => 'true_false';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}

class MatchResponse extends Response {
  final Map<String, String> mapping; // leftId -> rightId
  const MatchResponse(this.mapping);
  @override
  String get type => 'match';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'mapping': mapping};
}

class NumericResponse extends Response {
  final double value;
  const NumericResponse(this.value);
  @override
  String get type => 'numeric';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}

class MultiStepResponse extends Response {
  final Map<String, double> steps; // stepId -> value
  const MultiStepResponse(this.steps);
  @override
  String get type => 'multistep';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'steps': steps};
}

class PassageResponse extends Response {
  final Response inner;
  const PassageResponse(this.inner);
  @override
  String get type => 'passage';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'inner': inner.toJson()};
}
