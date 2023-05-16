import 'package:html/dom.dart';

class HorizontalParagraph {
  final int? leadingParagraphNumber;
  final int? endingParagraphNumber;
  final Element? elements;

  const HorizontalParagraph(
      {this.leadingParagraphNumber, this.endingParagraphNumber, this.elements});

  HorizontalParagraph copyWith(
      {int? leadingParagraphNumber,
      int? endingParagraphNumber,
      Element? elements}) {
    return HorizontalParagraph(
        endingParagraphNumber:
            endingParagraphNumber ?? this.endingParagraphNumber,
        elements: elements ?? this.elements,
        leadingParagraphNumber:
            leadingParagraphNumber ?? this.leadingParagraphNumber);
  }
}
