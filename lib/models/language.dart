class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, '🇺🇸', 'English', 'en'),
      Language(2, '🇫🇷', 'Français', 'fr'),
      Language(3, '🇵🇹', 'Português', 'pt'),
      Language(4, '🇪🇸', 'Española', 'es'),
      Language(5, '🇨🇳', '中文', 'zh'),
      Language(6, '🇸🇦', 'العربية', 'ar'),
      Language(7, '🇵🇰', 'اردو', 'ur'),
      Language(8, '🇮🇳', 'हिंदी', 'hi'),
    ];
  }
}
