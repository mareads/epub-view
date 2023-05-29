import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppNavigatorButton extends StatelessWidget {
  const AppNavigatorButton({
    Key? key,
    this.size,
    this.iconSize,
    this.iconColor,
    this.decoration,
    this.alignment,
    this.padding,
    this.margin,
    this.child,
    this.icon = "",
    required this.onTap,
  }) : super(key: key);

  final String icon;
  final Size? size;
  final Size? iconSize;
  final Color? iconColor;
  final BoxDecoration? decoration;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final void Function()? onTap;

  factory AppNavigatorButton.asset({
    Size? size,
    Size? iconSize,
    Color? iconColor,
    BoxDecoration? decoration,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    required String icon,
    required void Function()? onTap,
  }) {
    return AppNavigatorButton(
      size: size,
      iconSize: iconSize,
      iconColor: iconColor,
      decoration: decoration,
      alignment: alignment,
      padding: padding,
      margin: margin,
      icon: icon,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (child == null && icon.isEmpty) {
      assert(child != null || icon.isNotEmpty);
    } else if (child == null) {
      assert(icon.isNotEmpty);
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        width: size?.width ?? 40,
        height: size?.height ?? 40,
        decoration: BoxDecoration(
          color: decoration?.color ?? const Color(0xFFFFFFFF),
          border: decoration?.border ?? Border.all(color: const Color(0xFFf4f4f7)),
          borderRadius: decoration?.borderRadius ?? BorderRadius.circular(20),
        ),
        alignment: alignment,
        padding: padding ?? const EdgeInsets.all(8),
        margin: margin,
        child: child ??
            (icon.contains(".svg")
                ? SvgPicture.asset(
                    icon,
                    color: iconColor,
                    width: iconSize?.width,
                    height: iconSize?.height,
                    package: "epub_view",
                  )
                : Image.asset(
                    icon,
                    color: iconColor,
                    width: iconSize?.width,
                    height: iconSize?.height,
                    package: "epub_view",
                  )),
      ),
    );
  }
}
