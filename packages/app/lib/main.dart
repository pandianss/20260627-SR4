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
import 'dev/dev_seed.dart';

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

    } catch (e, stack) {
      _telemetryService.logError(e, stack);
      debugPrint('Failed to load content pack: $e. Falling back to seeded content.');
      await DevSeed.seedFallbackContent(_contentStore);
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
              onComplete: (date, email, token) async {
                await DevSeed.seedDueReviews(_stateStore, email);
                if (!mounted) return;
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
