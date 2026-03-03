import 'package:book_user_app/core/network/api_client.dart';
import 'package:flutter/foundation.dart';

/// Represents a sub-level under an education level (e.g., "Class 6" under "School")
class EducationSubLevel {
  final String key;
  final String label;

  const EducationSubLevel({required this.key, required this.label});

  factory EducationSubLevel.fromJson(Map<String, dynamic> json) {
    return EducationSubLevel(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

/// Represents an education level (e.g., "School", "College", "University")
class EducationLevel {
  final String key;
  final String label;
  final List<EducationSubLevel> subLevels;

  const EducationLevel({
    required this.key,
    required this.label,
    required this.subLevels,
  });

  factory EducationLevel.fromJson(Map<String, dynamic> json) {
    final subLevelsJson = json['subLevels'] as List<dynamic>? ?? [];
    return EducationLevel(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      subLevels: subLevelsJson
          .map((s) => EducationSubLevel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents a book type (e.g., "NCTB", "Guide", "Reference")
class BookType {
  final String key;
  final String label;

  const BookType({required this.key, required this.label});

  factory BookType.fromJson(Map<String, dynamic> json) {
    return BookType(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

/// Holds the complete education configuration
class EducationConfig {
  final List<EducationLevel> levels;
  final List<BookType> bookTypes;

  const EducationConfig({required this.levels, required this.bookTypes});

  factory EducationConfig.fromJson(Map<String, dynamic> json) {
    final levelsJson = json['levels'] as List<dynamic>? ?? [];
    final bookTypesJson = json['bookTypes'] as List<dynamic>? ?? [];
    return EducationConfig(
      levels: levelsJson
          .map((l) => EducationLevel.fromJson(l as Map<String, dynamic>))
          .toList(),
      bookTypes: bookTypesJson
          .map((b) => BookType.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Fallback config if API fails
  static const EducationConfig fallback = EducationConfig(
    levels: [
      EducationLevel(
        key: 'school',
        label: 'School',
        subLevels: [
          EducationSubLevel(key: 'class-6', label: 'Class 6'),
          EducationSubLevel(key: 'class-7', label: 'Class 7'),
          EducationSubLevel(key: 'class-8', label: 'Class 8'),
          EducationSubLevel(key: 'class-9', label: 'Class 9'),
          EducationSubLevel(key: 'class-10', label: 'Class 10'),
        ],
      ),
      EducationLevel(
        key: 'college',
        label: 'College',
        subLevels: [
          EducationSubLevel(key: 'hsc-1', label: 'HSC 1st Year'),
          EducationSubLevel(key: 'hsc-2', label: 'HSC 2nd Year'),
        ],
      ),
      EducationLevel(
        key: 'university',
        label: 'University',
        subLevels: [
          EducationSubLevel(key: 'sem-1', label: 'Semester 1'),
          EducationSubLevel(key: 'sem-2', label: 'Semester 2'),
          EducationSubLevel(key: 'sem-3', label: 'Semester 3'),
          EducationSubLevel(key: 'sem-4', label: 'Semester 4'),
          EducationSubLevel(key: 'sem-5', label: 'Semester 5'),
          EducationSubLevel(key: 'sem-6', label: 'Semester 6'),
          EducationSubLevel(key: 'sem-7', label: 'Semester 7'),
          EducationSubLevel(key: 'sem-8', label: 'Semester 8'),
        ],
      ),
    ],
    bookTypes: [
      BookType(key: 'nctb', label: 'NCTB'),
      BookType(key: 'guide', label: 'Guide'),
      BookType(key: 'reference', label: 'Reference'),
      BookType(key: 'university_textbook', label: 'Uni Book'),
      BookType(key: 'other', label: 'Other'),
    ],
  );
}

/// Singleton service that fetches and caches education config from the API
class EducationConfigService {
  static final EducationConfigService _instance = EducationConfigService._();
  factory EducationConfigService() => _instance;
  EducationConfigService._();

  EducationConfig? _cachedConfig;
  bool _isLoading = false;

  EducationConfig get config => _cachedConfig ?? EducationConfig.fallback;
  bool get isLoaded => _cachedConfig != null;

  /// Fetch config from API. Safe to call multiple times — returns cached value.
  Future<EducationConfig> fetchConfig() async {
    if (_cachedConfig != null) return _cachedConfig!;
    if (_isLoading) {
      // Wait a bit for the other call to finish
      await Future.delayed(const Duration(milliseconds: 500));
      return _cachedConfig ?? EducationConfig.fallback;
    }

    _isLoading = true;
    try {
      final response = await ApiClient().get('/education-config');
      final data = response.data;
      if (data != null && data['success'] == true && data['data'] != null) {
        _cachedConfig = EducationConfig.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        debugPrint(
          '📚 Education config loaded: ${_cachedConfig!.levels.length} levels',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Failed to fetch education config: $e');
    } finally {
      _isLoading = false;
    }

    return _cachedConfig ?? EducationConfig.fallback;
  }

  /// Force refresh from API
  Future<EducationConfig> refresh() async {
    _cachedConfig = null;
    return fetchConfig();
  }
}
