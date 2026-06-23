import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:domain/domain.dart';

/// Development/demo seeding for the pilot build. Not part of any production
/// data flow. All card ids match the canonical content pack
/// (content/src/jaiib) so the Review tab resolves seeded items whether the
/// real pack loads or the fallback content is used.
class DevSeed {
  DevSeed._();

  static const lessonId = 'les_ppb_crr';
  static const crrCard = 'card_crr_concept';
  static const slrCard = 'card_slr_concept';

  /// Seed a couple of due reviews for [userId] so the Review tab isn't empty on
  /// first launch. Called after onboarding, when the real user id is known
  /// (the previous seed keyed reviews to a placeholder id that never matched
  /// the onboarded user).
  static Future<void> seedDueReviews(
      SrsStateStore stateStore, String userId) async {
    final now = DateTime.now();
    await stateStore.saveState(
        _dueState(userId, crrCard, now, overdueMinutes: 5, stability: 1));
    await stateStore.saveState(
        _dueState(userId, slrCard, now, overdueMinutes: 1, stability: 2));
  }

  /// Fallback content, used only when the real content pack fails to load.
  /// Internally consistent and id-aligned with the canonical pack.
  static Future<void> seedFallbackContent(ContentStore contentStore) async {
    await contentStore.saveExam(const Exam(
      id: 'ex_ppb',
      code: 'JAIIB',
      name: 'JAIIB',
      body: 'Indian Institute of Banking and Finance',
      paperIds: ['p_ppb'],
    ));
    await contentStore.savePaper(const Paper(
      id: 'p_ppb',
      examCode: 'JAIIB',
      name: LocalizedString({'en': 'Principles & Practices of Banking'}),
      moduleIds: ['m_ppb_a'],
    ));
    await contentStore.saveModule(const Module(
      id: 'm_ppb_a',
      paperId: 'p_ppb',
      name: LocalizedString({'en': 'Module A: Indian financial system'}),
      topicTags: ['crr', 'slr'],
      lessonIds: [lessonId],
    ));
    await contentStore.saveLesson(const Lesson(
      id: lessonId,
      moduleId: 'm_ppb_a',
      title: LocalizedString({'en': 'Cash reserve ratio & SLR'}),
      cards: [
        Card(
          id: crrCard,
          kind: CardKind.concept,
          srsEligible: true,
          blocks: [
            TextBlock(LocalizedString({
              'en':
                  'The **Cash Reserve Ratio (CRR)** is the share of deposits a bank must keep as cash with the RBI.'
            })),
          ],
        ),
        Card(
          id: slrCard,
          kind: CardKind.concept,
          srsEligible: true,
          blocks: [
            TextBlock(LocalizedString({
              'en':
                  'The **Statutory Liquidity Ratio (SLR)** is the share of deposits a bank must hold in liquid assets within the bank.'
            })),
          ],
        ),
      ],
      probeQuestionIds: ['q_crr_holder', 'q_slr_assets'],
    ));
    await contentStore.saveQuestion(const QuestionBase(
      id: 'q_crr_holder',
      topicTags: ['crr'],
      difficulty: 1,
      gradingMode: GradingMode.autoExact,
      explanation:
          LocalizedString({'en': 'CRR is a cash balance kept with the RBI.'}),
      payload: McqSingle(
        stem: LocalizedString({'en': 'Where does a bank keep its CRR balance?'}),
        options: [
          QuestionOption(
              id: 'a', content: LocalizedString({'en': 'As cash with the RBI'})),
          QuestionOption(
              id: 'b', content: LocalizedString({'en': 'In its own vault'})),
        ],
        correctOptionId: 'a',
      ),
    ));
    await contentStore.saveQuestion(const QuestionBase(
      id: 'q_slr_assets',
      topicTags: ['slr'],
      difficulty: 2,
      gradingMode: GradingMode.autoExact,
      explanation: LocalizedString(
          {'en': 'SLR is held in liquid assets such as government securities.'}),
      payload: TrueFalse(
        stem: LocalizedString(
            {'en': 'SLR must be kept only as cash with the RBI.'}),
        answer: false,
      ),
    ));
  }

  static SrsState _dueState(String userId, String itemId, DateTime now,
      {required int overdueMinutes, required double stability}) {
    return SrsState(
      stability: stability,
      difficulty: 3.0,
      due: now.subtract(Duration(minutes: overdueMinutes)),
      lastReview: now.subtract(const Duration(days: 1)),
      reps: 1,
      lapses: 0,
      phase: SrsPhase.review,
      userId: userId,
      itemId: itemId,
      examContext: 'JAIIB',
    );
  }
}
