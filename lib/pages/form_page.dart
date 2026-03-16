import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/car.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class FormPage extends StatefulWidget {
  final Car? car;
  const FormPage({super.key, this.car});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _color;
  late TextEditingController _price;

  Uint8List? _imageBytes;
  bool _isSaving = false;

  late AnimationController _enterAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool get _isEdit => widget.car != null;

  @override
  void initState() {
    super.initState();
    _name  = TextEditingController(text: widget.car?.name  ?? '');
    _color = TextEditingController(text: widget.car?.color ?? '');
    _price = TextEditingController(text: widget.car?.price ?? '');

    _enterAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _fadeAnim  = CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, .04), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterAnim, curve: Curves.easeOutCubic));

    _enterAnim.forward();
  }

  @override
  void dispose() {
    _enterAnim.dispose();
    _name.dispose(); _color.dispose(); _price.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery, imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final car = Car(
        id:    widget.car?.id,
        name:  _name.text.trim(),
        color: _color.text.trim(),
        price: _price.text.trim(),
        imageUrl: widget.car?.imageUrl,
      );

      if (_isEdit) {
        await SupabaseService.updateCar(car, imageBytes: _imageBytes);
      } else {
        await SupabaseService.addCar(car, imageBytes: _imageBytes);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600)),
            backgroundColor: context.c.accent.withOpacity(.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: _buildAppBar(c),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              physics: const BouncingScrollPhysics(),
              children: [
                _PhotoPicker(
                  imageBytes: _imageBytes,
                  existingUrl: widget.car?.imageUrl,
                  onTap: _pickImage,
                ),
                const SizedBox(height: 32),

                _sectionLabel('DETAIL KENDARAAN', c),
                const SizedBox(height: 16),

                _Field(
                  controller: _name,
                  label: 'Nama Mobil',
                  hint: 'e.g. Nissan GT-R R35',
                  icon: Icons.directions_car_rounded,
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 14),

                _Field(
                  controller: _color,
                  label: 'Warna',
                  hint: 'e.g. Midnight Blue',
                  icon: Icons.palette_rounded,
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Warna tidak boleh kosong' : null,
                ),
                const SizedBox(height: 14),

                _Field(
                  controller: _price,
                  label: 'Harga Sewa / Hari',
                  hint: 'e.g. 500000',
                  icon: Icons.monetization_on_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixText: 'Rp  ',
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Harga tidak boleh kosong' : null,
                ),

                const SizedBox(height: 36),

                _SaveButton(isEdit: _isEdit, isSaving: _isSaving, onTap: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors c) {
    return AppBar(
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.border, width: 1),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: c.textPri, size: 16),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEdit ? 'EDIT MOBIL' : 'TAMBAH MOBIL',
            style: GoogleFonts.orbitron(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: c.textPri, letterSpacing: 1.5,
            ),
          ),
          Text(
            _isEdit ? 'Perbarui data kendaraan' : 'Daftarkan kendaraan baru',
            style: GoogleFonts.rajdhani(fontSize: 12, color: c.textSec),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent, c.neon.withOpacity(.3), Colors.transparent,
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, AppColors c) {
    return Row(
      children: [
        Container(
          width: 3, height: 14,
          decoration: BoxDecoration(
            color: c.neon, borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: GoogleFonts.rajdhani(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: c.textSec, letterSpacing: 2,
        )),
      ],
    );
  }
}

// ─── PHOTO PICKER ─────────────────────────────────────────────────────────────
class _PhotoPicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? existingUrl;
  final VoidCallback onTap;

  const _PhotoPicker({
    required this.imageBytes,
    required this.onTap,
    this.existingUrl,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasImage = imageBytes != null || existingUrl != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 200,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasImage ? c.neon.withOpacity(.4) : c.border,
            width: 1.5,
          ),
          boxShadow: hasImage
              ? [BoxShadow(color: c.neon.withOpacity(.08), blurRadius: 24)]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background / Image
              if (!hasImage) _EmptyPhoto()
              else if (imageBytes != null)
                Image.memory(imageBytes!, fit: BoxFit.cover)
              else
                Image.network(
                  existingUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _EmptyPhoto(),
                ),

              // Edit overlay (only when has image)
              if (hasImage)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(.7)],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_rounded,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text('Ketuk untuk ganti foto',
                          style: GoogleFonts.rajdhani(
                              fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Stack(
      children: [
        CustomPaint(painter: _GridPainter(color: c.border),
            child: const SizedBox.expand()),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.neon.withOpacity(.08),
                  border: Border.all(color: c.neon.withOpacity(.3), width: 1.5),
                ),
                child: Icon(Icons.add_a_photo_rounded, color: c.neon, size: 24),
              ),
              const SizedBox(height: 12),
              Text('UNGGAH FOTO', style: GoogleFonts.orbitron(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: c.neon, letterSpacing: 2,
              )),
              const SizedBox(height: 4),
              Text('Ketuk untuk memilih dari galeri',
                style: GoogleFonts.rajdhani(fontSize: 12, color: c.textSec)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── FIELD ────────────────────────────────────────────────────────────────────
class _Field extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixText,
    this.validator,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focused ? c.neon.withOpacity(.6) : c.border,
            width: _focused ? 1.5 : 1,
          ),
          boxShadow: _focused
              ? [BoxShadow(color: c.neon.withOpacity(.06), blurRadius: 16)]
              : null,
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          style: GoogleFonts.rajdhani(
            fontSize: 15, fontWeight: FontWeight.w600, color: c.textPri,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixText: widget.prefixText,
            prefixStyle: GoogleFonts.rajdhani(
              fontSize: 14, fontWeight: FontWeight.w600, color: c.neon,
            ),
            labelStyle: GoogleFonts.rajdhani(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: _focused ? c.neon : c.textSec,
            ),
            hintStyle: GoogleFonts.rajdhani(
              fontSize: 14, color: c.textSec.withOpacity(.4),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(widget.icon,
                  color: _focused ? c.neon : c.textSec, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 52),
            filled: false,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            errorStyle: GoogleFonts.rajdhani(
              fontSize: 11, color: c.accent, fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SAVE BUTTON ─────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool isEdit;
  final bool isSaving;
  final VoidCallback onTap;
  const _SaveButton({
    required this.isEdit, required this.isSaving, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isSaving
                ? [c.neon.withOpacity(.3), c.neon.withOpacity(.2)]
                : [c.neon, const Color(0xff0077aa)],
          ),
          boxShadow: isSaving ? null : [
            BoxShadow(
              color: c.neon.withOpacity(.3),
              blurRadius: 20, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isSaving
            ? Center(child: SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: c.neon, strokeWidth: 2),
              ))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isEdit ? Icons.save_rounded : Icons.add_circle_rounded,
                      color: c.bg, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAHKAN MOBIL',
                    style: GoogleFonts.orbitron(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: c.bg, letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── GRID PAINTER ─────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(.5)..strokeWidth = .5;
    const step = 28.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
