import 'package:diario_colaborativo/features/diary/data/results/diary_failed.dart';

String diaryFailureUserMessage(DiaryFailed failure) {
  return switch (failure) {
    DiaryFailed.notAuthenticated => 'Faça login para ver suas entradas.',
    DiaryFailed.offline =>
      'Sem conexão. Verifique sua internet e tente novamente.',
    DiaryFailed.notFound => 'Entrada não encontrada.',
    DiaryFailed.unknown => 'Algo deu errado. Tente novamente.',
  };
}
