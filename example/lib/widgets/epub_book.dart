import 'dart:async';

import 'package:flutter/material.dart';

class EpubBookCardView extends StatelessWidget {
  const EpubBookCardView({
    Key? key,
    required this.title,
    this.percent = 0,
    required this.isDownloaded,
    this.isForceDownload = false,
    this.isDeleting = false,
    required this.onDownload,
    required this.onDeleted,
  }) : super(key: key);

  final String title;
  final double percent;
  final bool isDownloaded;
  final bool isForceDownload;
  final bool isDeleting;
  final void Function() onDownload;
  final void Function() onDeleted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
      height: 397,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Placeholder(fallbackWidth: 144, fallbackHeight: 213),
              const SizedBox(height: 8.5),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Text("Pen name...."),
              const SizedBox(height: 21),
              const Text("Book-Type...."),
              const SizedBox(height: 4),
              const Text("Category...."),
              const SizedBox(height: 25),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _StarBoard(),
                    const _StatusPaidBook(),
                    GestureDetector(
                      onTap: () {
                        if (!isDownloaded && isForceDownload) onDownload();
                      },
                      child: _Download(
                        isLoading: percent > 0,
                        value: percent,
                        isForceDownload: isForceDownload,
                        isDownloaded: isDownloaded,
                        isDeleting: isDeleting,
                        onDeleted: onDeleted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarBoard extends StatelessWidget {
  const _StarBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.star_rounded),
        Text("4.6"),
      ],
    );
  }
}

class _StatusPaidBook extends StatelessWidget {
  const _StatusPaidBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xfff1f9ff),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        "ซื้อแล้ว",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _Download extends StatelessWidget {
  const _Download({
    Key? key,
    this.value = 0,
    this.isForceDownload = false,
    required this.isLoading,
    required this.isDownloaded,
    required this.isDeleting,
    required this.onDeleted,
  }) : super(key: key);

  final double value;
  final bool isForceDownload;
  final bool isLoading;
  final bool isDownloaded;
  final bool isDeleting;
  final Function onDeleted;

  @override
  Widget build(BuildContext context) {
    bool openDeleteButton = false;

    return Container(
      width: 44,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xfff1f9ff),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: !isForceDownload
          ? const Icon(Icons.clear, color: Colors.red)
          : StatefulBuilder(builder: (_, setState) {
              if (openDeleteButton) {
                return GestureDetector(
                  onTap: () {
                    if (!isDeleting) {
                      onDeleted.call();
                    }
                  },
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Stack(
                      children: [
                        Visibility(
                          visible: isDeleting,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                            backgroundColor: const Color(0xff858baf),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.delete_forever,
                            size: 20,
                            color: Color(0xff858baf),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return isLoading || !isDownloaded
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            value: value,
                            valueColor:
                                AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                            backgroundColor: const Color(0xff858baf),
                          ),
                          const Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.arrow_downward,
                              size: 20,
                              color: Color(0xff858baf),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() => openDeleteButton = true);

                        Timer.periodic(const Duration(seconds: 1), (timer) => setState(() {
                          if (timer.tick > 5 && !isDeleting) {
                            setState(() => openDeleteButton = false);
                            timer.cancel();
                          }
                        }));
                      },
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
            }),
    );
  }
}
