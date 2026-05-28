import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/api_config_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/biometric_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _biometricAvailable = false;
  List<BiometricType> _biometricTypes = [];

  late AnimationController _orbController;
  late AnimationController _entryController;
  late AnimationController _btnController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));
    _logoScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 85),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeOut),
    );

    _entryController.forward();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await BiometricService.isBiometricAvailable();
    if (!available) return;
    final types = await BiometricService.getAvailableTypes();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = true;
      _biometricTypes = types;
    });
  }

  Future<void> _loginWithBiometric() async {
    if (!await _ensureApiConfigured()) {
      return;
    }

    final enrollment = await BiometricService.readEnrollment();
    if (enrollment == null) {
      _showBiometricSetupDialog();
      return;
    }
    final label = BiometricService.getBiometricLabel(_biometricTypes);
    final result = await BiometricService.authenticate(
      reason: 'Use $label to sign in to Parcel Express HR',
    );
    if (!result.success || !mounted) return;
    _emailController.text = enrollment.identifier;
    final success =
        await ref.read(authControllerProvider.notifier).loginWithBiometric();
    if (!mounted) return;
    if (!success) {
      final error = ref.read(authProvider).error;
      if (error != null && error.toLowerCase().contains('device')) {
        _showDeviceBindingError(error);
      } else if (error != null) {
        AppUtils.showSnackBar(context, error, isError: true);
      }
      return;
    }

    final user = ref.read(authProvider).user;
    final role = user?.role ?? 'staff';
    context.go(AppConstants.homeRouteForRole(role));
  }

  void _showBiometricSetupDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Set Up Biometrics'),
          ],
        ),
        content: const Text(
          'Sign in once with your password, then enable biometric login from your profile settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _orbController.dispose();
    _entryController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await _ensureApiConfigured()) return;
    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (!success) {
      final error = ref.read(authProvider).error;
      if (error != null && error.toLowerCase().contains('device')) {
        _showDeviceBindingError(error);
      } else if (error != null) {
        AppUtils.showSnackBar(context, error, isError: true);
      }
      return;
    }
    final user = ref.read(authProvider).user;
    final role = user?.role ?? 'staff';
    context.go(AppConstants.homeRouteForRole(role));
  }

  Future<bool> _ensureApiConfigured() async {
    final config = ref.read(apiConfigProvider);
    if (!config.useRemote || config.isConfigured) {
      return true;
    }

    _showApiUrlSheet();
    return false;
  }

  void _showApiUrlSheet() {
    final currentUrl = ref.read(apiConfigProvider).apiUrl;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LoginApiUrlSheet(
        currentUrl: currentUrl,
        onSave: (url) async {
          await ref.read(apiConfigProvider.notifier).setApiUrl(url);
        },
      ),
    );
  }

  void _showDeviceBindingError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.phonelink_lock, color: AppColors.error),
            SizedBox(width: 8),
            Text('Device Not Allowed'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final apiConfig = ref.watch(apiConfigProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Rich gradient background ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF071A3E),
                  Color(0xFF0D47A1),
                  Color(0xFF1565C0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ── Decorative orbs ───────────────────────────────────────
          AnimatedBuilder(
            animation: _orbController,
            builder: (_, __) {
              final t = _orbController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -80 + (t * 30),
                    right: -70,
                    child: _Orb(size: 260, opacity: 0.07),
                  ),
                  Positioned(
                    top: size.height * 0.12 + (t * -20),
                    left: -100,
                    child: _Orb(size: 220, opacity: 0.05),
                  ),
                  Positioned(
                    top: size.height * 0.28,
                    right: 20 + (t * 15),
                    child: _Orb(size: 80, opacity: 0.09),
                  ),
                  Positioned(
                    top: size.height * 0.18 + (t * 12),
                    left: size.width * 0.4,
                    child: _Orb(size: 50, opacity: 0.12),
                  ),
                ],
              );
            },
          ),

          // ── Main content ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      if (!AppConstants.canUseRemoteData) ...[
                        TextButton.icon(
                          onPressed: () async {
                            final nextUseRemote = !apiConfig.useRemote;
                            await ref
                                .read(apiConfigProvider.notifier)
                                .setUseRemote(nextUseRemote);
                            if (!context.mounted) {
                              return;
                            }
                            if (nextUseRemote && apiConfig.apiUrl.isEmpty) {
                              _showApiUrlSheet();
                            }
                            AppUtils.showSnackBar(
                              context,
                              nextUseRemote
                                  ? 'Remote backend mode enabled'
                                  : 'Demo mode enabled',
                            );
                          },
                          icon: Icon(
                            apiConfig.useRemote
                                ? Icons.cloud_done_outlined
                                : Icons.smart_toy_outlined,
                            size: 18,
                          ),
                          label: Text(
                            apiConfig.useRemote ? 'Remote' : 'Demo',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _showApiUrlSheet,
                        icon: const Icon(Icons.dns_outlined, size: 18),
                        label: Text(
                          apiConfig.apiUrl.isEmpty
                              ? 'Set API URL'
                              : 'API Config',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Logo + brand
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _logoScaleAnim,
                    child: Column(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1B3F6B)
                                    .withValues(alpha: 0.3),
                                blurRadius: 28,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            'assets/images/parcel_express_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 18),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Parcel ',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Express',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE87722),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'HR MANAGEMENT SYSTEM',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.65),
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ── Login card ─────────────────────────────────────
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(26, 30, 26, 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF6F8FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(36),
                            topRight: Radius.circular(36),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Welcome Back!',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF071A3E),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Sign in to your account',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySurface,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.2)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.lock_outline,
                                              size: 12,
                                              color: AppColors.primary),
                                          SizedBox(width: 4),
                                          Text(
                                            'Secure',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),

                                // Email field
                                _StyledTextField(
                                  controller: _emailController,
                                  label: 'Email / Mobile',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Email is required'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Password field
                                _StyledTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  obscureText: !_showPassword,
                                  textInputAction: TextInputAction.done,
                                  suffix: GestureDetector(
                                    onTap: () => setState(
                                        () => _showPassword = !_showPassword),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Icon(
                                        _showPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.length < 4
                                      ? 'Password is required'
                                      : null,
                                ),

                                // Error message
                                if (authState.error != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.error
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline,
                                            color: AppColors.error, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            authState.error!,
                                            style: const TextStyle(
                                                color: AppColors.error,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 28),

                                // ── Gradient Sign In button ────────
                                GestureDetector(
                                  onTapDown: authState.isLoading
                                      ? null
                                      : (_) => _btnController.forward(),
                                  onTapUp: (_) => _btnController.reverse(),
                                  onTapCancel: () => _btnController.reverse(),
                                  onTap: authState.isLoading ? null : _login,
                                  child: AnimatedBuilder(
                                    animation: _btnController,
                                    builder: (_, child) => Transform.scale(
                                      scale: _btnScale.value,
                                      child: child,
                                    ),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: double.infinity,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: authState.isLoading
                                            ? null
                                            : const LinearGradient(
                                                colors: [
                                                  Color(0xFF1565C0),
                                                  Color(0xFF42A5F5),
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                        color: authState.isLoading
                                            ? AppColors.primaryLight
                                                .withValues(alpha: 0.6)
                                            : null,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: authState.isLoading
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: const Color(0xFF1565C0)
                                                      .withValues(alpha: 0.45),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 7),
                                                ),
                                              ],
                                      ),
                                      child: Center(
                                        child: authState.isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Sign In',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Icon(
                                                    Icons.arrow_forward_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),

                                // ── Biometric button ───────────────
                                if (_biometricAvailable) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Divider(
                                              color: Colors.grey.shade300)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        child: Text(
                                          'or',
                                          style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 13),
                                        ),
                                      ),
                                      Expanded(
                                          child: Divider(
                                              color: Colors.grey.shade300)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: OutlinedButton.icon(
                                      onPressed: _loginWithBiometric,
                                      icon: Icon(
                                        BiometricService.isFaceId(
                                                _biometricTypes)
                                            ? Icons.face_retouching_natural
                                            : Icons.fingerprint,
                                        size: 24,
                                        color: AppColors.primary,
                                      ),
                                      label: Text(
                                        'Sign in with ${BiometricService.getBiometricLabel(_biometricTypes)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.5),
                                            width: 1.5),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        backgroundColor: AppColors
                                            .primarySurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 22),

                                if (kDebugMode) ...[
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF4FF),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.15)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                  Icons.info_outline,
                                                  size: 14,
                                                  color: AppColors.primary),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Debug Demo Accounts',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Tap to fill',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _demoAccount(
                                            'Admin',
                                            'admin@smarthr.com',
                                            Icons.admin_panel_settings_outlined,
                                            AppColors.primary),
                                        const SizedBox(height: 6),
                                        _demoAccount(
                                            'Supervisor',
                                            'supervisor@smarthr.com',
                                            Icons.supervisor_account_outlined,
                                            AppColors.accent),
                                        const SizedBox(height: 6),
                                        _demoAccount(
                                            'Staff',
                                            'staff@smarthr.com',
                                            Icons.person_outline,
                                            AppColors.success),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.key_outlined,
                                                  size: 12,
                                                  color: Colors.grey.shade500),
                                              const SizedBox(width: 4),
                                              Text(
                                                'password123',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _demoAccount(String role, String email, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = 'password123';
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 8),
            Text(
              '$role: ',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              email,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  final double size;
  final double opacity;

  const _Orb({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _LoginApiUrlSheet extends StatefulWidget {
  const _LoginApiUrlSheet({
    required this.currentUrl,
    required this.onSave,
  });

  final String currentUrl;
  final Future<void> Function(String) onSave;

  @override
  State<_LoginApiUrlSheet> createState() => _LoginApiUrlSheetState();
}

class _LoginApiUrlSheetState extends State<_LoginApiUrlSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(_controller.text.trim());
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
    AppUtils.showSnackBar(context, 'API URL saved');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'API Server URL',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the backend API URL, for example https://api.example.com/api',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: 'https://api.example.com/api',
              prefixIcon: const Icon(Icons.link, color: AppColors.primary),
              filled: true,
              fillColor: const Color(0xFFF6F8FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save URL',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _StyledTextField({
    required this.label,
    required this.icon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(
          fontSize: 14, color: Color(0xFF071A3E), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}
