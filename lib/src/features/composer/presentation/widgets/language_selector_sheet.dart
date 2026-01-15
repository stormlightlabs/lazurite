import 'package:flutter/material.dart';

/// A bottom sheet for selecting languages for a post.
///
/// Supports multi-selection with a maximum of 3 languages.
/// Shows common languages as quick-select options and a search field.
class LanguageSelectorSheet extends StatefulWidget {
  const LanguageSelectorSheet({
    super.key,
    required this.selectedLanguages,
    required this.onSelectionChanged,
  });

  /// Currently selected language codes.
  final List<String> selectedLanguages;

  /// Callback when selection changes.
  final ValueChanged<List<String>> onSelectionChanged;

  @override
  State<LanguageSelectorSheet> createState() => _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends State<LanguageSelectorSheet> {
  static const int _maxLanguages = 3;
  late final TextEditingController _searchController;
  final List<Language> _filteredLanguages = List.from(_commonLanguages);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _filteredLanguages.clear();
        _filteredLanguages.addAll(_commonLanguages);
      } else {
        _filteredLanguages.clear();
        _filteredLanguages.addAll(
          _allLanguages.where(
            (lang) =>
                lang.name.toLowerCase().contains(query) || lang.code.toLowerCase().contains(query),
          ),
        );
      }
    });
  }

  void _toggleLanguage(String code) {
    final newSelection = List<String>.from(widget.selectedLanguages);
    if (newSelection.contains(code)) {
      newSelection.remove(code);
    } else if (newSelection.length < _maxLanguages) {
      newSelection.add(code);
    }
    widget.onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          widget.onSelectionChanged(widget.selectedLanguages);
        }
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Languages',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onSelectionChanged([]);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.selectedLanguages.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.selectedLanguages.map((code) {
                    return Chip(
                      label: Text(code.toUpperCase()),
                      onDeleted: () => _toggleLanguage(code),
                      deleteIconColor: theme.colorScheme.onSurfaceVariant,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search languages...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = _filteredLanguages[index];
                    final isSelected = widget.selectedLanguages.contains(lang.code);
                    final isMaxReached = widget.selectedLanguages.length >= _maxLanguages;

                    return CheckboxListTile(
                      title: Text(lang.name),
                      subtitle: Text(lang.code.toUpperCase()),
                      value: isSelected,
                      enabled: isSelected || !isMaxReached,
                      onChanged: (value) => _toggleLanguage(lang.code),
                    );
                  },
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Language {
  const Language({required this.code, required this.name});

  final String code;
  final String name;
}

/// Common languages shown by default.
const List<Language> _commonLanguages = [
  Language(code: 'en', name: 'English'),
  Language(code: 'es', name: 'Spanish'),
  Language(code: 'fr', name: 'French'),
  Language(code: 'de', name: 'German'),
  Language(code: 'it', name: 'Italian'),
  Language(code: 'pt', name: 'Portuguese'),
  Language(code: 'ja', name: 'Japanese'),
  Language(code: 'ko', name: 'Korean'),
  Language(code: 'zh', name: 'Chinese'),
  Language(code: 'ar', name: 'Arabic'),
  Language(code: 'hi', name: 'Hindi'),
  Language(code: 'ru', name: 'Russian'),
];

/// All supported languages for search.
const List<Language> _allLanguages = [
  Language(code: 'aa', name: 'Afar'),
  Language(code: 'ab', name: 'Abkhazian'),
  Language(code: 'af', name: 'Afrikaans'),
  Language(code: 'ak', name: 'Akan'),
  Language(code: 'sq', name: 'Albanian'),
  Language(code: 'am', name: 'Amharic'),
  Language(code: 'ar', name: 'Arabic'),
  Language(code: 'an', name: 'Aragonese'),
  Language(code: 'hy', name: 'Armenian'),
  Language(code: 'as', name: 'Assamese'),
  Language(code: 'av', name: 'Avaric'),
  Language(code: 'ae', name: 'Avestan'),
  Language(code: 'ay', name: 'Aymara'),
  Language(code: 'az', name: 'Azerbaijani'),
  Language(code: 'ba', name: 'Bashkir'),
  Language(code: 'bm', name: 'Bambara'),
  Language(code: 'eu', name: 'Basque'),
  Language(code: 'be', name: 'Belarusian'),
  Language(code: 'bn', name: 'Bengali'),
  Language(code: 'bh', name: 'Bihari'),
  Language(code: 'bi', name: 'Bislama'),
  Language(code: 'bs', name: 'Bosnian'),
  Language(code: 'br', name: 'Breton'),
  Language(code: 'bg', name: 'Bulgarian'),
  Language(code: 'my', name: 'Burmese'),
  Language(code: 'ca', name: 'Catalan'),
  Language(code: 'ch', name: 'Chamorro'),
  Language(code: 'ce', name: 'Chechen'),
  Language(code: 'ny', name: 'Chichewa'),
  Language(code: 'zh', name: 'Chinese'),
  Language(code: 'cv', name: 'Chuvash'),
  Language(code: 'kw', name: 'Cornish'),
  Language(code: 'co', name: 'Corsican'),
  Language(code: 'cr', name: 'Cree'),
  Language(code: 'cs', name: 'Czech'),
  Language(code: 'da', name: 'Danish'),
  Language(code: 'dv', name: 'Dhivehi'),
  Language(code: 'nl', name: 'Dutch'),
  Language(code: 'dz', name: 'Dzongkha'),
  Language(code: 'en', name: 'English'),
  Language(code: 'eo', name: 'Esperanto'),
  Language(code: 'et', name: 'Estonian'),
  Language(code: 'ee', name: 'Ewe'),
  Language(code: 'fo', name: 'Faroese'),
  Language(code: 'fj', name: 'Fijian'),
  Language(code: 'fi', name: 'Finnish'),
  Language(code: 'fr', name: 'French'),
  Language(code: 'fy', name: 'Frisian'),
  Language(code: 'ff', name: 'Fulah'),
  Language(code: 'ka', name: 'Georgian'),
  Language(code: 'de', name: 'German'),
  Language(code: 'gd', name: 'Gaelic'),
  Language(code: 'ga', name: 'Irish'),
  Language(code: 'gl', name: 'Galician'),
  Language(code: 'gv', name: 'Manx'),
  Language(code: 'el', name: 'Greek'),
  Language(code: 'gn', name: 'Guarani'),
  Language(code: 'gu', name: 'Gujarati'),
  Language(code: 'ht', name: 'Haitian'),
  Language(code: 'ha', name: 'Hausa'),
  Language(code: 'he', name: 'Hebrew'),
  Language(code: 'hz', name: 'Herero'),
  Language(code: 'hi', name: 'Hindi'),
  Language(code: 'ho', name: 'Hiri Motu'),
  Language(code: 'hr', name: 'Croatian'),
  Language(code: 'hu', name: 'Hungarian'),
  Language(code: 'ig', name: 'Igbo'),
  Language(code: 'is', name: 'Icelandic'),
  Language(code: 'io', name: 'Ido'),
  Language(code: 'ii', name: 'Sichuan Yi'),
  Language(code: 'iu', name: 'Inuktitut'),
  Language(code: 'ie', name: 'Interlingue'),
  Language(code: 'ia', name: 'Interlingua'),
  Language(code: 'id', name: 'Indonesian'),
  Language(code: 'ik', name: 'Inupiaq'),
  Language(code: 'it', name: 'Italian'),
  Language(code: 'jv', name: 'Javanese'),
  Language(code: 'ja', name: 'Japanese'),
  Language(code: 'kl', name: 'Kalaallisut'),
  Language(code: 'kn', name: 'Kannada'),
  Language(code: 'ks', name: 'Kashmiri'),
  Language(code: 'kr', name: 'Kanuri'),
  Language(code: 'kk', name: 'Kazakh'),
  Language(code: 'km', name: 'Khmer'),
  Language(code: 'ki', name: 'Kikuyu'),
  Language(code: 'rw', name: 'Kinyarwanda'),
  Language(code: 'ky', name: 'Kyrgyz'),
  Language(code: 'kv', name: 'Komi'),
  Language(code: 'kg', name: 'Kongo'),
  Language(code: 'ko', name: 'Korean'),
  Language(code: 'kj', name: 'Kuanyama'),
  Language(code: 'ku', name: 'Kurdish'),
  Language(code: 'lo', name: 'Lao'),
  Language(code: 'la', name: 'Latin'),
  Language(code: 'lv', name: 'Latvian'),
  Language(code: 'li', name: 'Limburgish'),
  Language(code: 'ln', name: 'Lingala'),
  Language(code: 'lt', name: 'Lithuanian'),
  Language(code: 'lb', name: 'Luxembourgish'),
  Language(code: 'lu', name: 'Luba-Katanga'),
  Language(code: 'lg', name: 'Luganda'),
  Language(code: 'mk', name: 'Macedonian'),
  Language(code: 'mh', name: 'Marshallese'),
  Language(code: 'ml', name: 'Malayalam'),
  Language(code: 'mi', name: 'Maori'),
  Language(code: 'mr', name: 'Marathi'),
  Language(code: 'ms', name: 'Malay'),
  Language(code: 'mg', name: 'Malagasy'),
  Language(code: 'mt', name: 'Maltese'),
  Language(code: 'mn', name: 'Mongolian'),
  Language(code: 'na', name: 'Nauru'),
  Language(code: 'nv', name: 'Navajo'),
  Language(code: 'nr', name: 'Ndebele'),
  Language(code: 'nd', name: 'Ndebele'),
  Language(code: 'ng', name: 'Ndonga'),
  Language(code: 'ne', name: 'Nepali'),
  Language(code: 'nn', name: 'Norwegian'),
  Language(code: 'nb', name: 'Norwegian'),
  Language(code: 'no', name: 'Norwegian'),
  Language(code: 'ny', name: 'Chichewa'),
  Language(code: 'oc', name: 'Occitan'),
  Language(code: 'oj', name: 'Ojibwa'),
  Language(code: 'or', name: 'Oriya'),
  Language(code: 'om', name: 'Oromo'),
  Language(code: 'os', name: 'Ossetian'),
  Language(code: 'pa', name: 'Panjabi'),
  Language(code: 'fa', name: 'Persian'),
  Language(code: 'pi', name: 'Pali'),
  Language(code: 'pl', name: 'Polish'),
  Language(code: 'pt', name: 'Portuguese'),
  Language(code: 'ps', name: 'Pushto'),
  Language(code: 'qu', name: 'Quechua'),
  Language(code: 'ro', name: 'Romanian'),
  Language(code: 'rm', name: 'Romansh'),
  Language(code: 'rn', name: 'Rundi'),
  Language(code: 'ru', name: 'Russian'),
  Language(code: 'sg', name: 'Sango'),
  Language(code: 'sa', name: 'Sanskrit'),
  Language(code: 'si', name: 'Sinhala'),
  Language(code: 'sk', name: 'Slovak'),
  Language(code: 'sl', name: 'Slovenian'),
  Language(code: 'se', name: 'Northern Sami'),
  Language(code: 'sm', name: 'Samoan'),
  Language(code: 'sn', name: 'Shona'),
  Language(code: 'sd', name: 'Sindhi'),
  Language(code: 'so', name: 'Somali'),
  Language(code: 'st', name: 'Sotho'),
  Language(code: 'es', name: 'Spanish'),
  Language(code: 'sc', name: 'Sardinian'),
  Language(code: 'sr', name: 'Serbian'),
  Language(code: 'ss', name: 'Swati'),
  Language(code: 'su', name: 'Sundanese'),
  Language(code: 'sw', name: 'Swahili'),
  Language(code: 'sv', name: 'Swedish'),
  Language(code: 'ty', name: 'Tahitian'),
  Language(code: 'ta', name: 'Tamil'),
  Language(code: 'tt', name: 'Tatar'),
  Language(code: 'te', name: 'Telugu'),
  Language(code: 'tg', name: 'Tajik'),
  Language(code: 'tl', name: 'Tagalog'),
  Language(code: 'th', name: 'Thai'),
  Language(code: 'bo', name: 'Tibetan'),
  Language(code: 'ti', name: 'Tigrinya'),
  Language(code: 'to', name: 'Tonga'),
  Language(code: 'tn', name: 'Tswana'),
  Language(code: 'ts', name: 'Tsonga'),
  Language(code: 'tk', name: 'Turkmen'),
  Language(code: 'tr', name: 'Turkish'),
  Language(code: 'tw', name: 'Twi'),
  Language(code: 'ug', name: 'Uighur'),
  Language(code: 'uk', name: 'Ukrainian'),
  Language(code: 'ur', name: 'Urdu'),
  Language(code: 'uz', name: 'Uzbek'),
  Language(code: 've', name: 'Venda'),
  Language(code: 'vi', name: 'Vietnamese'),
  Language(code: 'vo', name: 'Volapuk'),
  Language(code: 'cy', name: 'Welsh'),
  Language(code: 'wa', name: 'Walloon'),
  Language(code: 'wo', name: 'Wolof'),
  Language(code: 'xh', name: 'Xhosa'),
  Language(code: 'yi', name: 'Yiddish'),
  Language(code: 'yo', name: 'Yoruba'),
  Language(code: 'za', name: 'Zhuang'),
  Language(code: 'zu', name: 'Zulu'),
];
