part of 'epub_manager_bloc.dart';

abstract class EpubManagerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchEpubBooksEvent extends EpubManagerEvent {}

class DownloadEpubBookEvent extends EpubManagerEvent {
  final String ePubName;
  final int id;

  DownloadEpubBookEvent({required this.ePubName, required this.id});
}

class RemoveEpubBookEvent extends EpubManagerEvent {
  final String ePubName;
  final int id;

  RemoveEpubBookEvent({required this.ePubName, required this.id});
}

class UpdateEpubBookEvent extends EpubManagerEvent {
  final int ePubId;
  final Function? onSuccess;

  UpdateEpubBookEvent({required this.ePubId, this.onSuccess});
}