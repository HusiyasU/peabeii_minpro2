import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/car.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<Car> _cars = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    setState(() { _loading = true; _error = null; });
    try {
      final cars = await SupabaseService.getCars();
      if (mounted) setState(() { _cars = cars; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _openForm({Car? car}) async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => FormPage(car: car),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0), end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
    if (result == true) _fetchCars();
  }

  void _confirmDelete(Car car) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _DeleteDialog(
        carName: car.name,
        onConfirm: () => _deleteCar(car),
      ),
    );
  }

  Future<void> _deleteCar(Car car) async {
    if (car.id == null) return;
    try {
      await SupabaseService.deleteCar(car.id!);
      _fetchCars();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: context.c.accent,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await SupabaseService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: c.bg,
            surfaceTintColor: Colors.transparent,
            actions: [
              // Theme toggle
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: c.textSec,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  MyApp.toggleTheme();
                },
              ),
              // Logout
              IconButton(
                icon: Icon(Icons.logout_rounded, color: c.textSec),
                onPressed: _signOut,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: c.neon.withOpacity(.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c.neon.withOpacity(.4), width: 1),
                    ),
                    child: Icon(Icons.speed_rounded, color: c.neon, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'TUNING RENTAL',
                    style: GoogleFonts.orbitron(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: c.textPri,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    c.neon.withOpacity(.3),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),

          // ── Stats ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'TOTAL MOBIL',
                      value: _cars.length.toString(),
                      icon: Icons.directions_car_rounded,
                      color: c.neon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'TERSEDIA',
                      value: _cars.length.toString(),
                      icon: Icons.check_circle_rounded,
                      color: c.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Section label ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3, height: 16,
                        decoration: BoxDecoration(
                          color: c.neon,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'ARMADA MOBIL',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: c.textSec,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  // Refresh button
                  GestureDetector(
                    onTap: _fetchCars,
                    child: Icon(Icons.refresh_rounded,
                        color: c.textSec, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──
          if (_loading)
            SliverFillRemaining(child: _LoadingState())
          else if (_error != null)
            SliverFillRemaining(child: _ErrorState(onRetry: _fetchCars))
          else if (_cars.isEmpty)
            SliverFillRemaining(child: _EmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList.builder(
                itemCount: _cars.length,
                itemBuilder: (_, i) => _CarCard(
                  car: _cars[i],
                  index: i,
                  onEdit: () => _openForm(car: _cars[i]),
                  onDelete: () => _confirmDelete(_cars[i]),
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: _PulseFab(onTap: () => _openForm()),
    );
  }
}

// ─── STAT CARD ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.2), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(.06), blurRadius: 20),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.rajdhani(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: c.textSec, letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 22, fontWeight: FontWeight.w700, color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CAR CARD ─────────────────────────────────────────────────────────────────
class _CarCard extends StatefulWidget {
  final Car car;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CarCard({
    required this.car,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<_CarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 60),
    );
    _scale = Tween<double>(begin: .92, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );
    _anim.forward();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(context.isDark ? .4 : .08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _CarThumbnail(imageUrl: widget.car.imageUrl),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.car.name.toUpperCase(),
                              style: GoogleFonts.orbitron(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: c.textPri,
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            _Tag(label: widget.car.color, color: c.gold),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('Rp ', style: GoogleFonts.rajdhani(
                                  fontSize: 11, color: c.textSec,
                                  fontWeight: FontWeight.w600,
                                )),
                                Text(widget.car.price, style: GoogleFonts.orbitron(
                                  fontSize: 15, fontWeight: FontWeight.w700,
                                  color: c.neon,
                                )),
                                Text('/hari', style: GoogleFonts.rajdhani(
                                  fontSize: 11, color: c.textSec,
                                  fontWeight: FontWeight.w600,
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ActionBtn(icon: Icons.edit_rounded,
                              color: c.gold, onTap: widget.onEdit),
                          const SizedBox(height: 8),
                          _ActionBtn(icon: Icons.delete_rounded,
                              color: c.accent, onTap: widget.onDelete),
                        ],
                      ),
                    ],
                  ),
                ),
                // Top neon line
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        c.neon.withOpacity(.5),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── CAR THUMBNAIL ────────────────────────────────────────────────────────────
class _CarThumbnail extends StatelessWidget {
  final String? imageUrl;
  const _CarThumbnail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: c.surface,
        border: Border.all(color: c.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: imageUrl == null
            ? Center(child: Icon(Icons.directions_car_rounded,
                color: c.textSec, size: 30))
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: c.textSec, size: 26),
                ),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Center(child: SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: c.neon,
                        ),
                      )),
              ),
      ),
    );
  }
}

// ─── TAG ──────────────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(.3), width: 1),
      ),
      child: Text(label, style: GoogleFonts.rajdhani(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: color, letterSpacing: .5,
      )),
    );
  }
}

// ─── ACTION BUTTON ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(.25), width: 1),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}

// ─── PULSE FAB ────────────────────────────────────────────────────────────────
class _PulseFab extends StatefulWidget {
  final VoidCallback onTap;
  const _PulseFab({required this.onTap});

  @override
  State<_PulseFab> createState() => _PulseFabState();
}

class _PulseFabState extends State<_PulseFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400),
    )..repeat();
    _ring = Tween<double>(begin: .85, end: 1.3).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); widget.onTap(); },
      child: SizedBox(
        width: 64, height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _ring,
              builder: (_, __) => Transform.scale(
                scale: _ring.value,
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c.neon.withOpacity(1.3 - _ring.value),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.neon,
                boxShadow: [
                  BoxShadow(
                    color: c.neon.withOpacity(.4),
                    blurRadius: 20, spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(Icons.add_rounded, color: c.bg, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STATES ───────────────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36, height: 36,
            child: CircularProgressIndicator(color: c.neon, strokeWidth: 2),
          ),
          const SizedBox(height: 16),
          Text('Memuat armada...', style: GoogleFonts.rajdhani(
            fontSize: 14, color: c.textSec,
          )),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: c.accent, size: 48),
          const SizedBox(height: 16),
          Text('Gagal memuat data', style: GoogleFonts.orbitron(
            fontSize: 13, fontWeight: FontWeight.w700, color: c.textSec,
          )),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: c.neon.withOpacity(.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.neon.withOpacity(.3)),
              ),
              child: Text('COBA LAGI', style: GoogleFonts.orbitron(
                fontSize: 11, fontWeight: FontWeight.w700, color: c.neon,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.card,
              border: Border.all(color: c.border, width: 1.5),
            ),
            child: Icon(Icons.directions_car_rounded, color: c.textSec, size: 40),
          ),
          const SizedBox(height: 20),
          Text('ARMADA KOSONG', style: GoogleFonts.orbitron(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: c.textSec, letterSpacing: 2,
          )),
          const SizedBox(height: 8),
          Text('Tambahkan mobil pertama Anda', style: GoogleFonts.rajdhani(
            fontSize: 14, color: c.textSec.withOpacity(.6),
          )),
        ],
      ),
    );
  }
}

// ─── DELETE DIALOG ────────────────────────────────────────────────────────────
class _DeleteDialog extends StatelessWidget {
  final String carName;
  final VoidCallback onConfirm;
  const _DeleteDialog({required this.carName, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Dialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: c.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accent.withOpacity(.1),
                border: Border.all(color: c.accent.withOpacity(.3), width: 1.5),
              ),
              child: Icon(Icons.delete_forever_rounded, color: c.accent, size: 28),
            ),
            const SizedBox(height: 16),
            Text('HAPUS MOBIL', style: GoogleFonts.orbitron(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: c.textPri, letterSpacing: 1.5,
            )),
            const SizedBox(height: 8),
            Text('Hapus "$carName" dari armada?',
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(fontSize: 14, color: c.textSec),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _DialogBtn(
                  label: 'BATAL',
                  color: c.textSec,
                  onTap: () => Navigator.pop(context),
                )),
                const SizedBox(width: 12),
                Expanded(child: _DialogBtn(
                  label: 'HAPUS',
                  color: c.accent,
                  filled: true,
                  onTap: () { Navigator.pop(context); onConfirm(); },
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _DialogBtn({
    required this.label, required this.color,
    this.filled = false, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(.4), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(label, style: GoogleFonts.orbitron(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: filled ? Colors.white : color,
          letterSpacing: 1.5,
        )),
      ),
    );
  }
}
