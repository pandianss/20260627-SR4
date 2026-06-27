import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'package:store/store.dart';
import 'package:srs/srs.dart';
import 'package:domain/domain.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_layout.dart';
import 'theme/tokens.dart';
import 'services/notification_service.dart';
import 'services/telemetry_service.dart';
import 'services/updates_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_sync_service.dart';
import 'dev/dev_seed.dart';
import 'app_scope.dart';
import 'data/learning_repository.dart';
import 'data/prefs_stores.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Route Flutter framework + async errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Anonymous-first auth: every user gets a stable uid immediately. Falls back
  // to a local id only if the very first launch is offline.
  final authService = AuthService();
  String userId;
  try {
    userId = await authService.ensureSignedIn();
  } catch (e) {
    debugPrint('Anonymous sign-in failed (offline?): $e');
    userId = authService.currentUser?.uid ?? 'local';
  }

  runApp(MyApp(
    userId: userId,
    authService: authService,
    firestoreSync: FirestoreSyncService(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.userId,
    this.authService,
    this.firestoreSync,
  });

  /// The signed-in user's uid (anonymous or account), used to key all data.
  final String userId;
  final AuthService? authService;
  final FirestoreSyncService? firestoreSync;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime? _examDate;
  String _examName = 'CAIIB';
  late String _userId;
  bool _contentLoaded = false;

  final ContentStore _contentStore = MemoryContentStore();
  // Persistent (prefs-backed) so progress + SRS schedule survive restarts;
  // initialized from SharedPreferences in _checkPersistedSession.
  late final EventLogStore _eventStore;
  late final SrsStateStore _stateStore;
  final NotificationService _notificationService = NotificationService();
  final TelemetryService _telemetryService = TelemetryService();
  final UpdatesService _updatesService = UpdatesService();

  bool _isPremium = false;
  bool _loadingSession = true;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _checkPersistedSession();
    _notificationService.init();
  }

  /// Back up local progress and restore any cloud data for this uid.
  /// Fire-and-forget so startup never blocks on the network.
  Future<void> _syncCloud() async {
    final sync = widget.firestoreSync;
    if (sync == null) return;
    try {
      await sync.sync(_userId, _eventStore, _stateStore);
    } catch (e) {
      debugPrint('Cloud sync failed: $e');
    }
  }

  Future<void> _checkPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    _eventStore = await PrefsEventLogStore.create(prefs);
    _stateStore = await PrefsSrsStateStore.create(prefs);
    _syncCloud(); // fire-and-forget cloud backup + restore for this uid
    try {
      final examName = prefs.getString('examName');
      final examDateStr = prefs.getString('examDate');
      final isPremium = prefs.getBool('isPremium') ?? false;

      if (examName != null && examDateStr != null) {
        final examDate = DateTime.parse(examDateStr);
        setState(() {
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
      _userId = widget.userId;
      _isPremium = false;
      _contentLoaded = false;
    });
  }

  /// Permanently delete the account: cloud data, the auth user, and all local
  /// data, then re-establish a fresh anonymous session and return to onboarding.
  Future<void> _deleteAccount() async {
    final uid = _userId;
    try {
      await widget.firestoreSync?.deleteUserData(uid);
    } catch (e) {
      debugPrint('Failed to delete cloud data: $e');
    }
    // Throws (e.g. requires-recent-login) propagate to the UI to handle.
    await widget.authService?.deleteAccount();

    final eventStore = _eventStore;
    if (eventStore is PrefsEventLogStore) await eventStore.clear();
    final stateStore = _stateStore;
    if (stateStore is PrefsSrsStateStore) await stateStore.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final k in ['email', 'examName', 'examDate', 'isPremium', 'userId']) {
        await prefs.remove(k);
      }
    } catch (_) {}

    String newUid = 'local';
    try {
      newUid = await widget.authService?.ensureSignedIn() ?? 'local';
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _userId = newUid;
      _examDate = null;
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
            // Onboarding may have signed in / linked a real account.
            _userId = widget.authService?.currentUid ?? _userId;
            _contentLoaded = false;
          });
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', email);
            await prefs.setString('examName', examCode);
            await prefs.setString('examDate', date.toIso8601String());
          } catch (e) {
            debugPrint('Failed to save session: $e');
          }
          await _loadExam(examCode);
          if (!mounted) return;
          setState(() => _contentLoaded = true);
          _syncCloud();
        },
        authService: widget.authService,
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
        updatesService: _updatesService,
        authService: widget.authService,
        onLogout: _logout,
        onDeleteAccount: _deleteAccount,
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
