import 'package:flutter/material.dart';

@immutable
class WorkoutColors extends ThemeExtension<WorkoutColors> {
  const WorkoutColors({
    required this.buttonColor,
    required this.buttonSplashColor,
    required this.appBarColor,
    required this.tabBarColor,
    required this.buttonTextColor,
    required this.cardTextColor,
    required this.textColor,
    required this.specialTextColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.iconColor,
    required this.tabBarIconColor,
    required this.titleColor,
    required this.backgroundColor,
    required this.indicatorColor,
    required this.borderColor,
    required this.drawerColor,
    required this.chestColor,
    required this.backColor,
    required this.armColor,
    required this.legColor,
    required this.abdominalColor,
    required this.cardioColor,
    required this.arcColor,
    required this.greenButtonColor,
    required this.cancelButtonColor,
    required this.backgroundImage,
  });

  final Color buttonColor;
  final Color buttonSplashColor;
  final Color appBarColor;
  final Color tabBarColor;
  final Color buttonTextColor;
  final Color cardTextColor;
  final Color textColor;
  final Color specialTextColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color iconColor;
  final Color tabBarIconColor;
  final Color titleColor;
  final Color backgroundColor;
  final Color indicatorColor;
  final Color borderColor;
  final Color drawerColor;
  final Color chestColor;
  final Color backColor;
  final Color armColor;
  final Color legColor;
  final Color abdominalColor;
  final Color cardioColor;
  final Color arcColor;
  final Color greenButtonColor;
  final Color cancelButtonColor;
  final String backgroundImage;

  static WorkoutColors of(BuildContext context) =>
      Theme.of(context).extension<WorkoutColors>()!;

  static const WorkoutColors dark = WorkoutColors(
    buttonColor: Colors.red,
    buttonSplashColor: Colors.lightGreen,
    appBarColor: Color(0xFF212121),
    // Colors.grey[900]
    tabBarColor: Colors.amber,
    buttonTextColor: Color(0xFF424242),
    // Colors.grey[800]
    cardTextColor: Colors.amber,
    textColor: Colors.amber,
    specialTextColor: Color(0xFFAED581),
    // Colors.lightGreen[300]
    primaryColor: Color(0xFF558B2F),
    // Colors.lightGreen[800]
    secondaryColor: Colors.white,
    iconColor: Colors.amber,
    tabBarIconColor: Colors.amber,
    titleColor: Colors.amber,
    backgroundColor: Colors.black,
    indicatorColor: Colors.red,
    borderColor: Colors.red,
    drawerColor: Color(0xFF424242),
    // Colors.grey[800]
    chestColor: Colors.red,
    backColor: Colors.white,
    armColor: Colors.deepPurple,
    legColor: Colors.green,
    abdominalColor: Colors.indigo,
    cardioColor: Colors.black,
    arcColor: Colors.red,
    greenButtonColor: Colors.green,
    cancelButtonColor: Colors.red,
    backgroundImage: 'graphics/background.jpg',
  );

  static const WorkoutColors light = WorkoutColors(
    buttonColor: Colors.blue,
    buttonSplashColor: Colors.deepPurpleAccent,
    appBarColor: Colors.blue,
    tabBarColor: Colors.black87,
    buttonTextColor: Colors.white,
    cardTextColor: Colors.white,
    textColor: Colors.black87,
    specialTextColor: Colors.black87,
    primaryColor: Colors.blue,
    secondaryColor: Colors.white,
    iconColor: Colors.white,
    tabBarIconColor: Colors.black87,
    titleColor: Colors.white,
    backgroundColor: Colors.white,
    indicatorColor: Colors.blue,
    borderColor: Colors.blue,
    drawerColor: Color(0xFFBBDEFB),
    // Colors.blue[100]
    chestColor: Colors.red,
    backColor: Colors.white,
    armColor: Colors.deepPurple,
    legColor: Colors.green,
    abdominalColor: Colors.indigo,
    cardioColor: Colors.black,
    arcColor: Colors.red,
    greenButtonColor: Colors.green,
    cancelButtonColor: Colors.red,
    backgroundImage: 'graphics/lightBackground.jpg',
  );

  @override
  WorkoutColors copyWith({
    Color? buttonColor,
    Color? buttonSplashColor,
    Color? appBarColor,
    Color? tabBarColor,
    Color? buttonTextColor,
    Color? cardTextColor,
    Color? textColor,
    Color? specialTextColor,
    Color? primaryColor,
    Color? secondaryColor,
    Color? iconColor,
    Color? tabBarIconColor,
    Color? titleColor,
    Color? backgroundColor,
    Color? indicatorColor,
    Color? borderColor,
    Color? drawerColor,
    Color? chestColor,
    Color? backColor,
    Color? armColor,
    Color? legColor,
    Color? abdominalColor,
    Color? cardioColor,
    Color? arcColor,
    Color? greenButtonColor,
    Color? cancelButtonColor,
    String? backgroundImage,
  }) => WorkoutColors(
    buttonColor: buttonColor ?? this.buttonColor,
    buttonSplashColor: buttonSplashColor ?? this.buttonSplashColor,
    appBarColor: appBarColor ?? this.appBarColor,
    tabBarColor: tabBarColor ?? this.tabBarColor,
    buttonTextColor: buttonTextColor ?? this.buttonTextColor,
    cardTextColor: cardTextColor ?? this.cardTextColor,
    textColor: textColor ?? this.textColor,
    specialTextColor: specialTextColor ?? this.specialTextColor,
    primaryColor: primaryColor ?? this.primaryColor,
    secondaryColor: secondaryColor ?? this.secondaryColor,
    iconColor: iconColor ?? this.iconColor,
    tabBarIconColor: tabBarIconColor ?? this.tabBarIconColor,
    titleColor: titleColor ?? this.titleColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    indicatorColor: indicatorColor ?? this.indicatorColor,
    borderColor: borderColor ?? this.borderColor,
    drawerColor: drawerColor ?? this.drawerColor,
    chestColor: chestColor ?? this.chestColor,
    backColor: backColor ?? this.backColor,
    armColor: armColor ?? this.armColor,
    legColor: legColor ?? this.legColor,
    abdominalColor: abdominalColor ?? this.abdominalColor,
    cardioColor: cardioColor ?? this.cardioColor,
    arcColor: arcColor ?? this.arcColor,
    greenButtonColor: greenButtonColor ?? this.greenButtonColor,
    cancelButtonColor: cancelButtonColor ?? this.cancelButtonColor,
    backgroundImage: backgroundImage ?? this.backgroundImage,
  );

  @override
  WorkoutColors lerp(ThemeExtension<WorkoutColors>? other, double t) {
    if (other is! WorkoutColors) {
      return this;
    }

    return WorkoutColors(
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t)!,
      buttonSplashColor: Color.lerp(
        buttonSplashColor,
        other.buttonSplashColor,
        t,
      )!,
      appBarColor: Color.lerp(appBarColor, other.appBarColor, t)!,
      tabBarColor: Color.lerp(tabBarColor, other.tabBarColor, t)!,
      buttonTextColor: Color.lerp(buttonTextColor, other.buttonTextColor, t)!,
      cardTextColor: Color.lerp(cardTextColor, other.cardTextColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      specialTextColor: Color.lerp(
        specialTextColor,
        other.specialTextColor,
        t,
      )!,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      tabBarIconColor: Color.lerp(tabBarIconColor, other.tabBarIconColor, t)!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      indicatorColor: Color.lerp(indicatorColor, other.indicatorColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      drawerColor: Color.lerp(drawerColor, other.drawerColor, t)!,
      chestColor: Color.lerp(chestColor, other.chestColor, t)!,
      backColor: Color.lerp(backColor, other.backColor, t)!,
      armColor: Color.lerp(armColor, other.armColor, t)!,
      legColor: Color.lerp(legColor, other.legColor, t)!,
      abdominalColor: Color.lerp(abdominalColor, other.abdominalColor, t)!,
      cardioColor: Color.lerp(cardioColor, other.cardioColor, t)!,
      arcColor: Color.lerp(arcColor, other.arcColor, t)!,
      greenButtonColor: Color.lerp(
        greenButtonColor,
        other.greenButtonColor,
        t,
      )!,
      cancelButtonColor: Color.lerp(
        cancelButtonColor,
        other.cancelButtonColor,
        t,
      )!,
      backgroundImage: t < 0.5 ? backgroundImage : other.backgroundImage,
    );
  }
}

class WorkoutTypography {
  static const double fontSize = 20;
  static const double headerSize = 30;
}
