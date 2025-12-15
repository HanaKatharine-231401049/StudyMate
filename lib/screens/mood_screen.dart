import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  // Spotify playlist links
  static const String deepFocusUrl =
      'https://open.spotify.com/playlist/3Dg3Yj8rLfwECu1AVZNz22?si=efae95225e234ac9';
  static const String studyUrl =
      'https://open.spotify.com/playlist/1E6KoJG2lWZ6IlGcAnfZhL?si=123327217c3b4820';
  static const String creativeUrl =
      'https://open.spotify.com/playlist/2ty1GmgQkIN0ZGSkNdH42e?si=10f2482fae534e22';
  static const String energeticUrl =
      'https://open.spotify.com/playlist/19xyRNClUFsWhbvLzWOvxb?si=a43b2774678b4644';

  Future<void> _onTapPlaylist(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak dapat membuka Spotify',
            style: GoogleFonts.inter(),
          ),
        ),
      );
    }
  }

  Widget _moodTile({
    required BuildContext context,
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline.withOpacity(0.8)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,

      appBar: AppBar(
        backgroundColor: scheme.background,
        elevation: 0,
        title: const Text(''),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: scheme.primary),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserratAlternates(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scheme.onBackground,
                  ),
                  children: [
                    const TextSpan(text: 'Find your perfect '),
                    TextSpan(
                      text: 'music',
                      style: TextStyle(color: scheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserratAlternates(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scheme.onBackground,
                  ),
                  children: [
                    const TextSpan(text: 'to '),
                    TextSpan(
                      text: 'study',
                      style: TextStyle(color: scheme.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: scheme.outline.withOpacity(0.8)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Choose Your Mood',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _moodTile(
                          context: context,
                          imagePath: 'assets/images/brain 1.png',
                          label: 'Deep Focus',
                          onTap: () => _onTapPlaylist(context, deepFocusUrl),
                        ),
                        _moodTile(
                          context: context,
                          imagePath: 'assets/images/book-stack 1.png',
                          label: 'Study',
                          onTap: () => _onTapPlaylist(context, studyUrl),
                        ),
                        _moodTile(
                          context: context,
                          imagePath: 'assets/images/paint-palette 1.png',
                          label: 'Creative',
                          onTap: () => _onTapPlaylist(context, creativeUrl),
                        ),
                        _moodTile(
                          context: context,
                          imagePath: 'assets/images/lightning 1.png',
                          label: 'Energetic',
                          onTap: () => _onTapPlaylist(context, energeticUrl),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}