import '../../domain/entities/education_config.dart';

class EducationConfigModel extends EducationConfig {
  const EducationConfigModel({super.levels, super.bookTypes});

  factory EducationConfigModel.fromJson(Map<String, dynamic> json) {
    final levelsJson = json['levels'] as List? ?? [];
    final bookTypesJson = json['bookTypes'] as List? ?? [];

    return EducationConfigModel(
      levels: levelsJson.map((l) => EducationLevelModel.fromJson(l)).toList(),
      bookTypes: bookTypesJson.map((b) => BookTypeModel.fromJson(b)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levels': levels.map((l) {
        final map = <String, dynamic>{
          'key': l.key,
          'label': l.label,
          'subLevels': l.subLevels
              .map((s) => {'key': s.key, 'label': s.label})
              .toList(),
        };
        if (l.streams.isNotEmpty) {
          map['streams'] = l.streams.map((s) {
            return {
              'key': s.key,
              'label': s.label,
              'departments': s.departments.map((d) {
                return {
                  'key': d.key,
                  'label': d.label,
                  'subLevels': d.subLevels
                      .map((sl) => {'key': sl.key, 'label': sl.label})
                      .toList(),
                };
              }).toList(),
            };
          }).toList();
        }
        return map;
      }).toList(),
      'bookTypes': bookTypes
          .map((b) => {'key': b.key, 'label': b.label})
          .toList(),
    };
  }
}

class EducationLevelModel extends EducationLevel {
  const EducationLevelModel({
    super.key,
    super.label,
    super.subLevels,
    super.streams,
  });

  factory EducationLevelModel.fromJson(Map<String, dynamic> json) {
    final subLevelsJson = json['subLevels'] as List? ?? [];
    final streamsJson = json['streams'] as List? ?? [];
    return EducationLevelModel(
      key: json['key'],
      label: json['label'],
      subLevels: subLevelsJson.map((s) => SubLevelModel.fromJson(s)).toList(),
      streams: streamsJson
          .map((s) => EducationStreamModel.fromJson(s))
          .toList(),
    );
  }
}

class EducationStreamModel extends EducationStream {
  const EducationStreamModel({
    super.key,
    super.label,
    super.departments,
  });

  factory EducationStreamModel.fromJson(Map<String, dynamic> json) {
    final deptsJson = json['departments'] as List? ?? [];
    return EducationStreamModel(
      key: json['key'],
      label: json['label'],
      departments: deptsJson
          .map((d) => EducationDepartmentModel.fromJson(d))
          .toList(),
    );
  }
}

class EducationDepartmentModel extends EducationDepartment {
  const EducationDepartmentModel({
    super.key,
    super.label,
    super.subLevels,
  });

  factory EducationDepartmentModel.fromJson(Map<String, dynamic> json) {
    final subLevelsJson = json['subLevels'] as List? ?? [];
    return EducationDepartmentModel(
      key: json['key'],
      label: json['label'],
      subLevels: subLevelsJson.map((s) => SubLevelModel.fromJson(s)).toList(),
    );
  }
}

class SubLevelModel extends SubLevel {
  const SubLevelModel({super.key, super.label});

  factory SubLevelModel.fromJson(Map<String, dynamic> json) {
    return SubLevelModel(key: json['key'], label: json['label']);
  }
}

class BookTypeModel extends BookType {
  const BookTypeModel({super.key, super.label});

  factory BookTypeModel.fromJson(Map<String, dynamic> json) {
    return BookTypeModel(key: json['key'], label: json['label']);
  }
}
