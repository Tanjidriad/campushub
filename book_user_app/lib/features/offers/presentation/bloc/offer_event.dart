import 'package:equatable/equatable.dart';

abstract class OfferEvent extends Equatable {
  const OfferEvent();

  @override
  List<Object?> get props => [];
}

class CreateOfferRequested extends OfferEvent {
  final String listingId;
  final double amount;
  final String? message;

  const CreateOfferRequested({
    required this.listingId,
    required this.amount,
    this.message,
  });

  @override
  List<Object?> get props => [listingId, amount, message];
}

class OfferDetailRequested extends OfferEvent {
  final String offerId;

  const OfferDetailRequested({required this.offerId});

  @override
  List<Object?> get props => [offerId];
}

class OffersListRequested extends OfferEvent {
  final String? type; // 'sent' | 'received'
  final String? status;

  const OffersListRequested({this.type, this.status});

  @override
  List<Object?> get props => [type, status];
}

class OfferAccepted extends OfferEvent {
  final String offerId;

  const OfferAccepted({required this.offerId});

  @override
  List<Object?> get props => [offerId];
}

class OfferDeclined extends OfferEvent {
  final String offerId;

  const OfferDeclined({required this.offerId});

  @override
  List<Object?> get props => [offerId];
}

class OfferCountered extends OfferEvent {
  final String offerId;
  final double counterAmount;

  const OfferCountered({required this.offerId, required this.counterAmount});

  @override
  List<Object?> get props => [offerId, counterAmount];
}
