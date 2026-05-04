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

/// Represents a department (e.g., "CSE" under "Science & Engineering")
class EducationDepartment {
  final String key;
  final String label;
  final List<EducationSubLevel> subLevels;

  const EducationDepartment({
    required this.key,
    required this.label,
    required this.subLevels,
  });

  factory EducationDepartment.fromJson(Map<String, dynamic> json) {
    final subLevelsJson = json['subLevels'] as List<dynamic>? ?? [];
    return EducationDepartment(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      subLevels: subLevelsJson
          .map((s) => EducationSubLevel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents a stream (e.g., "Science & Engineering" under "University")
class EducationStream {
  final String key;
  final String label;
  final List<EducationDepartment> departments;

  const EducationStream({
    required this.key,
    required this.label,
    required this.departments,
  });

  factory EducationStream.fromJson(Map<String, dynamic> json) {
    final deptsJson = json['departments'] as List<dynamic>? ?? [];
    return EducationStream(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      departments: deptsJson
          .map((d) => EducationDepartment.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents an education level (e.g., "School", "College", "University")
class EducationLevel {
  final String key;
  final String label;
  final List<EducationSubLevel> subLevels;
  final List<EducationStream> streams;

  const EducationLevel({
    required this.key,
    required this.label,
    required this.subLevels,
    required this.streams,
  });

  /// Whether this level has nested streams (e.g., University)
  bool get hasStreams => streams.isNotEmpty;

  factory EducationLevel.fromJson(Map<String, dynamic> json) {
    final subLevelsJson = json['subLevels'] as List<dynamic>? ?? [];
    final streamsJson = json['streams'] as List<dynamic>? ?? [];
    return EducationLevel(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      subLevels: subLevelsJson
          .map((s) => EducationSubLevel.fromJson(s as Map<String, dynamic>))
          .toList(),
      streams: streamsJson
          .map((s) => EducationStream.fromJson(s as Map<String, dynamic>))
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
        streams: [],
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
        streams: [
          EducationStream(key: 'science', label: 'Science', departments: []),
          EducationStream(key: 'arts', label: 'Arts', departments: []),
          EducationStream(key: 'commerce', label: 'Commerce', departments: []),
        ],
      ),
      EducationLevel(
        key: 'university',
        label: 'University',
        subLevels: [],
        streams: [
          EducationStream(key: 'science-engineering', label: 'Science & Engineering', departments: [
            EducationDepartment(key: 'cse', label: 'CSE', subLevels: []),
            EducationDepartment(key: 'eee', label: 'EEE', subLevels: []),
          ]),
          EducationStream(key: 'arts-humanities', label: 'Arts & Humanities', departments: [
            EducationDepartment(key: 'english', label: 'English', subLevels: []),
          ]),
          EducationStream(key: 'business', label: 'Business & Commerce', departments: [
            EducationDepartment(key: 'bba', label: 'BBA', subLevels: []),
          ]),
        ],
      ),
    ],
    bookTypes: [
      BookType(key: 'nctb', label: 'NCTB'),
      BookType(key: 'guide', label: 'Guide'),
      BookType(key: 'reference', label: 'Reference'),
      BookType(key: 'university_textbook', label: 'Uni Book'),
      BookType(key: 'notes', label: 'Notes'),
      BookType(key: 'question_bank', label: 'Question Bank'),
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
