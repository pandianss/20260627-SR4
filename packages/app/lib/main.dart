import 'dart:convert';
import 'package:flutter/material.dart' hide Card;
import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:domain/domain.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_layout.dart';
import 'theme/tokens.dart';
import 'services/notification_service.dart';
import 'services/telemetry_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime? _examDate;
  final String _examName = 'JAIIB';
  String _userId = 'dummy_user';
  String? _token;

  final ContentStore _contentStore = MemoryContentStore();
  final EventLogStore _eventStore = MemoryEventLogStore();
  final SrsStateStore _stateStore = MemorySrsStateStore();
  final NotificationService _notificationService = NotificationService();
  final TelemetryService _telemetryService = TelemetryService();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final startTime = DateTime.now();
    _initApp(startTime);
  }

  Future<void> _initApp(DateTime startTime) async {
    try {
      final jsonStr = await DefaultAssetBundle.of(context).loadString('assets/content_pack_jaiib.json');
      final Map<String, dynamic> pack = jsonDecode(jsonStr);
      final delta = ContentPackDelta.fromJson(pack);

      for (final exam in delta.exams) {
        await _contentStore.saveExam(exam);
      }
      for (final paper in delta.papers) {
        await _contentStore.savePaper(paper);
      }
      for (final mod in delta.modules) {
        await _contentStore.saveModule(mod);
      }
      for (final lesson in delta.lessons) {
        await _contentStore.saveLesson(lesson);
      }
      for (final q in delta.questions) {
        await _contentStore.saveQuestion(q);
      }
      for (final asset in delta.assets) {
        await _contentStore.saveAsset(asset);
      }
      for (final stimulus in delta.stimuli) {
        await _contentStore.saveStimulus(stimulus);
      }

      await _seedSrsStates(_stateStore);
    } catch (e, stack) {
      _telemetryService.logError(e, stack);
      debugPrint('Failed to load content pack: $e. Falling back to default mock seed.');
      await _seedMockData(_contentStore, _stateStore);
    } finally {
      final latency = DateTime.now().difference(startTime);
      _telemetryService.setBootLatency(latency);
      if (mounted) {
        setState(() {
          _loaded = true;
        });
      }
    }
  }

  Future<void> _seedSrsStates(SrsStateStore stateStore) async {
    final now = DateTime.now();
    final state1 = SrsState(
      stability: 1.0,
      difficulty: 3.0,
      due: now.subtract(const Duration(minutes: 5)),
      lastReview: now.subtract(const Duration(days: 1)),
      reps: 1,
      lapses: 0,
      phase: SrsPhase.review,
      userId: 'dummy_user',
      itemId: 'card_crr_concept',
      examContext: 'JAIIB',
    );
    await stateStore.saveState(state1);

    final state2 = SrsState(
      stability: 2.0,
      difficulty: 4.0,
      due: now.subtract(const Duration(minutes: 1)),
      lastReview: now.subtract(const Duration(days: 2)),
      reps: 1,
      lapses: 0,
      phase: SrsPhase.review,
      userId: 'dummy_user',
      itemId: 'card_slr_concept',
      examContext: 'JAIIB',
    );
    await stateStore.saveState(state2);
  }

  @override
  Widget build(BuildContext context) {
    final themeTokens = AppTokens.dark;

    if (!_loaded) {
      return MaterialApp(
        title: 'Calm Prep',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(themeTokens),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Set up deadline-aware scheduler if examDate is picked
    final Scheduler scheduler = DeadlineAwareScheduler(
      delegate: const Fsrs(),
      examDate: _examDate ?? DateTime.now().add(const Duration(days: 90)),
    );

    final examConfig = ExamConfig(
      examCode: _examName,
      papers: const [
        PaperConfig(
          paperCode: 'PPB',
          name: LocalizedString({'en': 'Principles & Practices of Banking'}),
          durationMin: 120,
          sections: [
            SectionConfig(
              code: 'ALL',
              count: 2,
              marksPerQuestion: 1,
              negativeMarks: 0,
            )
          ],
        )
      ],
      passRule: const PassRule(
        perComponentMin: 50,
        alternativeAggregate: AlternativeAggregate(perComponentMin: 45, aggregateMin: 50),
      ),
      gradingProfile: const GradingProfile(allowPartialDefault: false),
      mockBlueprints: const [
        MockBlueprint(
          id: 'bp_ppb_full',
          name: 'Principles & Practices of Banking - full mock',
          picks: [
            MockPick(
              topicTags: [],
              count: 2,
              difficultyMix: {1: 0.5, 2: 0.5},
            )
          ],
          shuffle: true,
          timingFromPaper: 'PPB',
        )
      ],
    );

    return MaterialApp(
      title: 'Calm Prep',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(themeTokens),
      home: _examDate == null
          ? OnboardingScreen(
              onComplete: (date, email, token) {
                setState(() {
                  _examDate = date;
                  _userId = email;
                  _token = token;
                });
              },
            )
          : MainLayout(
              examDate: _examDate!,
              examName: _examName,
              contentStore: _contentStore,
              eventStore: _eventStore,
              stateStore: _stateStore,
              scheduler: scheduler,
              userId: _userId,
              examConfig: examConfig,
              notificationService: _notificationService,
            ),
    );
  }
}

Future<void> _seedMockData(ContentStore contentStore, SrsStateStore stateStore) async {
  // 1. Seed Exam
  final exam = const Exam(
    id: 'ex_ppb',
    code: 'JAIIB',
    name: 'JAIIB Exam',
    body: 'Indian Institute of Banking and Finance',
    paperIds: ['p_ppb'],
  );
  await contentStore.saveExam(exam);

  // 2. Seed Paper
  final paper = const Paper(
    id: 'p_ppb',
    examCode: 'JAIIB',
    name: LocalizedString({'en': 'Principles & Practices of Banking'}),
    moduleIds: ['m_ppb_a'],
  );
  await contentStore.savePaper(paper);

  // 3. Seed Module
  final module = const Module(
    id: 'm_ppb_a',
    paperId: 'p_ppb',
    name: LocalizedString({'en': 'Module A: Indian Financial System'}),
    topicTags: ['crr', 'slr', 'banking'],
    lessonIds: ['les_ppb_crr'],
  );
  await contentStore.saveModule(module);

  // 4. Seed Lesson
  final lesson = const Lesson(
    id: 'les_ppb_crr',
    moduleId: 'm_ppb_a',
    title: LocalizedString({'en': 'Cash Reserve Ratio & Statutory Liquidity Ratio'}),
    cards: [
      Card(
        id: 'card_crr',
        kind: CardKind.concept,
        blocks: [
          TextBlock(LocalizedString({'en': 'The **Cash Reserve Ratio (CRR)** is the share of Net Demand and Time Liabilities (NDTL) that a bank must maintain as cash balance with the Reserve Bank of India (RBI). No interest is paid by the RBI on CRR balances.'})),
          FormulaBlock('CRR = \\frac{\\text{Cash with RBI}}{\\text{NDTL}} \\times 100\\%'),
        ],
        srsEligible: true,
      ),
      Card(
        id: 'card_slr',
        kind: CardKind.concept,
        blocks: [
          TextBlock(LocalizedString({'en': 'The **Statutory Liquidity Ratio (SLR)** is the minimum percentage of deposits that a commercial bank has to maintain in the form of liquid cash, gold, or other securities approved by the RBI.'})),
        ],
        srsEligible: true,
      ),
    ],
    probeQuestionIds: ['q_crr_1', 'q_crr_2'],
  );
  await contentStore.saveLesson(lesson);

  // 5. Seed Questions
  final q1 = const QuestionBase(
    id: 'q_crr_1',
    topicTags: ['crr'],
    difficulty: 1,
    gradingMode: GradingMode.autoExact,
    explanation: LocalizedString({'en': 'Under Section 42(1) of the RBI Act, 1934, banks are required to keep a certain percentage of NDTL as cash reserves with the RBI.'}),
    payload: McqSingle(
      stem: LocalizedString({'en': 'Which of the following describes the Cash Reserve Ratio (CRR)?'}),
      options: [
        QuestionOption(id: 'opt_1_a', content: LocalizedString({'en': 'Percentage of NDTL kept as cash with the RBI'})),
        QuestionOption(id: 'opt_1_b', content: LocalizedString({'en': 'Percentage of deposits kept as liquid assets with themselves'})),
      ],
      correctOptionId: 'opt_1_a',
    ),
  );
  await contentStore.saveQuestion(q1);

  final q2 = const QuestionBase(
    id: 'q_crr_2',
    topicTags: ['slr'],
    difficulty: 2,
    gradingMode: GradingMode.autoExact,
    explanation: LocalizedString({'en': 'Under Section 24 of the Banking Regulation Act, 1949, SLR can be maintained in gold, cash, or unencumbered approved securities.'}),
    payload: TrueFalse(
      stem: LocalizedString({'en': 'Statutory Liquidity Ratio (SLR) must only be maintained in cash reserves with the RBI.'}),
      answer: false,
    ),
  );
  await contentStore.saveQuestion(q2);

  // 6. Seed SRS states due today
  final now = DateTime.now();
  final state1 = SrsState(
    stability: 1.0,
    difficulty: 3.0,
    due: now.subtract(const Duration(minutes: 5)),
    lastReview: now.subtract(const Duration(days: 1)),
    reps: 1,
    lapses: 0,
    phase: SrsPhase.review,
    userId: 'dummy_user',
    itemId: 'card_crr',
    examContext: 'JAIIB',
  );
  await stateStore.saveState(state1);

  final state2 = SrsState(
    stability: 2.0,
    difficulty: 4.0,
    due: now.subtract(const Duration(minutes: 1)),
    lastReview: now.subtract(const Duration(days: 2)),
    reps: 1,
    lapses: 0,
    phase: SrsPhase.review,
    userId: 'dummy_user',
    itemId: 'card_slr',
    examContext: 'JAIIB',
  );
  await stateStore.saveState(state2);
}
