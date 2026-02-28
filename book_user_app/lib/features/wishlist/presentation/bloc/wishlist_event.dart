import 'package:equatable/equatable.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWishlist extends WishlistEvent {}

class AddToWishlist extends WishlistEvent {
  final String listingId;

  const AddToWishlist(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

class RemoveFromWishlist extends WishlistEvent {
  final String listingId;

  const RemoveFromWishlist(this.listingId);

  @override
  List<Object?> get props => [listingId];
}
