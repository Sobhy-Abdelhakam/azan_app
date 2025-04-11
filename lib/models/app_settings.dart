class AppSettings {
  final bool notificationsEnabled;
  final bool azanSoundEnabled;
  final CalculationMethodOption calculationMethod;
  final LocationType locationType;
  final String manualCity;
  final String manualCountry;

  AppSettings({
    required this.notificationsEnabled,
    required this.azanSoundEnabled,
    required this.calculationMethod,
    required this.locationType,
    required this.manualCity,
    required this.manualCountry,
  });

  factory AppSettings.defaultSettings() => AppSettings(
        notificationsEnabled: true,
        azanSoundEnabled: true,
        calculationMethod: CalculationMethodOption.muslimWorldLeague,
        locationType: LocationType.gps,
        manualCity: '',
        manualCountry: '',
      );

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? azanSoundEnabled,
    CalculationMethodOption? calculationMethod,
    LocationType? locationType,
    String? manualCity,
    String? manualCountry,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      azanSoundEnabled: azanSoundEnabled ?? this.azanSoundEnabled,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      locationType: locationType ?? this.locationType,
      manualCity: manualCity ?? this.manualCity,
      manualCountry: manualCountry ?? this.manualCountry,
    );
  }
}

enum CalculationMethodOption {
  muslimWorldLeague,
  egyptian,
  karachi,
  other,
}

enum LocationType {
  gps,
  manual,
}
