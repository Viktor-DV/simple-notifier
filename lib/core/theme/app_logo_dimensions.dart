/// Единые размеры логотипа (`app_logo.png`) для экрана загрузки и главного экрана.
class AppLogoDimensions {
  AppLogoDimensions._();

  static double logoSize(double shortestSide) =>
      (shortestSide * 0.16).clamp(64.0, 96.0);

  static double gapBelowLogo(double shortestSide) =>
      (shortestSide * 0.03).clamp(12.0, 18.0);
}
