import 'package:equatable/equatable.dart';

class EducationConfig extends Equatable {
  final List<EducationLevel> levels;
  final List<BookType> bookTypes;

  const EducationConfig({this.levels = const [], this.bookTypes = const []});

  @override
  List<Object?> get props => [levels, bookTypes];
}

class EducationLevel extends Equatable {
  final String? key;
  final String? label;
  final List<SubLevel> subLevels;
  final List<EducationStream> streams;

  const EducationLevel({
    this.key,
    this.label,
    this.subLevels = const [],
    this.streams = const [],
  });

  bool get hasStreams => streams.isNotEmpty;

  @override
  List<Object?> get props => [key, label, subLevels, streams];
}

class EducationStream extends Equatable {
  final String? key;
  final String? label;
  final List<EducationDepartment> departments;

  const EducationStream({
    this.key,
    this.label,
    this.departments = const [],
  });

  @override
  List<Object?> get props => [key, label, departments];
}

class EducationDepartment extends Equatable {
  final String? key;
  final String? label;
  final List<SubLevel> subLevels;

  const EducationDepartment({
    this.key,
    this.label,
    this.subLevels = const [],
  });

  @override
  List<Object?> get props => [key, label, subLevels];
}

class SubLevel extends Equatable {
  final String? key;
  final String? label;

  const SubLevel({this.key, this.label});

  @override
  List<Object?> get props => [key, label];
}

class BookType extends Equatable {
  final String? key;
  final String? label;

  const BookType({this.key, this.label});

  @override
  List<Object?> get props => [key, label];
}
