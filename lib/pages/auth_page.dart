import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _switchMode() {
    HapticFeedback.lightImpact();
    setState(() => _isLogin = !_isLogin);
    _anim.forward(from: 0);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await SupabaseService.signIn(
          email:    _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        final res = await SupabaseService.signUp(
          email:    _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        if (res.user != null && !mounted) return;
        if (mounted && !_isLogin) {
          _showSnack('Akun berhasil dibuat! Silakan login.', success: true);
          setState(() => _isLogin = true);
        }
      }
    } on AuthException catch (e) {
      if (mounted) _showSnack(e.message);
    } catch (e) {
      if (mounted) _showSnack('Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.rajdhani(
          fontWeight: FontWeight.w600,
        )),
        backgroundColor: success
            ? context.c.neon.withOpacity(.9)
            : context.c.accent.withOpacity(.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo ──
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.neon.withOpacity(.1),
                          border: Border.all(color: c.neon.withOpacity(.4), width: 1.5),
                        ),
                        child: Icon(Icons.speed_rounded, color: c.neon, size: 34),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'TUNING RENTAL',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: c.textPri,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isLogin ? 'Masuk ke akun Anda' : 'Buat akun baru',
                        style: GoogleFonts.rajdhani(
                          fontSize: 14, color: c.textSec,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Card ──
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: c.border, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _AuthField(
                              controller: _emailCtrl,
                              label: 'Email',
                              icon: Icons.email_rounded,
                              keyboard: TextInputType.emailAddress,
                              validator: (v) => (v?.isEmpty ?? true)
                                  ? 'Email tidak boleh kosong'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            _AuthField(
                              controller: _passCtrl,
                              label: 'Password',
                              icon: Icons.lock_rounded,
                              obscure: _obscure,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: c.textSec, size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) => (v?.length ?? 0) < 6
                                  ? 'Password minimal 6 karakter'
                                  : null,
                            ),

                            const SizedBox(height: 24),

                            // Submit button
                            _SubmitButton(
                              label: _isLogin ? 'MASUK' : 'DAFTAR',
                              loading: _loading,
                              onTap: _submit,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Switch mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? 'Belum punya akun? '
                                : 'Sudah punya akun? ',
                            style: GoogleFonts.rajdhani(
                              fontSize: 14, color: c.textSec,
                            ),
                          ),
                          GestureDetector(
                            onTap: _switchMode,
                            child: Text(
                              _isLogin ? 'Daftar' : 'Masuk',
                              style: GoogleFonts.rajdhani(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: c.neon,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AUTH FIELD ───────────────────────────────────────────────────────────────
class _AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType keyboard;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboard = TextInputType.text,
    this.validator,
  });

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused ? c.neon.withOpacity(.6) : c.border,
            width: _focused ? 1.5 : 1,
          ),
          boxShadow: _focused
              ? [BoxShadow(color: c.neon.withOpacity(.06), blurRadius: 12)]
              : null,
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscure,
          keyboardType: widget.keyboard,
          validator: widget.validator,
          style: GoogleFonts.rajdhani(
            fontSize: 15, fontWeight: FontWeight.w600, color: c.textPri,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: GoogleFonts.rajdhani(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: _focused ? c.neon : c.textSec,
            ),
            prefixIcon: Icon(widget.icon,
                color: _focused ? c.neon : c.textSec, size: 20),
            suffixIcon: widget.suffixIcon,
            filled: false,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16,
            ),
            errorStyle: GoogleFonts.rajdhani(
              fontSize: 11, color: c.accent, fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SUBMIT BUTTON ────────────────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: loading
                ? [c.neon.withOpacity(.3), c.neon.withOpacity(.2)]
                : [c.neon, const Color(0xff0077aa)],
          ),
          boxShadow: loading
              ? null
              : [
                  BoxShadow(
                    color: c.neon.withOpacity(.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: loading
            ? Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    color: c.neon, strokeWidth: 2,
                  ),
                ),
              )
            : Center(
                child: Text(
                  label,
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
      ),
    );
  }
}
