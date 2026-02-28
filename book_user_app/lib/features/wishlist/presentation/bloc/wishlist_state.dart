import 'package:equatable/equatable.dart';
import 'package:book_user_app/features/listings/domain/entities/listing.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<Listing> wishlist;

  const WishlistLoaded(this.wishlist);

  @override
  List<Object?> get props => [wishlist];
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}

class WishlistOperationSuccess extends WishlistState {
  final String message;

  const WishlistOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
