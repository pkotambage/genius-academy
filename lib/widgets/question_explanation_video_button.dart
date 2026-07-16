import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QuestionExplanationVideoButton extends StatefulWidget {
  final String videoUrl;
  final String? videoTitle;
  final String? videoProvider;

  const QuestionExplanationVideoButton({
    super.key,
    required this.videoUrl,
    this.videoTitle,
    this.videoProvider,
  });

  @override
  State<QuestionExplanationVideoButton> createState() =>
      _QuestionExplanationVideoButtonState();
}

class _QuestionExplanationVideoButtonState
    extends State<QuestionExplanationVideoButton> {
  bool _isOpening = false;

  Future<void> _openVideo() async {
    if (_isOpening) {
      return;
    }

    final uri = Uri.tryParse(widget.videoUrl.trim());

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      _showMessage('The video link is invalid.', isError: true);
      return;
    }

    setState(() {
      _isOpening = true;
    });

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && mounted) {
        _showMessage('Unable to open the video explanation.', isError: true);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to open the video explanation.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpening = false;
        });
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }

  String get _buttonLabel {
    final title = widget.videoTitle?.trim();

    if (title != null && title.isNotEmpty) {
      return title;
    }

    return 'Watch Video Explanation';
  }

  String? get _providerLabel {
    final provider = widget.videoProvider?.trim();

    if (provider == null || provider.isEmpty) {
      return null;
    }

    return 'Opens in $provider';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.ondemand_video_rounded, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Video Explanation',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _isOpening ? null : _openVideo,
              icon: _isOpening
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_circle_fill_rounded),
              label: Text(_isOpening ? 'Opening Video...' : _buttonLabel),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),
            if (_providerLabel != null) ...[
              const SizedBox(height: 7),
              Text(
                _providerLabel!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
