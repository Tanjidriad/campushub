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

  const EducationLevel({this.key, this.label, this.subLevels = const []});

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
