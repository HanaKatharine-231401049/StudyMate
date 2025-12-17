import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';

typedef NoteTapCallback = void Function(Note note);
typedef NoteSearchCallback = void Function(String query);

class NoteTab extends StatelessWidget {
  final List<Note> notes;
  final NoteSearchCallback onSearch;
  final NoteTapCallback onTapNote;

  const NoteTab({
    super.key,
    required this.notes,
    required this.onSearch,
    required this.onTapNote,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'List Notes',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: scheme.onBackground,
                  ),
                ),
              ),

              // SEARCH FIELD
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: onSearch,
                  style: GoogleFonts.inter(color: scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search Notes',
                    hintStyle: GoogleFonts.inter(
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                    prefixIcon: Icon(Icons.search, color: scheme.primary),

                    isDense: true,
                    filled: true,
                    fillColor: scheme.surface,

                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 10),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: scheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: scheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: scheme.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // NOTES LIST
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              return GestureDetector(
                onTap: () => onTapNote(note),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: scheme.outline),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withOpacity(0.05),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        note.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: scheme.onSurface.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}