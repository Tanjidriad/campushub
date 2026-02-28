import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/offer_remote_datasource.dart';
import 'offer_event.dart';
import 'offer_state.dart';

class OfferBloc extends Bloc<OfferEvent, OfferState> {
  final OfferRemoteDataSource _dataSource;

  OfferBloc(this._dataSource) : super(const OfferInitial()) {
    on<CreateOfferRequested>(_onCreateOffer);
    on<OfferDetailRequested>(_onGetOfferDetail);
    on<OffersListRequested>(_onGetOffers);
    on<OfferAccepted>(_onAcceptOffer);
    on<OfferDeclined>(_onDeclineOffer);
    on<OfferCountered>(_onCounterOffer);
  }

  Future<void> _onCreateOffer(
    CreateOfferRequested event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final offer = await _dataSource.createOffer(
        listingId: event.listingId,
        amount: event.amount,
        message: event.message,
      );
      emit(OfferCreated(offer: offer));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to create offer';
      emit(OfferError(message: message));
    } catch (e) {
      emit(OfferError(message: e.toString()));
    }
  }

  Future<void> _onGetOfferDetail(
    OfferDetailRequested event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final offer = await _dataSource.getOffer(event.offerId);
      emit(OfferDetailLoaded(offer: offer));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to load offer';
      emit(OfferError(message: message));
    } catch (e) {
      emit(OfferError(message: e.toString()));
    }
  }

  Future<void> _onGetOffers(
    OffersListRequested event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final offers = await _dataSource.getOffers(
        type: event.type,
        status: event.status,
      );
      emit(OffersLoaded(offers: offers));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to load offers';
      emit(OfferError(message: message));
    } catch (e) {
      emit(OfferError(message: e.toString()));
    }
  }

  Future<void> _onAcceptOffer(
    OfferAccepted event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final offer = await _dataSource.respondToOffer(
        offerId: event.offerId,
        action: 'accept',
      );
      emit(OfferResponded(offer: offer, action: 'accept'));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to accept offer';
      emit(OfferError(message: message));
    } catch (e) {
      emit(OfferError(message: e.toString()));
    }
  }

  Future<void> _onDeclineOffer(
    OfferDeclined event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final offer = await _dataSource.respondToOffer(
        offerId: event.offerId,
        action: 'decline',
      );
      emit(OfferResponded(offer: offer, action: 'decline'));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to decline offer';
      emit(OfferError(message: message));
    } catch (e) {
      emit(OfferError(message: e.toString()));
    }
  }

  Future<void> _onCounterOffer(
    OfferCountered event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final offer = await _dataSource.respondToOffer(
        offerId: event.offerId,
        action: 'counter',
        counterAmount: event.counterAmount,
      );
      emit(OfferResponded(offer: offer, action: 'counter'));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to counter offer';
      emit(OfferError(message: message));
    } catch (e) {
      emit(OfferError(message: e.toString()));
    }
  }
}
