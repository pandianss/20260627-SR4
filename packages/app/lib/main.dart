import 'dart:convert';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart' show rootBundle;
import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:domain/domain.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_layout.dart';
import 'theme/tokens.dart';
import 'services/notification_service.dart';
import 'services/telemetry_service.dart';
import 'dev/dev_seed.dart';
import 'app_scope.dart';
import 'data/learning_repository.dart';

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
  String _examName = 'JAIIB';
  String _userId = 'dummy_user';
  bool _contentLoaded = false;

  final ContentStore _contentStore = MemoryContentStore();
  final EventLogStore _eventStore = MemoryEventLogStore();
  final SrsStateStore _stateStore = MemorySrsStateStore();
  final NotificationService _notificationService = NotificationService();
  final TelemetryService _telemetryService = TelemetryService();

  /// Load the content pack for the chosen exam into the stores.
  Future<void> _loadExam(String examCode) async {
    try {
      final asset = 'assets/content_pack_${examCode.toLowerCase()}.json';
      final pack = jsonDecode(await rootBundle.loadString(asset))
          as Map<String, dynamic>;
      final delta = ContentPackDelta.fromJson(pack);
      for (final e in delta.exams) {
        await _contentStore.saveExam(e);
      }
      for (final p in delta.papers) {
        await _contentStore.savePaper(p);
      }
      for (final m in delta.modules) {
        await _contentStore.saveModule(m);
      }
      for (final l in delta.lessons) {
        await _contentStore.saveLesson(l);
      }
      for (final q in delta.questions) {
        await _contentStore.saveQuestion(q);
      }
      for (final a in delta.assets) {
        await _contentStore.saveAsset(a);
      }
      for (final s in delta.stimuli) {
        await _contentStore.saveStimulus(s);
      }
    } catch (e, stack) {
      _telemetryService.logError(e, stack);
      debugPrint('Failed to load $examCode pack: $e. Falling back to seeded content.');
      await DevSeed.seedFallbackContent(_contentStore);
    }
  }

  ExamConfig get _examConfig =>
      _examName == 'CAIIB' ? _caiibConfig : _jaiibConfig;

  static const _jaiibConfig = ExamConfig(
    examCode: 'JAIIB',
    papers: [
      PaperConfig(
        paperCode: 'PPB',
        name: LocalizedString({'en': 'Principles & Practices of Banking'}),
        durationMin: 120,
        sections: [
          SectionConfig(
              code: 'ALL', count: 10, marksPerQuestion: 1, negativeMarks: 0),
        ],
      ),
    ],
    passRule: PassRule(
      perComponentMin: 50,
      alternativeAggregate:
          AlternativeAggregate(perComponentMin: 45, aggregateMin: 50),
    ),
    gradingProfile: GradingProfile(allowPartialDefault: false),
    mockBlueprints: [
      MockBlueprint(
        id: 'bp_jaiib_full',
        name: 'JAIIB practice mock',
        picks: [MockPick(topicTags: [], count: 10, difficultyMix: {1: 0.5, 2: 0.5})],
        shuffle: true,
        timingFromPaper: 'PPB',
      ),
    ],
  );

  static const _caiibConfig = ExamConfig(
    examCode: 'CAIIB',
    papers: [
      PaperConfig(
        paperCode: 'CAIIB',
        name: LocalizedString({'en': 'CAIIB'}),
        durationMin: 120,
        sections: [
          SectionConfig(
              code: 'ALL', count: 30, marksPerQuestion: 1, negativeMarks: 0),
        ],
      ),
    ],
    passRule: PassRule(
      perComponentMin: 50,
      alternativeAggregate:
          AlternativeAggregate(perComponentMin: 45, aggregateMin: 50),
    ),
    gradingProfile: GradingProfile(allowPartialDefault: false),
    mockBlueprints: [
      MockBlueprint(
        id: 'bp_caiib_full',
        name: 'CAIIB practice mock',
        picks: [
          MockPick(
              topicTags: [],
              count: 30,
              difficultyMix: {1: 0.3, 2: 0.4, 3: 0.2, 4: 0.1}),
        ],
        shuffle: true,
        timingFromPaper: 'CAIIB',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final themeTokens = AppTokens.dark;
    final theme = buildTheme(themeTokens);

    final Widget home;
    if (_examDate == null) {
      home = OnboardingScreen(
        onComplete: (date, email, token, examCode) async {
          setState(() {
            _examName = examCode;
            _examDate = date;
            _userId = email;
            _contentLoaded = false;
          });
          await _loadExam(examCode);
          if (!mounted) return;
          setState(() => _contentLoaded = true);
        },
      );
    } else if (!_contentLoaded) {
      home = Scaffold(
        backgroundColor: themeTokens.bgBase,
        body: Center(child: CircularProgressIndicator(color: themeTokens.accent)),
      );
    } else {
      final scheduler = DeadlineAwareScheduler(
        delegate: const Fsrs(),
        examDate: _examDate!,
      );
      final repository = LearningRepository(
        content: _contentStore,
        events: _eventStore,
        states: _stateStore,
        scheduler: scheduler,
      );
      home = AppScope(
        repository: repository,
        userId: _userId,
        examName: _examName,
        examDate: _examDate!,
        examConfig: _examConfig,
        notificationService: _notificationService,
        child: const MainLayout(),
      );
    }

    return MaterialApp(
      title: 'Calm Prep',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: home,
    );
  }
}
