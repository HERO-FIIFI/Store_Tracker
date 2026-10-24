import 'package:flutter/material.dart';
import 'package:store_tracker/services/voice_input_service.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onResult;
  final Function(String)? onPartialResult;
  final VoiceInputType type;
  final IconData icon;
  final Color? color;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.onPartialResult,
    this.type = VoiceInputType.text,
    this.icon = Icons.mic,
    this.color,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  bool _isAvailable = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _checkAvailability();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    final available = await VoiceInputService.isAvailable();
    if (mounted) {
      setState(() {
        _isAvailable = available;
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await VoiceInputService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      try {
        await VoiceInputService.startListening(
          onResult: (text) {
            setState(() {
              _isListening = false;
            });

            // Process result based on type
            switch (widget.type) {
              case VoiceInputType.numeric:
                final number = VoiceInputService.parseNumericInput(text);
                if (number != null) {
                  widget.onResult(number.toString());
                } else {
                  _showError('Could not understand number');
                }
                break;
              case VoiceInputType.text:
                widget.onResult(text);
                break;
            }
          },
          onPartialResult: widget.onPartialResult,
        );

        setState(() {
          _isListening = true;
        });
      } catch (e) {
        _showError('Voice input error: $e');
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (_isListening)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (widget.color ?? Theme.of(context).primaryColor)
                        .withOpacity(0.3 * (1 - _animationController.value)),
                  ),
                ),
              Icon(
                widget.icon,
                color: _isListening
                    ? widget.color ?? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ],
          );
        },
      ),
      onPressed: _toggleListening,
      tooltip: _isListening ? 'Stop listening' : 'Voice input',
    );
  }
}

enum VoiceInputType {
  text,
  numeric,
}
