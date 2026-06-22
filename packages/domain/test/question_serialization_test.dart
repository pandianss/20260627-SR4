import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:test/test.dart';

/// Re-parsing a question's own JSON must reproduce identical JSON.
Map<String, dynamic> _reparse(QuestionBase q) =>
    jsonDecode(jsonEncode(q.toJson())) as Map<String, dynamic>;

void main() {
  group('Question serialization round-trips', () {
    test('mcq_single (JAIIB: where is CRR held)', () {
      final json = {
        'id': 'q_crr_holder',
        'version': 1,
        'topicTags': ['ppb.reserves', 'ppb.crr'],
        'difficulty': 1,
        'gradingMode': 'auto_exact',
        'defaultMarks': 1,
        'defaultNegativeMarks': 0,
        'explanation': {'en': 'CRR is a cash balance maintained with the RBI.'},
        'payload': {
          'type': 'mcq_single',
          'stem': {'en': 'Where does a bank keep its CRR balance?'},
          'options': [
            {'id': 'a', 'content': {'en': 'As cash in its own vault'}},
            {'id': 'b', 'content': {'en': 'With the Reserve Bank of India'}},
            {'id': 'c', 'content': {'en': 'In government securities'}},
          ],
          'correctOptionId': 'b',
        },
      };
      final q = QuestionBase.fromJson(json);
      expect(q.payload, isA<McqSingle>());
      expect((q.payload as McqSingle).correctOptionId, 'b');
      expect(_reparse(q), equals(q.toJson()));
    });

    test('caselet: passage_ref -> numeric (JAIIB CRR amount)', () {
      final json = {
        'id': 'cs_crr_q1',
        'gradingMode': 'auto_numeric',
        'stimulusId': 'cs_crr_caselet',
        'explanation': {'en': '4.5% of 100 cr = 4.5 cr.'},
        'payload': {
          'type': 'passage_ref',
          'innerType': 'numeric',
          'inner': {
            'type': 'numeric',
            'stem': {'en': 'How much must it keep with the RBI?'},
            'answer': {'value': 4.5, 'unit': '₹ cr'},
            'tolerance': {'kind': 'absolute', 'amount': 0.01},
          },
        },
      };
      final q = QuestionBase.fromJson(json);
      final pr = q.payload as PassageRef;
      expect(pr.inner, isA<NumericEntry>());
      expect((pr.inner as NumericEntry).answerValue, 4.5);
      expect((pr.inner as NumericEntry).unit, '₹ cr');
      expect(q.stimulusId, 'cs_crr_caselet');
      expect(_reparse(q), equals(q.toJson()));
    });

    test('numeric_multistep (CAIIB expected loss)', () {
      final json = {
        'id': 'ms_el_calc',
        'gradingMode': 'auto_numeric',
        'explanation': {'en': 'PD x EAD = 10; x LGD 45% = 4.5.'},
        'payload': {
          'type': 'numeric_multistep',
          'stem': {'en': 'Work out the expected loss.'},
          'steps': [
            {'id': 's1', 'prompt': {'en': 'PD x EAD?'}, 'answer': 10, 'tolerance': 0.01},
            {
              'id': 's2',
              'prompt': {'en': 'Apply LGD of 45%?'},
              'answer': 4.5,
              'tolerance': 0.01,
              'hint': {'en': '45% of the previous answer.'},
            },
          ],
        },
      };
      final q = QuestionBase.fromJson(json);
      final ms = q.payload as NumericMultiStep;
      expect(ms.steps, hasLength(2));
      expect(ms.steps[1].hint?.resolve('en'), contains('45%'));
      expect(_reparse(q), equals(q.toJson()));
    });

    test('match_pairs round-trips with mapping', () {
      final q = QuestionBase(
        id: 'q_match',
        gradingMode: GradingMode.autoExact,
        explanation: LocalizedString({'en': 'Match each ratio to where it is held.'}),
        payload: MatchPairs(
          stem: LocalizedString({'en': 'Match the ratio to its custodian.'}),
          left: [
            QuestionOption(id: 'l1', content: LocalizedString({'en': 'CRR'})),
            QuestionOption(id: 'l2', content: LocalizedString({'en': 'SLR'})),
          ],
          right: [
            QuestionOption(id: 'r1', content: LocalizedString({'en': 'With the RBI'})),
            QuestionOption(id: 'r2', content: LocalizedString({'en': 'With the bank'})),
          ],
          correct: {'l1': 'r1', 'l2': 'r2'},
          partialCredit: PartialCredit.perPair,
        ),
      );
      expect(_reparse(q), equals(q.toJson()));
    });
  });
}
