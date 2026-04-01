/// Tags de humor pré-configuradas para entradas do diário.
class MoodTagPreset {
  const MoodTagPreset({
    required this.id,
    required this.emoji,
    required this.label,
  });

  final String id;
  final String emoji;
  final String label;

  static const feliz = MoodTagPreset(id: 'feliz', emoji: '😊', label: 'feliz');
  static const gratidao = MoodTagPreset(
      id: 'gratidao', emoji: '🌸', label: 'gratidão');
  static const inspirada = MoodTagPreset(
      id: 'inspirada', emoji: '✨', label: 'inspirada');
  static const sensivel = MoodTagPreset(
      id: 'sensivel', emoji: '🌧', label: 'sensível');
  static const paz = MoodTagPreset(id: 'paz', emoji: '🌿', label: 'paz');
  static const reflexiva = MoodTagPreset(
      id: 'reflexiva', emoji: '💭', label: 'reflexiva');

  static const List<MoodTagPreset> all = [
    feliz,
    gratidao,
    inspirada,
    sensivel,
    paz,
    reflexiva,
  ];

  static MoodTagPreset? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    return all.firstWhere((p) => p.id == id, orElse: () => feliz);
  }
}
