import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

/// タップ時に軽くバウンスし、連打を防止するプライマリボタン。
class BouncyButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  /// 連打防止のクールダウン時間
  final Duration cooldown;

  const BouncyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.cooldown = const Duration(milliseconds: 500),
  });

  @override
  ConsumerState<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends ConsumerState<BouncyButton> {
  bool _pressed = false;
  bool _locked = false;
  Timer? _unlockTimer;

  @override
  void dispose() {
    _unlockTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (_locked) return;
    setState(() => _locked = true);
    if (ref.read(hapticsEnabledProvider)) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed();
    _unlockTimer = Timer(widget.cooldown, () {
      if (mounted) setState(() => _locked = false);
    });
  }

  ButtonStyle get _buttonStyle => ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _locked ? null : (_) => setState(() => _pressed = true),
      onTapUp: _locked
          ? null
          : (_) {
              setState(() => _pressed = false);
              _handleTap();
            },
      onTapCancel: _locked ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.icon == null
            ? ElevatedButton(
                onPressed: _locked ? null : _handleTap,
                style: _buttonStyle,
                child: Text(widget.label),
              )
            : ElevatedButton.icon(
                onPressed: _locked ? null : _handleTap,
                icon: Icon(widget.icon),
                label: Text(widget.label),
                style: _buttonStyle,
              ),
      ),
    );
  }
}
