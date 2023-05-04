part of 'epub_manager_bloc.dart';

enum EpubManagerStatus { init, loading, success, error, downloading, downloaded, removing, removed }

extension EpubManagerStatusX on EpubManagerStatus {
  bool get isInit => this == EpubManagerStatus.init;

  bool get isLoading => this == EpubManagerStatus.loading;

  bool get isSuccess => this == EpubManagerStatus.success;

  bool get isError => this == EpubManagerStatus.error;

  bool get isDownloading => this == EpubManagerStatus.downloading;

  bool get isDownloaded => this == EpubManagerStatus.downloaded;

  bool get isRemoving => this == EpubManagerStatus.removing;

  bool get isRemoved => this == EpubManagerStatus.removed;
}

class EpubManagerState extends Equatable {
  const EpubManagerState({
    this.status = EpubManagerStatus.init,
    this.ePubs = const [],
    this.downloadPercent = const {0: 0},
    this.removePercent = const {0: 0},
  });

  final EpubManagerStatus status;
  final List<EpubBookModel> ePubs;
  final Map<int, double> downloadPercent; // Map<ePubId, Download-Percent>
  final Map<int, double> removePercent;

  EpubManagerState copyWith({
    EpubManagerStatus? status,
    List<EpubBookModel>? ePubs,
    Map<int, double>? downloadPercent,
    Map<int, double>? removePercent,
  }) {
    return EpubManagerState(
      status: status ?? this.status,
      ePubs: ePubs ?? this.ePubs,
      downloadPercent: downloadPercent ?? this.downloadPercent,
      removePercent: removePercent ?? this.removePercent,
    );
  }

  @override
  List<Object?> get props => [status, ePubs, downloadPercent, removePercent];
}
