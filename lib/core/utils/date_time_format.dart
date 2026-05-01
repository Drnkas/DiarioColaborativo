
String formatRelativeTimePt(
  DateTime dateTime, {
  bool includeYearWhenOld = true,
}) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inMinutes < 60) return '${diff.inMinutes}min';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return includeYearWhenOld
      ? '${dateTime.day}/${dateTime.month}/${dateTime.year}'
      : '${dateTime.day}/${dateTime.month}';
}

/// Formata [date] como `HH:mm · d mês abrev. ano`
String formatTimeAndShortDatePt(DateTime date) {
  const months = [
    'jan.',
    'fev.',
    'mar.',
    'abr.',
    'mai.',
    'jun.',
    'jul.',
    'ago.',
    'set.',
    'out.',
    'nov.',
    'dez.',
  ];
  final hh = date.hour.toString().padLeft(2, '0');
  final mm = date.minute.toString().padLeft(2, '0');
  final month = months[(date.month - 1).clamp(0, 11)];
  return '$hh:$mm · ${date.day} $month ${date.year}';
}
