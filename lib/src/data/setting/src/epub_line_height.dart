import 'package:epub_view/src/data/setting/src/value_setting.dart';
import 'package:equatable/equatable.dart';

enum TypeLineHeight { light, normal, medium, hard, extra }

extension ExtensionTypeLineHeight on TypeLineHeight {
  bool get isLight => this == TypeLineHeight.light;
  bool get isNormal => this == TypeLineHeight.normal;
  bool get isMedium => this == TypeLineHeight.medium;
  bool get isHard => this == TypeLineHeight.hard;
  bool get isExtra => this == TypeLineHeight.extra;
}

class EpubLineHeight with EquatableMixin implements ValueLineHeightSettings {
  static const EpubLineHeight factor_1_25 = EpubLineHeight._(TypeLineHeight.light, 1.25);
  static const EpubLineHeight factor_1_5 = EpubLineHeight._(TypeLineHeight.normal, 1.5);
  static const EpubLineHeight factor_2_0 = EpubLineHeight._(TypeLineHeight.medium, 2.0);
  static const EpubLineHeight factor_2_5 = EpubLineHeight._(TypeLineHeight.hard, 2.5);
  static const EpubLineHeight factor_3_0 = EpubLineHeight._(TypeLineHeight.extra, 3.0);

  static const List<EpubLineHeight> values = [
    factor_1_25,
    factor_1_5,
    factor_2_0,
    factor_2_5,
    factor_3_0,
  ];

  @override
  final TypeLineHeight type;
  @override
  final double value;

  const EpubLineHeight._(this.type, this.value);

  @override
  List<Object> get props => [type, value];

  static EpubLineHeight from(String name) =>
      values.firstWhere((type) => type.type.name == name, orElse: () => factor_1_5);

  @override
  String toString() => 'EpubLineHeight{name: ${type.name}, value: $value}';
}
