import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/education_config.dart';
import '../repositories/category_repository.dart';

class GetConfig implements UseCase<EducationConfig, NoParams> {
  final CategoryRepository repository;
  GetConfig(this.repository);

  @override
  Future<Either<Failure, EducationConfig>> call(NoParams params) async {
    return await repository.getConfig();
  }
}

class SaveConfig implements UseCase<void, EducationConfig> {
  final CategoryRepository repository;
  SaveConfig(this.repository);

  @override
  Future<Either<Failure, void>> call(EducationConfig config) async {
    return await repository.saveConfig(config);
  }
}
