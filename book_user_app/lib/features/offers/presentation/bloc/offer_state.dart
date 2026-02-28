import 'package:equatable/equatable.dart';
import '../../domain/entities/offer.dart';

abstract class OfferState extends Equatable {
  const OfferState();

  @override
  List<Object?> get props => [];
}

class OfferInitial extends OfferState {
  const OfferInitial();
}

class OfferLoading extends OfferState {
  const OfferLoading();
}

class OfferCreated extends OfferState {
  final Offer offer;

  const OfferCreated({required this.offer});

  @override
  List<Object?> get props => [offer];
}

class OfferDetailLoaded extends OfferState {
  final Offer offer;

  const OfferDetailLoaded({required this.offer});

  @override
  List<Object?> get props => [offer];
}

class OffersLoaded extends OfferState {
  final List<Offer> offers;

  const OffersLoaded({required this.offers});

  @override
  List<Object?> get props => [offers];
}

class OfferResponded extends OfferState {
  final Offer offer;
  final String action;

  const OfferResponded({required this.offer, required this.action});

  @override
  List<Object?> get props => [offer, action];
}

class OfferError extends OfferState {
  final String message;

  const OfferError({required this.message});

  @override
  List<Object?> get props => [message];
}
