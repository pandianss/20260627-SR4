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
import 'package:shared_preferences/shared_preferences.dart';

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
  String _examName = 'CAIIB';
  String _userId = 'dummy_user';
  bool _contentLoaded = false;

  final ContentStore _contentStore = MemoryContentStore();
  final EventLogStore _eventStore = MemoryEventLogStore();
  final SrsStateStore _stateStore = MemorySrsStateStore();
  final NotificationService _notificationService = NotificationService();
  final TelemetryService _telemetryService = TelemetryService();

  bool _isPremium = false;
  bool _loadingSession = true;

  @override
  void initState() {
    super.initState();
    _checkPersistedSession();
  }

  Future<void> _checkPersistedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userId');
      final examName = prefs.getString('examName');
      final examDateStr = prefs.getString('examDate');
      final isPremium = prefs.getBool('isPremium') ?? false;

      if (email != null && examName != null && examDateStr != null) {
        final examDate = DateTime.parse(examDateStr);
        setState(() {
          _userId = email;
          _examName = examName;
          _examDate = examDate;
          _isPremium = isPremium;
          _contentLoaded = false;
        });
        await _loadExam(examName);
        if (mounted) {
          setState(() {
            _contentLoaded = true;
            _loadingSession = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingSession = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking persisted session: $e');
      if (mounted) {
        setState(() {
          _loadingSession = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('examName');
      await prefs.remove('examDate');
      await prefs.remove('isPremium');
    } catch (e) {
      debugPrint('Error clearing preferences: $e');
    }
    setState(() {
      _examDate = null;
      _userId = 'dummy_user';
      _isPremium = false;
      _contentLoaded = false;
    });
  }

  Future<void> _purchasePremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', true);
    } catch (e) {
      debugPrint('Error saving premium state: $e');
    }
    setState(() {
      _isPremium = true;
    });
  }

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

  ExamConfig get _examConfig => _caiibConfig;

  static const _caiibConfig = ExamConfig(
    examCode: 'CAIIB',
    papers: [
      PaperConfig(
        paperCode: 'CAIIB',
        name: LocalizedString({'en': 'CAIIB'}),
        durationMin: 15,
        sections: [
          SectionConfig(
              code: 'ALL', count: 15, marksPerQuestion: 1, negativeMarks: 0),
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
              count: 15,
              difficultyMix: {1: 0.3, 2: 0.4, 3: 0.2, 4: 0.1}),
        ],
        shuffle: true,
        timingFromPaper: 'CAIIB',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final themeTokens = AppTokens.light;
    final theme = buildTheme(themeTokens);

    final Widget home;
    if (_loadingSession) {
      home = Scaffold(
        backgroundColor: themeTokens.bgBase,
        body: Center(child: CircularProgressIndicator(color: themeTokens.accent)),
      );
    } else if (_examDate == null) {
      home = OnboardingScreen(
        onComplete: (date, email, token, examCode) async {
          setState(() {
            _examName = examCode;
            _examDate = date;
            _userId = email;
            _contentLoaded = false;
          });
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userId', email);
            await prefs.setString('examName', examCode);
            await prefs.setString('examDate', date.toIso8601String());
          } catch (e) {
            debugPrint('Failed to save session: $e');
          }
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
        onLogout: _logout,
        isPremium: _isPremium,
        onBuyPremium: _purchasePremium,
        child: const MainLayout(),
      );
    }

    return MaterialApp(
      title: 'SuperRecall Banker',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: home,
    );
  }
}
