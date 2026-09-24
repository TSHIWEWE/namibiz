import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// -----------------------------------------------------------------------
// TODO: paste your own values from Supabase → Project Settings → API
// -----------------------------------------------------------------------
const String supabaseUrl = 'https://ygxmakrimsflohtkcovt.supabase.co';
const String supabaseAnonKey = 'sb_publishable_lSehM44XAvAh6Esg1Tc4tA_6Q6iHHbl';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const NamiBizApp());
}

SupabaseClient get supabase => Supabase.instance.client;

// ---------------------------------------------------------------------------
// Palette
// ---------------------------------------------------------------------------
const Color bg = Color(0xFFF5F6FA);
const Color navy = Color(0xFF16294F);
const Color gold = Color(0xFFE8A33D);
const Color ink = Color(0xFF1E2430);
const Color muted = Color(0xFF6B7280);
const Color cardBg = Colors.white;
const Color income = Color(0xFF1F9254);
const Color expense = Color(0xFFD64545);
const Color rule = Color(0xFFE4E6EE);
const Color brandGreen = Color(0xFF2E8B57);
const Color customerColor = Color(0xFF9B59B6);

const List<String> _expenseCategories = ['Stock', 'Rent', 'Transport', 'Utilities', 'Salaries', 'Other'];
const List<String> _paymentMethods = ['Cash', 'Mobile Money', 'Card', 'Bank Transfer', 'Digital Payment'];
const List<String> _sectionTitles = [
  'Dashboard', 'Sales', 'Expenses', 'Transactions', 'Financial Summary', 'Business Financial Profile', 'Settings',
];

class NamiBizApp extends StatelessWidget {
  const NamiBizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NamiBiz',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.light(
          primary: navy,
          onPrimary: Colors.white,
          secondary: gold,
          onSecondary: navy,
          surface: cardBg,
          onSurface: ink,
          error: expense,
          onError: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ---------------------------------------------------------------------------
// Auth gate
// ---------------------------------------------------------------------------
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final TransactionsController controller = TransactionsController();
  Session? _session;
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    _session = supabase.auth.currentSession;
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      setState(() => _session = data.session);
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return const AuthScreen();
    }
    return HomeShell(controller: controller);
  }
}

// ---------------------------------------------------------------------------
// Login / sign-up screen
// ---------------------------------------------------------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _DuneSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = navy.withOpacity(0.30);
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.70);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.48, size.width * 0.32, size.height * 0.62);
    path.quadraticBezierTo(size.width * 0.46, size.height * 0.76, size.width * 0.58, size.height * 0.52);
    path.quadraticBezierTo(size.width * 0.72, size.height * 0.30, size.width * 0.86, size.height * 0.58);
    path.quadraticBezierTo(size.width * 0.95, size.height * 0.70, size.width, size.height * 0.62);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()..color = navy.withOpacity(0.18);
    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.85);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.68, size.width * 0.5, size.height * 0.82);
    path2.quadraticBezierTo(size.width * 0.75, size.height * 0.94, size.width, size.height * 0.78);
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String? _error;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isSignUp) {
        await supabase.auth.signUp(email: email, password: password);
      } else {
        await supabase.auth.signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset password', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
        content: TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(emailCtrl.text.trim()),
            child: const Text('Send link'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    try {
      await supabase.auth.resetPasswordForEmail(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('If that email exists, a reset link was sent.', style: GoogleFonts.inter(fontSize: 13))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send a reset link right now.', style: GoogleFonts.inter(fontSize: 13))),
      );
    }
  }

  void _comingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.inter(fontSize: 13))),
    );
  }

  Widget _featureRow(IconData icon, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [navy, navy, gold.withOpacity(0.55)],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 36,
                  right: 30,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [gold.withOpacity(0.85), gold.withOpacity(0)]),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 110,
                  child: CustomPaint(painter: _DuneSilhouettePainter(), size: Size.infinite),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [brandGreen, navy]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text('N',
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('NamiBiz',
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                                Text('Your Business. Our Future.',
                                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text('Manage your business.\nGrow your dreams.',
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800, height: 1.25)),
                        const SizedBox(height: 10),
                        Text(
                          'NamiBiz helps Namibian small businesses track sales, manage expenses, '
                          'and build a stronger financial future — all in one place.',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5, height: 1.4),
                        ),
                        const SizedBox(height: 18),
                        _featureRow(Icons.trending_up_rounded, brandGreen, 'Track your sales'),
                        _featureRow(Icons.account_balance_wallet_rounded, const Color(0xFF3B82F6), 'Manage your expenses'),
                        _featureRow(Icons.people_alt_rounded, const Color(0xFFE8734A), 'Keep your customers'),
                        _featureRow(Icons.insights_rounded, customerColor, 'Build your financial profile'),
                        const SizedBox(height: 6),
                        Text('Built for Namibian Businesses',
                            style: GoogleFonts.inter(
                                color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              decoration: const BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => _comingSoon('More languages coming soon.'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.language_rounded, size: 15, color: muted),
                          const SizedBox(width: 4),
                          Text('English', style: GoogleFonts.inter(fontSize: 12, color: muted)),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: muted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUp ? 'Create your account' : 'Welcome back!',
                    style: GoogleFonts.inter(fontSize: 21, fontWeight: FontWeight.w800, color: ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSignUp ? 'Set up your NamiBiz account.' : 'Log in to your NamiBiz account.',
                    style: GoogleFonts.inter(fontSize: 13, color: muted),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(fontSize: 15, color: ink),
                    decoration: _decoration('Email', icon: Icons.mail_outline_rounded),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.inter(fontSize: 15, color: ink),
                    decoration: _decoration(
                      'Password',
                      icon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: muted,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  if (!_isSignUp) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _rememberMe = !_rememberMe),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                  activeColor: navy,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('Remember me', style: GoogleFonts.inter(fontSize: 12, color: muted)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _loading ? null : _showForgotPasswordDialog,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          child: Text('Forgot password?', style: GoogleFonts.inter(fontSize: 12, color: muted)),
                        ),
                      ],
                    ),
                  ] else
                    const SizedBox(height: 12),
                  if (_error != null) ...[
                    const SizedBox(height: 4),
                    Text(_error!, style: GoogleFonts.inter(fontSize: 12, color: expense)),
                  ],
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_isSignUp ? 'Create account' : 'Log in',
                                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp ? 'Already have an account?' : "Don't have an account?",
                        style: GoogleFonts.inter(fontSize: 13, color: muted),
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() {
                                  _isSignUp = !_isSignUp;
                                  _error = null;
                                }),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _isSignUp ? 'Sign in' : 'Sign up',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: const Color(0xFFB8860B), fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, {IconData? icon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 13, color: muted),
      prefixIcon: icon != null ? Icon(icon, color: muted, size: 20) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cardBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: rule)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: rule)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: navy, width: 1.4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Data layer
// ---------------------------------------------------------------------------
enum TxnType { income, expense }

class Transaction {
  final String? id;
  final String note;
  final double amount;
  final TxnType type;
  final DateTime date;
  final String? category;
  final String? paymentMethod;
  final String? customerName;

  Transaction({
    this.id,
    required this.note,
    required this.amount,
    required this.type,
    required this.date,
    this.category,
    this.paymentMethod,
    this.customerName,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      note: map['note'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 'income' ? TxnType.income : TxnType.expense,
      date: DateTime.parse(map['created_at'] as String).toLocal(),
      category: map['category'] as String?,
      paymentMethod: map['payment_method'] as String?,
      customerName: map['customer_name'] as String?,
    );
  }
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.createdAt,
  });

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] as String,
      name: map['name'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      savedAmount: (map['saved_amount'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }
}

class ReadinessResult {
  final int score;
  final int consistencyScore;
  final int cashFlowScore;
  final int trackRecordScore;
  final int daysTracked;
  final int activeDays;
  final String label;
  final String summary;

  ReadinessResult({
    required this.score,
    required this.consistencyScore,
    required this.cashFlowScore,
    required this.trackRecordScore,
    required this.daysTracked,
    required this.activeDays,
    required this.label,
    required this.summary,
  });
}

class TransactionsController extends ChangeNotifier {
  List<Transaction> transactions = [];
  bool loading = true;
  bool saving = false;
  String? businessName;
  String? businessType;
  String? businessLocation;

  List<SavingsGoal> savingsGoals = [];
  bool goalsLoading = true;

  double get totalIncome => transactions
      .where((t) => t.type == TxnType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TxnType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  int get customerCount => transactions
      .where((t) => t.type == TxnType.income && (t.customerName ?? '').trim().isNotEmpty)
      .map((t) => t.customerName!.trim().toLowerCase())
      .toSet()
      .length;

  void loadBusinessProfile() {
    final meta = supabase.auth.currentUser?.userMetadata;
    businessName = meta?['business_name'] as String?;
    businessType = meta?['business_type'] as String?;
    businessLocation = meta?['business_location'] as String?;
  }

  Future<bool> updateBusinessProfile({required String name, required String type, required String location}) async {
    try {
      await supabase.auth.updateUser(UserAttributes(data: {
        'business_name': name,
        'business_type': type,
        'business_location': location,
      }));
      businessName = name;
      businessType = type;
      businessLocation = location;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  ReadinessResult get readiness {
    if (transactions.isEmpty) {
      return ReadinessResult(
        score: 0,
        consistencyScore: 0,
        cashFlowScore: 0,
        trackRecordScore: 0,
        daysTracked: 0,
        activeDays: 0,
        label: 'Not enough data yet',
        summary: 'Add a few entries to see your score take shape.',
      );
    }

    final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));
    final firstDate = sorted.first.date;
    final now = DateTime.now();
    final daysSinceFirst =
        DateTime(now.year, now.month, now.day).difference(DateTime(firstDate.year, firstDate.month, firstDate.day)).inDays + 1;
    final windowDays = daysSinceFirst < 30 ? daysSinceFirst : 30;
    final windowStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: windowDays - 1));

    final activeDaySet = <String>{};
    for (final t in transactions) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (!d.isBefore(windowStart)) {
        activeDaySet.add('${d.year}-${d.month}-${d.day}');
      }
    }
    final activeDays = activeDaySet.length;
    final consistencyRatio = windowDays > 0 ? (activeDays / windowDays).clamp(0.0, 1.0) : 0.0;
    final consistencyScore = (consistencyRatio * 40).round();

    double cashFlowScoreD;
    if (totalIncome <= 0) {
      cashFlowScoreD = 0;
    } else {
      final margin = (balance / totalIncome).clamp(-1.0, 1.0);
      cashFlowScoreD = ((margin + 1) / 2) * 40;
    }
    final cashFlowScore = cashFlowScoreD.round();

    final trackRecordScore = ((transactions.length / 20).clamp(0.0, 1.0) * 20).round();

    final total = (consistencyScore + cashFlowScore + trackRecordScore).clamp(0, 100);

    String label;
    String summary;
    if (total >= 80) {
      label = 'Strong';
      summary = 'Consistent records and healthy cash flow — the kind of history lenders look for.';
    } else if (total >= 60) {
      label = 'Good';
      summary = 'Solid progress. Keep logging regularly to strengthen this further.';
    } else if (total >= 40) {
      label = 'Building';
      summary = "You're building a record. More consistent entries and a healthier balance will raise this.";
    } else if (total >= 20) {
      label = 'Just starting';
      summary = 'Early days. Log entries regularly to start building a track record.';
    } else {
      label = 'Not enough data yet';
      summary = 'Add a few entries to see your score take shape.';
    }

    return ReadinessResult(
      score: total,
      consistencyScore: consistencyScore,
      cashFlowScore: cashFlowScore,
      trackRecordScore: trackRecordScore,
      daysTracked: daysSinceFirst,
      activeDays: activeDays,
      label: label,
      summary: summary,
    );
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    loadBusinessProfile();
    try {
      final data = await supabase
          .from('transactions')
          .select()
          .order('created_at', ascending: false);
      transactions = (data as List)
          .map((row) => Transaction.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Keep whatever we already had.
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> addTransaction({
    required String note,
    required double amount,
    required TxnType type,
    String? category,
    String? paymentMethod,
    String? customerName,
    DateTime? date,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    saving = true;
    notifyListeners();
    try {
      final payload = <String, dynamic>{
        'note': note,
        'amount': amount,
        'type': type == TxnType.income ? 'income' : 'expense',
        'user_id': userId,
        'category': category,
        'payment_method': paymentMethod,
        'customer_name': customerName,
      };
      if (date != null) payload['created_at'] = date.toIso8601String();

      final inserted = await supabase.from('transactions').insert(payload).select().single();
      transactions.insert(0, Transaction.fromMap(inserted));
      transactions.sort((a, b) => b.date.compareTo(a.date));
      saving = false;
      notifyListeners();
      return true;
    } catch (_) {
      saving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction({
    required String id,
    required String note,
    required double amount,
    required TxnType type,
    String? category,
    String? paymentMethod,
    String? customerName,
  }) async {
    saving = true;
    notifyListeners();
    try {
      final updated = await supabase
          .from('transactions')
          .update({
            'note': note,
            'amount': amount,
            'type': type == TxnType.income ? 'income' : 'expense',
            'category': category,
            'payment_method': paymentMethod,
            'customer_name': customerName,
          })
          .eq('id', id)
          .select()
          .single();
      final index = transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        transactions[index] = Transaction.fromMap(updated);
      }
      saving = false;
      notifyListeners();
      return true;
    } catch (_) {
      saving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    saving = true;
    notifyListeners();
    try {
      await supabase.from('transactions').delete().eq('id', id);
      transactions.removeWhere((t) => t.id == id);
      saving = false;
      notifyListeners();
      return true;
    } catch (_) {
      saving = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSavingsGoals() async {
    goalsLoading = true;
    notifyListeners();
    try {
      final data = await supabase.from('savings_goals').select().order('created_at', ascending: false);
      savingsGoals = (data as List).map((r) => SavingsGoal.fromMap(r as Map<String, dynamic>)).toList();
    } catch (_) {
      // Keep whatever we already had.
    }
    goalsLoading = false;
    notifyListeners();
  }

  Future<bool> addSavingsGoal(String name, double target) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final inserted = await supabase
          .from('savings_goals')
          .insert({'name': name, 'target_amount': target, 'saved_amount': 0, 'user_id': userId})
          .select()
          .single();
      savingsGoals.insert(0, SavingsGoal.fromMap(inserted));
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addToGoal(String id, double amount) async {
    final index = savingsGoals.indexWhere((g) => g.id == id);
    if (index == -1) return false;
    final newSaved = savingsGoals[index].savedAmount + amount;
    try {
      final updated = await supabase.from('savings_goals').update({'saved_amount': newSaved}).eq('id', id).select().single();
      savingsGoals[index] = SavingsGoal.fromMap(updated);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSavingsGoal(String id) async {
    try {
      await supabase.from('savings_goals').delete().eq('id', id);
      savingsGoals.removeWhere((g) => g.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}

String _fmt(double v) => 'N\$${v.toStringAsFixed(2)}';

const List<String> _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _sectionDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(date.year, date.month, date.day);
  if (that == today) return 'Today';
  if (that == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${date.day} ${_months[date.month - 1]}';
}

String _time(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

Widget _choiceChipStatic(String label, bool selected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? navy.withOpacity(0.1) : bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? navy : rule, width: 1.2),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? navy : muted)),
    ),
  );
}

InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.inter(fontSize: 13, color: muted),
    filled: true,
    fillColor: bg,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

Widget _searchField(TextEditingController controller, String hint, ValueChanged<String> onChanged) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    style: GoogleFonts.inter(fontSize: 14, color: ink),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: muted),
      prefixIcon: Icon(Icons.search_rounded, color: muted, size: 20),
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              icon: Icon(Icons.close_rounded, color: muted, size: 18),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            )
          : null,
      filled: true,
      fillColor: cardBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    ),
  );
}

// ---------------------------------------------------------------------------
// Shell — Drawer navigation + shared app bar
// ---------------------------------------------------------------------------
class HomeShell extends StatefulWidget {
  final TransactionsController controller;
  const HomeShell({super.key, required this.controller});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  void _openEntrySheet({Transaction? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEntrySheet(controller: widget.controller, existing: existing),
    );
  }

  void _goTo(int i) {
    setState(() => _index = i);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        controller: widget.controller,
        onSeeAll: () => setState(() => _index = 3),
        onEdit: (t) => _openEntrySheet(existing: t),
      ),
      SalesScreen(controller: widget.controller, onEdit: (t) => _openEntrySheet(existing: t)),
      ExpensesScreen(controller: widget.controller, onEdit: (t) => _openEntrySheet(existing: t)),
      TransactionsScreen(controller: widget.controller, onEdit: (t) => _openEntrySheet(existing: t)),
      FinancialSummaryScreen(controller: widget.controller),
      BusinessProfileScreen(
        controller: widget.controller,
        onViewAllTransactions: () => setState(() => _index = 3),
        onOpenSettings: () => setState(() => _index = 6),
      ),
      SettingsScreen(controller: widget.controller),
    ];

    final showFab = _index == 0 || _index == 3;

    return Scaffold(
      backgroundColor: bg,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: ink),
        title: Text(_sectionTitles[_index], style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: ink)),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded),
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: expense, shape: BoxShape.circle, border: Border.all(color: bg, width: 1.5)),
                  ),
                ),
              ],
            ),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No new notifications.', style: GoogleFonts.inter(fontSize: 13))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: GestureDetector(
              onTap: () => setState(() => _index = 6),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: navy,
                child: Text('N', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: IndexedStack(index: _index, children: screens)),
      floatingActionButton: showFab
          ? FloatingActionButton(
              backgroundColor: gold,
              foregroundColor: navy,
              onPressed: () => _openEntrySheet(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDrawer() {
    final items = <(IconData, String, Color)>[
      (Icons.grid_view_rounded, 'Dashboard', gold),
      (Icons.point_of_sale_rounded, 'Sales', income),
      (Icons.receipt_long_rounded, 'Expenses', expense),
      (Icons.swap_horiz_rounded, 'Transactions', const Color(0xFF3B82F6)),
      (Icons.bar_chart_rounded, 'Financial Summary', customerColor),
      (Icons.account_balance_rounded, 'Business Financial Profile', const Color(0xFF14B8A6)),
      (Icons.settings_rounded, 'Settings', const Color(0xFF94A3B8)),
    ];

    return Drawer(
      backgroundColor: navy,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [brandGreen, navy]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('N', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NamiBiz', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('Your Business. Our Future.', style: GoogleFonts.inter(color: Colors.white60, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.12), height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final selected = i == _index;
                  final itemColor = items[i].$3;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: selected ? itemColor.withOpacity(0.16) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _goTo(i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: selected ? itemColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected ? itemColor : Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(items[i].$1, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(items[i].$2,
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.12), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 18, backgroundColor: gold, child: const Icon(Icons.person_rounded, color: navy, size: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.controller.businessName ?? '').isNotEmpty
                              ? widget.controller.businessName!
                              : (supabase.auth.currentUser?.email ?? ''),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('Business Owner', style: GoogleFonts.inter(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------
class DashboardScreen extends StatelessWidget {
  final TransactionsController controller;
  final VoidCallback onSeeAll;
  final ValueChanged<Transaction> onEdit;
  const DashboardScreen({super.key, required this.controller, required this.onSeeAll, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.loading) {
          return const Center(child: CircularProgressIndicator(color: navy));
        }
        final recent = controller.transactions.take(5).toList();

        final now = DateTime.now();
        final thisStart = DateTime(now.year, now.month, 1);
        final nextStart = DateTime(now.year, now.month + 1, 1);
        final lastStart = DateTime(now.year, now.month - 1, 1);

        double sumFor(TxnType type, DateTime start, DateTime end) => controller.transactions
            .where((t) => t.type == type && !t.date.isBefore(start) && t.date.isBefore(end))
            .fold(0.0, (s, t) => s + t.amount);

        int customersInRange(DateTime start, DateTime end) => controller.transactions
            .where((t) => t.type == TxnType.income && !t.date.isBefore(start) && t.date.isBefore(end) && (t.customerName ?? '').trim().isNotEmpty)
            .map((t) => t.customerName!.trim().toLowerCase())
            .toSet()
            .length;

        double pctChange(double current, double previous) =>
            previous == 0 ? (current == 0 ? 0.0 : 1.0) : (current - previous) / previous.abs();

        final thisSales = sumFor(TxnType.income, thisStart, nextStart);
        final lastSales = sumFor(TxnType.income, lastStart, thisStart);
        final thisExpenses = sumFor(TxnType.expense, thisStart, nextStart);
        final lastExpenses = sumFor(TxnType.expense, lastStart, thisStart);
        final thisProfit = thisSales - thisExpenses;
        final lastProfit = lastSales - lastExpenses;
        final thisCustomers = customersInRange(thisStart, nextStart);
        final lastCustomers = customersInRange(lastStart, thisStart);

        final salesChange = pctChange(thisSales, lastSales);
        final expensesChange = pctChange(thisExpenses, lastExpenses);
        final profitChange = pctChange(thisProfit, lastProfit);
        final customersChange = pctChange(thisCustomers.toDouble(), lastCustomers.toDouble());

        String? changeLabel(double change, double current, double previous) {
          if (current == 0 && previous == 0) return null;
          return '${(change.abs() * 100).toStringAsFixed(0)}% from last month';
        }

        return RefreshIndicator(
          color: navy,
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              Text('Overview of your business', style: GoogleFonts.inter(fontSize: 13, color: muted)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      'Total Sales',
                      _fmt(controller.totalIncome),
                      income,
                      Icons.shopping_cart_rounded,
                      changeLabel: changeLabel(salesChange, thisSales, lastSales),
                      increased: salesChange >= 0,
                      isGoodChange: salesChange >= 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      'Total Expenses',
                      _fmt(controller.totalExpense),
                      expense,
                      Icons.receipt_long_rounded,
                      changeLabel: changeLabel(expensesChange, thisExpenses, lastExpenses),
                      increased: expensesChange >= 0,
                      isGoodChange: expensesChange <= 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      'Estimated Profit',
                      _fmt(controller.balance),
                      navy,
                      Icons.bar_chart_rounded,
                      changeLabel: changeLabel(profitChange, thisProfit, lastProfit),
                      increased: profitChange >= 0,
                      isGoodChange: profitChange >= 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      'Customers',
                      '${controller.customerCount}',
                      customerColor,
                      Icons.people_alt_rounded,
                      changeLabel: changeLabel(customersChange, thisCustomers.toDouble(), lastCustomers.toDouble()),
                      increased: customersChange >= 0,
                      isGoodChange: customersChange >= 0,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CustomersScreen(controller: controller)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: navy.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                      child: const Icon(Icons.receipt_long_rounded, color: navy, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text('Transactions', style: GoogleFonts.inter(fontSize: 12, color: muted)),
                    const Spacer(),
                    Text('${controller.transactions.length}',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildChart(controller),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: ink)),
                  GestureDetector(
                    onTap: onSeeAll,
                    child: Text('See all', style: GoogleFonts.inter(fontSize: 13, color: navy, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (recent.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  child: Text('No entries yet. Tap + to log your first sale or expense.',
                      textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: muted)),
                )
              else
                ...recent.map(_row),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(
    String label,
    String valueText,
    Color color,
    IconData icon, {
    String? changeLabel,
    bool increased = true,
    bool isGoodChange = true,
    VoidCallback? onTap,
  }) {
    final content = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(height: 10),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: muted)),
          const SizedBox(height: 3),
          Text(valueText, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: ink)),
          if (changeLabel != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(increased ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 11, color: isGoodChange ? income : expense),
                const SizedBox(width: 2),
                Text(changeLabel,
                    style: GoogleFonts.inter(fontSize: 10, color: isGoodChange ? income : expense, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap, child: content),
    );
  }

  Widget _buildChart(TransactionsController controller) {
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));
    double maxVal = 1;
    final bars = months.map((m) {
      final start = m;
      final end = DateTime(m.year, m.month + 1, 1);
      final inc = controller.transactions
          .where((t) => t.type == TxnType.income && !t.date.isBefore(start) && t.date.isBefore(end))
          .fold(0.0, (s, t) => s + t.amount);
      final exp = controller.transactions
          .where((t) => t.type == TxnType.expense && !t.date.isBefore(start) && t.date.isBefore(end))
          .fold(0.0, (s, t) => s + t.amount);
      if (inc > maxVal) maxVal = inc;
      if (exp > maxVal) maxVal = exp;
      return (m, inc, exp);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Sales vs Expenses', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
              const Spacer(),
              _legendDot(income, 'Sales'),
              const SizedBox(width: 12),
              _legendDot(expense, 'Expenses'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: bars.map((entry) {
                final (m, inc, exp) = entry;
                final incH = maxVal > 0 ? (inc / maxVal) * 90 : 0.0;
                final expH = maxVal > 0 ? (exp / maxVal) * 90 : 0.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: incH < 3 ? 3 : incH,
                          decoration: BoxDecoration(color: income, borderRadius: BorderRadius.circular(3)),
                        ),
                        const SizedBox(width: 3),
                        Container(
                          width: 8,
                          height: expH < 3 ? 3 : expH,
                          decoration: BoxDecoration(color: expense, borderRadius: BorderRadius.circular(3)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(_months[m.month - 1].substring(0, 3), style: GoogleFonts.inter(fontSize: 10, color: muted)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: muted)),
      ],
    );
  }

  Widget _row(Transaction txn) {
    final isIncome = txn.type == TxnType.income;
    final color = isIncome ? income : expense;
    final sign = isIncome ? '+' : '-';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onEdit(txn),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Icon(isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(txn.note, style: GoogleFonts.inter(fontSize: 14, color: ink))),
                Text('$sign${_fmt(txn.amount)}',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sales screen — Add Sale / Sales History
// ---------------------------------------------------------------------------
class SalesScreen extends StatefulWidget {
  final TransactionsController controller;
  final ValueChanged<Transaction> onEdit;
  const SalesScreen({super.key, required this.controller, required this.onEdit});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

enum _SalesTab { add, history, customers }

class _SalesScreenState extends State<SalesScreen> {
  _SalesTab _tab = _SalesTab.add;
  final _amountController = TextEditingController();
  final _productController = TextEditingController();
  final _customerController = TextEditingController();
  final _historySearchController = TextEditingController();
  String _historyQuery = '';
  String _paymentMethod = _paymentMethods.first;
  DateTime _date = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _saveSale() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter an amount to log this sale.', style: GoogleFonts.inter(fontSize: 13))),
      );
      return;
    }
    final product = _productController.text.trim().isEmpty ? 'Sale' : _productController.text.trim();
    final customer = _customerController.text.trim().isEmpty ? null : _customerController.text.trim();
    final success = await widget.controller.addTransaction(
      note: product,
      amount: amount,
      type: TxnType.income,
      paymentMethod: _paymentMethod,
      customerName: customer,
      date: _date,
    );
    if (!mounted) return;
    if (success) {
      _amountController.clear();
      _productController.clear();
      _customerController.clear();
      setState(() {
        _date = DateTime.now();
        _paymentMethod = _paymentMethods.first;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale saved.', style: GoogleFonts.inter(fontSize: 13))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save that sale. Try again.', style: GoogleFonts.inter(fontSize: 13))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  _tabChip('Add Sale', _tab == _SalesTab.add, () => setState(() => _tab = _SalesTab.add)),
                  _tabChip('History', _tab == _SalesTab.history, () => setState(() => _tab = _SalesTab.history)),
                  _tabChip('Customers', _tab == _SalesTab.customers, () => setState(() => _tab = _SalesTab.customers)),
                ],
              ),
            ),
            Container(height: 1, color: rule),
            const SizedBox(height: 4),
            Expanded(
              child: _tab == _SalesTab.add
                  ? _buildForm()
                  : _tab == _SalesTab.history
                      ? _buildHistory()
                      : _buildCustomersBody(context, widget.controller),
            ),
          ],
        );
      },
    );
  }

  Widget _tabChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 24, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? navy : muted)),
            const SizedBox(height: 6),
            Container(height: 2, width: 30, color: selected ? navy : Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: _productController, decoration: _fieldDecoration('Product / Service')),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.inter(fontSize: 15, color: ink),
                decoration: _fieldDecoration('Amount (N\$)'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _customerController, decoration: _fieldDecoration('Customer (optional)')),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _fieldDecoration('Date'),
                  child: Text('${_date.day} ${_months[_date.month - 1]} ${_date.year}',
                      style: GoogleFonts.inter(fontSize: 15, color: ink)),
                ),
              ),
              const SizedBox(height: 14),
              Text('Payment method', style: GoogleFonts.inter(fontSize: 12, color: muted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _paymentMethods
                    .map((m) => _choiceChipStatic(m, _paymentMethod == m, () => setState(() => _paymentMethod = m)))
                    .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.controller.saving ? null : _saveSale,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: widget.controller.saving
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Save Sale', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    var sales = widget.controller.transactions.where((t) => t.type == TxnType.income).toList();
    final q = _historyQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      sales = sales.where((t) {
        final haystack = [t.note, t.customerName ?? '', t.paymentMethod ?? ''].join(' ').toLowerCase();
        return haystack.contains(q);
      }).toList();
    }

    final groups = <String, List<Transaction>>{};
    for (final t in sales) {
      groups.putIfAbsent(_sectionDate(t.date), () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        _searchField(_historySearchController, 'Search sales', (v) => setState(() => _historyQuery = v)),
        const SizedBox(height: 12),
        if (sales.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(q.isEmpty ? 'No sales logged yet.' : 'No matches for "$_historyQuery".',
                textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: muted)),
          )
        else
          ...groups.entries.expand((entry) => [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                  child: Text(entry.key, style: GoogleFonts.inter(fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
                ),
                ...entry.value.map(_row),
              ]),
      ],
    );
  }

  Widget _row(Transaction txn) {
    final extras = <String>[
      _time(txn.date),
      if ((txn.customerName ?? '').isNotEmpty) txn.customerName!,
      if ((txn.paymentMethod ?? '').isNotEmpty) txn.paymentMethod!,
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => widget.onEdit(txn),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: income, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(txn.note, style: GoogleFonts.inter(fontSize: 14, color: ink)),
                      const SizedBox(height: 2),
                      Text(extras.join(' · '), style: GoogleFonts.inter(fontSize: 11, color: muted)),
                    ],
                  ),
                ),
                Text('+${_fmt(txn.amount)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: income)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _productController.dispose();
    _customerController.dispose();
    _historySearchController.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Expenses screen — Add Expense / Expense History
// ---------------------------------------------------------------------------
class ExpensesScreen extends StatefulWidget {
  final TransactionsController controller;
  final ValueChanged<Transaction> onEdit;
  const ExpensesScreen({super.key, required this.controller, required this.onEdit});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool _showHistory = false;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _historySearchController = TextEditingController();
  String _historyQuery = '';
  String _category = _expenseCategories.first;
  DateTime _date = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter an amount to log this expense.', style: GoogleFonts.inter(fontSize: 13))),
      );
      return;
    }
    final description = _descriptionController.text.trim().isEmpty ? 'Expense' : _descriptionController.text.trim();
    final success = await widget.controller.addTransaction(
      note: description,
      amount: amount,
      type: TxnType.expense,
      category: _category,
      date: _date,
    );
    if (!mounted) return;
    if (success) {
      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _date = DateTime.now();
        _category = _expenseCategories.first;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense saved.', style: GoogleFonts.inter(fontSize: 13))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save that expense. Try again.', style: GoogleFonts.inter(fontSize: 13))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  _tabChip('Add Expense', !_showHistory, () => setState(() => _showHistory = false)),
                  _tabChip('Expense History', _showHistory, () => setState(() => _showHistory = true)),
                ],
              ),
            ),
            Container(height: 1, color: rule),
            const SizedBox(height: 4),
            Expanded(child: _showHistory ? _buildHistory() : _buildForm()),
          ],
        );
      },
    );
  }

  Widget _tabChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 24, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? navy : muted)),
            const SizedBox(height: 6),
            Container(height: 2, width: 30, color: selected ? navy : Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category', style: GoogleFonts.inter(fontSize: 12, color: muted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _expenseCategories
                    .map((c) => _choiceChipStatic(c, _category == c, () => setState(() => _category = c)))
                    .toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.inter(fontSize: 15, color: ink),
                decoration: _fieldDecoration('Amount (N\$)'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _descriptionController, decoration: _fieldDecoration('Description')),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _fieldDecoration('Date'),
                  child: Text('${_date.day} ${_months[_date.month - 1]} ${_date.year}',
                      style: GoogleFonts.inter(fontSize: 15, color: ink)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.controller.saving ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: widget.controller.saving
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Save Expense', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    var expenses = widget.controller.transactions.where((t) => t.type == TxnType.expense).toList();
    final q = _historyQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      expenses = expenses.where((t) {
        final haystack = [t.note, t.category ?? ''].join(' ').toLowerCase();
        return haystack.contains(q);
      }).toList();
    }

    final groups = <String, List<Transaction>>{};
    for (final t in expenses) {
      groups.putIfAbsent(_sectionDate(t.date), () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        _searchField(_historySearchController, 'Search expenses', (v) => setState(() => _historyQuery = v)),
        const SizedBox(height: 12),
        if (expenses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(q.isEmpty ? 'No expenses logged yet.' : 'No matches for "$_historyQuery".',
                textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: muted)),
          )
        else
          ...groups.entries.expand((entry) => [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                  child: Text(entry.key, style: GoogleFonts.inter(fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
                ),
                ...entry.value.map(_row),
              ]),
      ],
    );
  }

  Widget _row(Transaction txn) {
    final extras = <String>[_time(txn.date), if ((txn.category ?? '').isNotEmpty) txn.category!];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => widget.onEdit(txn),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: expense, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(txn.note, style: GoogleFonts.inter(fontSize: 14, color: ink)),
                      const SizedBox(height: 2),
                      Text(extras.join(' · '), style: GoogleFonts.inter(fontSize: 11, color: muted)),
                    ],
                  ),
                ),
                Text('-${_fmt(txn.amount)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: expense)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _historySearchController.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Transactions — All / Sales / Expenses
// ---------------------------------------------------------------------------
enum _TxnFilter { all, sales, expenses }

class TransactionsScreen extends StatefulWidget {
  final TransactionsController controller;
  final ValueChanged<Transaction> onEdit;
  const TransactionsScreen({super.key, required this.controller, required this.onEdit});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _TxnFilter _filter = _TxnFilter.all;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.loading) {
          return const Center(child: CircularProgressIndicator(color: navy));
        }

        final q = _query.trim().toLowerCase();
        final filtered = widget.controller.transactions.where((t) {
          if (_filter == _TxnFilter.sales && t.type != TxnType.income) return false;
          if (_filter == _TxnFilter.expenses && t.type != TxnType.expense) return false;
          if (q.isEmpty) return true;
          final haystack = [t.note, t.customerName ?? '', t.category ?? '', t.paymentMethod ?? ''].join(' ').toLowerCase();
          return haystack.contains(q);
        }).toList();

        final groups = <String, List<Transaction>>{};
        for (final t in filtered) {
          groups.putIfAbsent(_sectionDate(t.date), () => []).add(t);
        }

        return RefreshIndicator(
          color: navy,
          onRefresh: widget.controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              Text('Tap any entry to edit or delete it.', style: GoogleFonts.inter(fontSize: 12, color: muted)),
              const SizedBox(height: 12),
              _searchField(_searchController, 'Search by note, customer, or category', (v) => setState(() => _query = v)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _filterChip('All', _TxnFilter.all),
                  const SizedBox(width: 8),
                  _filterChip('Sales', _TxnFilter.sales),
                  const SizedBox(width: 8),
                  _filterChip('Expenses', _TxnFilter.expenses),
                ],
              ),
              const SizedBox(height: 6),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(q.isEmpty ? 'Nothing here yet.' : 'No matches for "$_query".',
                      textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: muted)),
                )
              else
                ...groups.entries.expand((entry) => [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 8),
                        child: Text(entry.key, style: GoogleFonts.inter(fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
                      ),
                      ...entry.value.map(_row),
                    ]),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, _TxnFilter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? navy : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? navy : rule),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : muted)),
      ),
    );
  }

  Widget _row(Transaction txn) {
    final isIncome = txn.type == TxnType.income;
    final color = isIncome ? income : expense;
    final sign = isIncome ? '+' : '-';

    final extras = <String>[
      _time(txn.date),
      if (isIncome && (txn.customerName ?? '').isNotEmpty) txn.customerName!,
      if (isIncome && (txn.paymentMethod ?? '').isNotEmpty) txn.paymentMethod!,
      if (!isIncome && (txn.category ?? '').isNotEmpty) txn.category!,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => widget.onEdit(txn),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Icon(isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(txn.note, style: GoogleFonts.inter(fontSize: 14, color: ink)),
                      const SizedBox(height: 2),
                      Text(extras.join(' · '), style: GoogleFonts.inter(fontSize: 11, color: muted)),
                    ],
                  ),
                ),
                Text('$sign${_fmt(txn.amount)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: muted.withOpacity(0.6), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Customers — derived from sales that have a customer name attached
// ---------------------------------------------------------------------------
class CustomerSummary {
  final String name;
  final double totalSpent;
  final int purchaseCount;
  final DateTime lastPurchase;
  CustomerSummary({required this.name, required this.totalSpent, required this.purchaseCount, required this.lastPurchase});
}

List<CustomerSummary> _aggregateCustomers(TransactionsController controller) {
  final map = <String, List<Transaction>>{};
  for (final t in controller.transactions) {
    final name = (t.customerName ?? '').trim();
    if (t.type == TxnType.income && name.isNotEmpty) {
      map.putIfAbsent(name, () => []).add(t);
    }
  }
  final list = map.entries.map((e) {
    final txns = e.value;
    final total = txns.fold(0.0, (s, t) => s + t.amount);
    final last = txns.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b);
    return CustomerSummary(name: e.key, totalSpent: total, purchaseCount: txns.length, lastPurchase: last);
  }).toList();
  list.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
  return list;
}

Widget _buildCustomersBody(BuildContext context, TransactionsController controller) {
  final customers = _aggregateCustomers(controller);
  if (customers.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'No customers yet. Add a customer name when logging a sale to see them here.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, color: muted),
        ),
      ),
    );
  }
  return ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
    children: [
      Text('${customers.length} ${customers.length == 1 ? 'customer' : 'customers'} · sorted by total spent',
          style: GoogleFonts.inter(fontSize: 12, color: muted)),
      const SizedBox(height: 12),
      ...customers.map((c) => _customerCard(context, controller, c)),
    ],
  );
}

Widget _customerCard(BuildContext context, TransactionsController controller, CustomerSummary c) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CustomerDetailScreen(controller: controller, customerName: c.name)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: customerColor.withOpacity(0.15),
                child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(color: customerColor, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: ink)),
                    const SizedBox(height: 2),
                    Text('${c.purchaseCount} purchase${c.purchaseCount == 1 ? '' : 's'} · Last: ${_sectionDate(c.lastPurchase)}',
                        style: GoogleFonts.inter(fontSize: 11, color: muted)),
                  ],
                ),
              ),
              Text(_fmt(c.totalSpent), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: income)),
            ],
          ),
        ),
      ),
    ),
  );
}

class CustomersScreen extends StatelessWidget {
  final TransactionsController controller;
  const CustomersScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            iconTheme: const IconThemeData(color: ink),
            title: Text('Customers', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
          ),
          body: _buildCustomersBody(context, controller),
        );
      },
    );
  }
}

class CustomerDetailScreen extends StatelessWidget {
  final TransactionsController controller;
  final String customerName;
  const CustomerDetailScreen({super.key, required this.controller, required this.customerName});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final txns = controller.transactions
            .where((t) => t.type == TxnType.income && (t.customerName ?? '').trim() == customerName)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        final total = txns.fold(0.0, (s, t) => s + t.amount);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            iconTheme: const IconThemeData(color: ink),
            title: Text(customerName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total spent', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(_fmt(total), style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('${txns.length} purchase${txns.length == 1 ? '' : 's'}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Purchase history', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
              const SizedBox(height: 10),
              ...txns.map((t) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.note, style: GoogleFonts.inter(fontSize: 14, color: ink)),
                              const SizedBox(height: 2),
                              Text(
                                '${_sectionDate(t.date)} · ${_time(t.date)}${(t.paymentMethod ?? '').isNotEmpty ? ' · ${t.paymentMethod}' : ''}',
                                style: GoogleFonts.inter(fontSize: 11, color: muted),
                              ),
                            ],
                          ),
                        ),
                        Text('+${_fmt(t.amount)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: income)),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Financial Summary — now a top-level section (no own app bar)
// ---------------------------------------------------------------------------
class FinancialSummaryScreen extends StatelessWidget {
  final TransactionsController controller;
  const FinancialSummaryScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final now = DateTime.now();
        final thisMonthStart = DateTime(now.year, now.month, 1);
        final nextMonthStart = DateTime(now.year, now.month + 1, 1);
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);

        double sumFor(TxnType type, DateTime start, DateTime end) {
          return controller.transactions
              .where((t) => t.type == type && !t.date.isBefore(start) && t.date.isBefore(end))
              .fold(0.0, (s, t) => s + t.amount);
        }

        final thisIncome = sumFor(TxnType.income, thisMonthStart, nextMonthStart);
        final thisExpense = sumFor(TxnType.expense, thisMonthStart, nextMonthStart);
        final lastIncome = sumFor(TxnType.income, lastMonthStart, thisMonthStart);
        final lastExpense = sumFor(TxnType.expense, lastMonthStart, thisMonthStart);
        final thisProfit = thisIncome - thisExpense;
        final lastProfit = lastIncome - lastExpense;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text('This month vs last month', style: GoogleFonts.inter(fontSize: 13, color: muted)),
            const SizedBox(height: 12),
            _compareCard('Revenue', thisIncome, lastIncome, income, Icons.shopping_cart_rounded),
            _compareCard('Expenses', thisExpense, lastExpense, expense, Icons.receipt_long_rounded),
            _compareCard('Profit', thisProfit, lastProfit, navy, Icons.bar_chart_rounded),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cash Flow (all time)', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(_fmt(controller.balance),
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _compareCard(String label, double current, double previous, Color iconColor, IconData icon) {
    final double diff = previous == 0 ? (current == 0 ? 0.0 : 1.0) : (current - previous) / previous.abs();
    final isUp = diff >= 0;
    final changeColor = isUp ? income : expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 13, color: muted)),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_fmt(current), style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: ink)),
                    const SizedBox(width: 10),
                    Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: changeColor, size: 16),
                    Text('${(diff.abs() * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(fontSize: 12, color: changeColor, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Last month: ${_fmt(previous)}', style: GoogleFonts.inter(fontSize: 11, color: muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Business Financial Profile
// ---------------------------------------------------------------------------
class BusinessProfileScreen extends StatelessWidget {
  final TransactionsController controller;
  final VoidCallback onViewAllTransactions;
  final VoidCallback onOpenSettings;
  const BusinessProfileScreen({
    super.key,
    required this.controller,
    required this.onViewAllTransactions,
    required this.onOpenSettings,
  });

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF4ADE80);
    if (score >= 60) return const Color(0xFFA3E635);
    if (score >= 40) return gold;
    if (score >= 20) return const Color(0xFFFB923C);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final r = controller.readiness;
        final recent = controller.transactions.take(3).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Business Information', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
                TextButton(
                  onPressed: onOpenSettings,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: Text('Edit', style: GoogleFonts.inter(fontSize: 12, color: navy, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Business name', (controller.businessName ?? '').isNotEmpty ? controller.businessName! : 'Not set'),
                  _infoRow('Business type', (controller.businessType ?? '').isNotEmpty ? controller.businessType! : 'Not set'),
                  _infoRow('Location', (controller.businessLocation ?? '').isNotEmpty ? controller.businessLocation! : 'Not set',
                      last: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Business Activity', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _miniStat('Entries logged', '${controller.transactions.length}')),
                const SizedBox(width: 10),
                Expanded(child: _miniStat('Active days', '${r.activeDays}')),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transaction History', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
                GestureDetector(
                  onTap: onViewAllTransactions,
                  child: Text('View all', style: GoogleFonts.inter(fontSize: 12, color: navy, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('No transactions yet.', style: GoogleFonts.inter(fontSize: 13, color: muted)),
              )
            else
              ...recent.map(_txnPreviewRow),
            const SizedBox(height: 24),
            Text('Financial Performance', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _miniStat('Revenue', _fmt(controller.totalIncome))),
                const SizedBox(width: 8),
                Expanded(child: _miniStat('Expenses', _fmt(controller.totalExpense))),
                const SizedBox(width: 8),
                Expanded(child: _miniStat('Profit', _fmt(controller.balance))),
              ],
            ),
            const SizedBox(height: 24),
            Text('Financial Profile', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadinessScreen(controller: controller))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 56,
                              height: 56,
                              child: CircularProgressIndicator(
                                value: r.score / 100,
                                strokeWidth: 6,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation(_scoreColor(r.score)),
                              ),
                            ),
                            Text('${r.score}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text('Tap to see the full breakdown', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: muted)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.inter(fontSize: 14, color: ink)),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: muted)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
        ],
      ),
    );
  }

  Widget _txnPreviewRow(Transaction t) {
    final isIncome = t.type == TxnType.income;
    final color = isIncome ? income : expense;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(t.note, style: GoogleFonts.inter(fontSize: 13, color: ink))),
          Text('${isIncome ? '+' : '-'}${_fmt(t.amount)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings — Business Profile, Account, Logout + utility links
// ---------------------------------------------------------------------------
class SettingsScreen extends StatefulWidget {
  final TransactionsController controller;
  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameController = TextEditingController(text: widget.controller.businessName ?? '');
  late final TextEditingController _typeController = TextEditingController(text: widget.controller.businessType ?? '');
  late final TextEditingController _locationController = TextEditingController(text: widget.controller.businessLocation ?? '');
  bool _saving = false;

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final success = await widget.controller.updateBusinessProfile(
      name: _nameController.text.trim(),
      type: _typeController.text.trim(),
      location: _locationController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Business profile saved.' : 'Could not save. Try again.', style: GoogleFonts.inter(fontSize: 13))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    String memberSince = '';
    final createdAtStr = user?.createdAt;
    if (createdAtStr != null) {
      final d = DateTime.tryParse(createdAtStr);
      if (d != null) memberSince = '${d.day} ${_months[d.month - 1]} ${d.year}';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Text('Business Profile', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: _nameController, style: GoogleFonts.inter(fontSize: 15, color: ink), decoration: _settingsDecoration('Business name')),
              const SizedBox(height: 12),
              TextField(controller: _typeController, style: GoogleFonts.inter(fontSize: 15, color: ink), decoration: _settingsDecoration('Business type')),
              const SizedBox(height: 12),
              TextField(controller: _locationController, style: GoogleFonts.inter(fontSize: 15, color: ink), decoration: _settingsDecoration('Location')),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Save', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Account', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email', style: GoogleFonts.inter(fontSize: 12, color: muted)),
              const SizedBox(height: 2),
              Text(user?.email ?? '', style: GoogleFonts.inter(fontSize: 14, color: ink)),
              if (memberSince.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Member since', style: GoogleFonts.inter(fontSize: 12, color: muted)),
                const SizedBox(height: 2),
                Text(memberSince, style: GoogleFonts.inter(fontSize: 14, color: ink)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('More', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
        const SizedBox(height: 10),
        _navRow(context, 'Export report', Icons.ios_share_rounded, (c) => ExportReportScreen(controller: widget.controller)),
        _navRow(context, 'Savings goals', Icons.savings_rounded, (c) => SavingsGoalsScreen(controller: widget.controller)),
        _navRow(context, 'About NamiBiz', Icons.info_outline_rounded, (c) => const AboutScreen()),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => supabase.auth.signOut(),
            icon: const Icon(Icons.logout_rounded, color: expense),
            label: Text('Logout', style: GoogleFonts.inter(color: expense, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: expense),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navRow(BuildContext context, String label, IconData icon, WidgetBuilder builder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: builder)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: navy, size: 20),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: ink))),
                Icon(Icons.chevron_right_rounded, color: muted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _settingsDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 13, color: muted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Financial-Readiness screen (pushed from Business Financial Profile)
// ---------------------------------------------------------------------------
class ReadinessScreen extends StatelessWidget {
  final TransactionsController controller;
  const ReadinessScreen({super.key, required this.controller});

  Color _colorForScore(int score) {
    if (score >= 80) return const Color(0xFF4ADE80);
    if (score >= 60) return const Color(0xFFA3E635);
    if (score >= 40) return gold;
    if (score >= 20) return const Color(0xFFFB923C);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final r = controller.readiness;
        final scoreColor = _colorForScore(r.score);
        final windowLabel = r.daysTracked > 30 ? 30 : r.daysTracked;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            iconTheme: const IconThemeData(color: ink),
            title: Text('Financial readiness', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: r.score / 100,
                              strokeWidth: 10,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation(scoreColor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${r.score}', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                              Text('/ 100', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(r.label, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(r.summary, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('What makes up this score', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
              const SizedBox(height: 12),
              _factorCard('Record-keeping consistency', r.consistencyScore, 40,
                  '${r.activeDays} of the last $windowLabel day(s) had at least one entry. Logging regularly builds a track record lenders trust.'),
              _factorCard('Cash-flow health', r.cashFlowScore, 40,
                  'Based on how income compares to expenses. A healthy margin shows the business can cover its costs.'),
              _factorCard('Track record', r.trackRecordScore, 20,
                  '${controller.transactions.length} ${controller.transactions.length == 1 ? 'entry' : 'entries'} logged so far. More history means more confidence in the picture.'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
                child: Text(
                  "This score is calculated only from what's recorded in NamiBiz — nothing is shared anywhere unless the business owner chooses to.",
                  style: GoogleFonts.inter(fontSize: 12, color: muted),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _factorCard(String title, int score, int max, String explanation) {
    final ratio = max > 0 ? score / max : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: ink)),
              Text('$score / $max', style: GoogleFonts.inter(fontSize: 12, color: muted)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: rule,
              valueColor: const AlwaysStoppedAnimation(navy),
            ),
          ),
          const SizedBox(height: 8),
          Text(explanation, style: GoogleFonts.inter(fontSize: 12, color: muted)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Export Report (pushed from Settings)
// ---------------------------------------------------------------------------
enum _ReportRange { thisMonth, lastMonth, allTime }

class ExportReportScreen extends StatefulWidget {
  final TransactionsController controller;
  const ExportReportScreen({super.key, required this.controller});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  _ReportRange _range = _ReportRange.thisMonth;

  List<Transaction> _filtered() {
    final now = DateTime.now();
    late DateTime start;
    late DateTime end;
    if (_range == _ReportRange.thisMonth) {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 1);
    } else if (_range == _ReportRange.lastMonth) {
      start = DateTime(now.year, now.month - 1, 1);
      end = DateTime(now.year, now.month, 1);
    } else {
      start = DateTime(2000);
      end = DateTime(now.year + 1);
    }
    return widget.controller.transactions.where((t) => !t.date.isBefore(start) && t.date.isBefore(end)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  String _rangeLabel() {
    if (_range == _ReportRange.thisMonth) return 'This month';
    if (_range == _ReportRange.lastMonth) return 'Last month';
    return 'All time';
  }

  String _buildReportText() {
    final txns = _filtered();
    final incomeTotal = txns.where((t) => t.type == TxnType.income).fold(0.0, (s, t) => s + t.amount);
    final expenseTotal = txns.where((t) => t.type == TxnType.expense).fold(0.0, (s, t) => s + t.amount);
    final profit = incomeTotal - expenseTotal;
    final businessName = widget.controller.businessName ?? supabase.auth.currentUser?.email ?? 'NamiBiz user';

    final buffer = StringBuffer();
    buffer.writeln('NamiBiz Financial Report');
    buffer.writeln(businessName);
    buffer.writeln('Period: ${_rangeLabel()}');
    buffer.writeln('');
    buffer.writeln('Revenue: ${_fmt(incomeTotal)}');
    buffer.writeln('Expenses: ${_fmt(expenseTotal)}');
    buffer.writeln('Profit: ${_fmt(profit)}');
    buffer.writeln('');
    buffer.writeln('Transactions (${txns.length}):');
    for (final t in txns) {
      final sign = t.type == TxnType.income ? '+' : '-';
      final extra = t.type == TxnType.income
          ? [if ((t.customerName ?? '').isNotEmpty) t.customerName!, if ((t.paymentMethod ?? '').isNotEmpty) t.paymentMethod!]
          : [if ((t.category ?? '').isNotEmpty) t.category!];
      final extraText = extra.isEmpty ? '' : ' (${extra.join(', ')})';
      buffer.writeln('${_sectionDate(t.date)} ${_time(t.date)} - ${t.note}$extraText: $sign${_fmt(t.amount)}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final reportText = _buildReportText();
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            iconTheme: const IconThemeData(color: ink),
            title: Text('Export report', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    _rangeChip('This month', _ReportRange.thisMonth),
                    const SizedBox(width: 8),
                    _rangeChip('Last month', _ReportRange.lastMonth),
                    const SizedBox(width: 8),
                    _rangeChip('All time', _ReportRange.allTime),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
                  child: SingleChildScrollView(
                    child: Text(reportText, style: GoogleFonts.ibmPlexMono(fontSize: 12, color: ink, height: 1.5)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: reportText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Report copied. Paste it into email, WhatsApp, or anywhere you need it.', style: GoogleFonts.inter(fontSize: 13))),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text('Copy report', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _rangeChip(String label, _ReportRange value) {
    final selected = _range == value;
    return GestureDetector(
      onTap: () => setState(() => _range = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? navy : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? navy : rule),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : muted)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Savings Goals (pushed from Settings)
// ---------------------------------------------------------------------------
class SavingsGoalsScreen extends StatefulWidget {
  final TransactionsController controller;
  const SavingsGoalsScreen({super.key, required this.controller});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadSavingsGoals();
  }

  Future<void> _showNewGoalDialog() async {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New savings goal', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Goal name')),
            const SizedBox(height: 10),
            TextField(
              controller: targetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Target amount (N\$)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Create')),
        ],
      ),
    );
    if (result != true) return;
    final name = nameCtrl.text.trim();
    final target = double.tryParse(targetCtrl.text.trim());
    if (name.isEmpty || target == null || target <= 0) return;
    await widget.controller.addSavingsGoal(name, target);
  }

  Future<void> _showAddToGoalDialog(SavingsGoal goal) async {
    final amountCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to "${goal.name}"', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (N\$)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Add')),
        ],
      ),
    );
    if (result != true) return;
    final amount = double.tryParse(amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    await widget.controller.addToGoal(goal.id, amount);
  }

  Future<void> _confirmDeleteGoal(SavingsGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete this goal?', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('This can\'t be undone.', style: GoogleFonts.inter(fontSize: 13, color: muted)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Delete', style: GoogleFonts.inter(color: expense))),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.controller.deleteSavingsGoal(goal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            iconTheme: const IconThemeData(color: ink),
            title: Text('Savings goals', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: gold,
            foregroundColor: navy,
            onPressed: _showNewGoalDialog,
            child: const Icon(Icons.add),
          ),
          body: widget.controller.goalsLoading
              ? const Center(child: CircularProgressIndicator(color: navy))
              : widget.controller.savingsGoals.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text('No savings goals yet. Tap + to set one.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: muted)),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      children: widget.controller.savingsGoals.map(_goalCard).toList(),
                    ),
        );
      },
    );
  }

  Widget _goalCard(SavingsGoal goal) {
    final progress = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    final reached = progress >= 1.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(goal.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: ink))),
              IconButton(
                onPressed: () => _confirmDeleteGoal(goal),
                icon: const Icon(Icons.delete_outline_rounded, color: muted, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: rule,
              valueColor: AlwaysStoppedAnimation(reached ? income : navy),
            ),
          ),
          const SizedBox(height: 8),
          Text('${_fmt(goal.savedAmount)} of ${_fmt(goal.targetAmount)}', style: GoogleFonts.inter(fontSize: 12, color: muted)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: reached ? null : () => _showAddToGoalDialog(goal),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: navy),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(reached ? 'Goal reached' : 'Add to this goal', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: navy)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// About (pushed from Settings)
// ---------------------------------------------------------------------------
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: ink),
        title: Text('About NamiBiz', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text('NamiBiz', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: navy)),
          const SizedBox(height: 4),
          Text('Digital financial management for Namibian MSMEs', style: GoogleFonts.inter(fontSize: 13, color: muted)),
          const SizedBox(height: 20),
          Text(
            "NamiBiz helps Namibian small businesses and informal traders move away from notebooks and guesswork, "
            "and toward a clear, honest picture of their own money. Every sale and expense logged here builds a real "
            "financial record — one that can support day-to-day decisions today, and a case for formal credit or "
            "financial services down the line.",
            style: GoogleFonts.inter(fontSize: 14, color: ink, height: 1.5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Version', style: GoogleFonts.inter(fontSize: 12, color: muted)),
                const SizedBox(height: 2),
                Text('1.0.0 (MVP)', style: GoogleFonts.inter(fontSize: 14, color: ink)),
                const SizedBox(height: 12),
                Text('Built for', style: GoogleFonts.inter(fontSize: 12, color: muted)),
                const SizedBox(height: 2),
                Text('Bank of Namibia Fintech Youth Programme', style: GoogleFonts.inter(fontSize: 14, color: ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit entry bottom sheet (quick add from Dashboard / Transactions)
// ---------------------------------------------------------------------------
class AddEntrySheet extends StatefulWidget {
  final TransactionsController controller;
  final Transaction? existing;
  const AddEntrySheet({super.key, required this.controller, this.existing});

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  late final TextEditingController _amountController = TextEditingController(
    text: widget.existing != null ? widget.existing!.amount.toStringAsFixed(2) : '',
  );
  late final TextEditingController _noteController = TextEditingController(text: widget.existing?.note ?? '');
  late final TextEditingController _customerController = TextEditingController(text: widget.existing?.customerName ?? '');
  late TxnType _type = widget.existing?.type ?? TxnType.income;
  late String _category = widget.existing?.category ?? _expenseCategories.first;
  late String _paymentMethod = widget.existing?.paymentMethod ?? _paymentMethods.first;

  bool get _isEditing => widget.existing != null;

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter an amount to log this entry.', style: GoogleFonts.inter(fontSize: 13))),
      );
      return;
    }
    final note = _noteController.text.trim().isEmpty ? (_type == TxnType.income ? 'Sale' : 'Expense') : _noteController.text.trim();

    final category = _type == TxnType.expense ? _category : null;
    final paymentMethod = _type == TxnType.income ? _paymentMethod : null;
    final customerName = _type == TxnType.income && _customerController.text.trim().isNotEmpty ? _customerController.text.trim() : null;

    final success = _isEditing
        ? await widget.controller.updateTransaction(
            id: widget.existing!.id!,
            note: note,
            amount: amount,
            type: _type,
            category: category,
            paymentMethod: paymentMethod,
            customerName: customerName,
          )
        : await widget.controller.addTransaction(
            note: note,
            amount: amount,
            type: _type,
            category: category,
            paymentMethod: paymentMethod,
            customerName: customerName,
          );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save that entry. Try again.', style: GoogleFonts.inter(fontSize: 13))),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete this entry?', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('This removes it from your records permanently. This can\'t be undone.', style: GoogleFonts.inter(fontSize: 13, color: muted)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel', style: GoogleFonts.inter(color: muted))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Delete', style: GoogleFonts.inter(color: expense, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await widget.controller.deleteTransaction(widget.existing!.id!);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete that entry. Try again.', style: GoogleFonts.inter(fontSize: 13))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: rule, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 18),
              Text(_isEditing ? 'Edit entry' : 'New entry', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: ink)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _typeChip('Income', TxnType.income, income)),
                  const SizedBox(width: 10),
                  Expanded(child: _typeChip('Expense', TxnType.expense, expense)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.inter(fontSize: 16, color: ink),
                decoration: _fieldDecoration('Amount (N\$)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                style: GoogleFonts.inter(fontSize: 15, color: ink),
                decoration: _fieldDecoration(_type == TxnType.income ? 'Product / Service' : 'Description'),
              ),
              if (_type == TxnType.income) ...[
                const SizedBox(height: 12),
                TextField(controller: _customerController, style: GoogleFonts.inter(fontSize: 15, color: ink), decoration: _fieldDecoration('Customer (optional)')),
                const SizedBox(height: 14),
                Text('Payment method', style: GoogleFonts.inter(fontSize: 12, color: muted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _paymentMethods.map((m) => _choiceChipStatic(m, _paymentMethod == m, () => setState(() => _paymentMethod = m))).toList(),
                ),
              ] else ...[
                const SizedBox(height: 14),
                Text('Category', style: GoogleFonts.inter(fontSize: 12, color: muted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _expenseCategories.map((c) => _choiceChipStatic(c, _category == c, () => setState(() => _category = c))).toList(),
                ),
              ],
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.controller.saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: widget.controller.saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_isEditing ? 'Save changes' : 'Save entry', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  );
                },
              ),
              if (_isEditing) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: widget.controller.saving ? null : _confirmDelete,
                    child: Text('Delete entry', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: expense)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, TxnType type, Color color) {
    final selected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : rule, width: 1.2),
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? color : muted)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customerController.dispose();
    super.dispose();
  }
}