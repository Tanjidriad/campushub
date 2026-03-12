import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing.dart';
import '../repositories/listing_repository.dart';
import 'package:equatable/equatable.dart';

class GetAllListings implements UseCase<List<Listing>, GetAllParams> {
  final ListingRepository repository;

  GetAllListings(this.repository);

  @override
  Future<Either<Failure, List<Listing>>> call(GetAllParams params) async {
    return await repository.getAllListings(
      limit: params.limit,
      search: params.search,
      category: params.category,
      isFeatured: params.isFeatured,
    );
  }
}

class GetAllParams extends Equatable {
  final int limit;
  final String? search;
  final String? category;
  final bool? isFeatured;

  const GetAllParams({
    this.limit = 50,
    this.search,
    this.category,
    this.isFeatured,
  });

  @override
  List<Object?> get props => [limit, search, category, isFeatured];
}
