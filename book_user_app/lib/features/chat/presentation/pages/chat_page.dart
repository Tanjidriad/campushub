import 'dart:async';
import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/app_cached_image.dart';
import 'package:book_user_app/core/widgets/app_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_user_app/config/maps_config.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:book_user_app/core/widgets/shimmer_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:book_user_app/core/services/fcm_service.dart';
import 'package:book_user_app/core/services/listing_status_notifier.dart';
import 'package:book_user_app/injection_container/injection_container.dart';

import 'package:book_user_app/features/chat/data/models/chat_message.dart';
import 'package:book_user_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:book_user_app/features/chat/presentation/bloc/conversations_bloc.dart';
import 'package:book_user_app/features/chat/data/models/conversation.dart';
import 'package:book_user_app/features/chat/presentation/widgets/listing_info_bar.dart';
import 'package:book_user_app/features/report/domain/entities/report.dart';
import 'package:book_user_app/features/report/presentation/widgets/report_dialog.dart';
import 'package:book_user_app/features/offers/presentation/widgets/make_offer_sheet.dart';
import 'package:book_user_app/features/listings/data/datasources/listing_remote_datasource.dart';
import 'package:book_user_app/features/chat/presentation/widgets/offer_bubble.dart';
import 'package:book_user_app/l10n/app_localizations.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? otherUserId;

  // Listing info for ListingInfoBar
  final String? listingId;
  final String? listingTitle;
  final String? listingImage;
  final double? listingPrice;
  final String? sellerId; // The listing owner
  final String? currentUserId; // Passed from navigation for instant button

  const ChatPage({
    super.key,
    required this.conversationId,
    this.otherUserName,
    this.otherUserAvatar,
    this.otherUserId,
    this.listingId,
    this.listingTitle,
    this.listingImage,
    this.listingPrice,
    this.sellerId,
    this.currentUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  late final ChatBloc _chatBloc;

  StreamSubscription<String>? _listingStatusSub;

  String? _listingId;
  String? _listingTitle;
  String? _listingImage;
  double? _listingPrice;
  String? _sellerId;
  bool _isSold = false;

  String? _pendingSoldListingId;
  bool _isRefreshingListingMeta = false;

  String? _derivedOtherUserAvatar;
  String? _derivedOtherUserName;

  @override
  void initState() {
    super.initState();
    _chatBloc = sl<ChatBloc>();
    _chatBloc.add(LoadMessages(conversationId: widget.conversationId));

    // Track active conversation for notification suppression
    sl<FCMService>().activeConversationId = widget.conversationId;

    _scrollController.addListener(_onScroll);

    // Seed header listing info from navigation query params (fast path).
    _listingId = widget.listingId?.isNotEmpty == true ? widget.listingId : null;
    _listingTitle =
        widget.listingTitle?.isNotEmpty == true ? widget.listingTitle : null;
    _listingImage =
        widget.listingImage?.isNotEmpty == true ? widget.listingImage : null;
    _listingPrice = widget.listingPrice;
    _sellerId = widget.sellerId?.isNotEmpty == true ? widget.sellerId : null;

    _derivedOtherUserName = widget.otherUserName;
    _derivedOtherUserAvatar = widget.otherUserAvatar;

    // Try to extract missing details immediately if they exist in ConversationsBloc
    _tryExtractMissingDataFromConversations(sl<ConversationsBloc>().state.conversations);

    // If still missing data (e.g., opened via push notification), force load conversations
    if (_listingId == null || _listingId!.isEmpty || _derivedOtherUserAvatar == null || _derivedOtherUserAvatar!.isEmpty) {
      sl<ConversationsBloc>().add(const LoadConversations(page: 1, refresh: true));
    }

    // Listen for sold-state changes (triggered by offer acceptance).
    _listingStatusSub = ListingStatusNotifier.instance.onStatusChanged.listen(
      (listingId) async {
        if (!mounted) return;
        if (_listingId == null || _listingId!.isEmpty) {
          _pendingSoldListingId = listingId;
          return;
        }
        if (_listingId == listingId) {
          debugPrint('🟢 ChatPage: listing $listingId became sold → refreshing header');
          // If we're already refreshing, don't start a competing fetch.
          // Mark it as pending and flip the sold state when this refresh finishes.
          if (_isRefreshingListingMeta) {
            _pendingSoldListingId = listingId;
            return;
          }
          await _refreshListingMeta();
        }
      },
    );

    // If we already have a listingId, fetch authoritative status/sellerId.
    if (_listingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _refreshListingMeta();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _chatBloc.add(const LoadMoreMessages());
    }
  }

  @override
  void dispose() {
    sl<FCMService>().activeConversationId = null;

    _listingStatusSub?.cancel();

    // ChatBloc.close() calls leaveConversation directly — no need to
    // add(LeaveConversation()) here (it races with close() and is dropped).
    _chatBloc.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _tryExtractMissingDataFromConversations(List<Conversation> convs) {
    if (!mounted) return;
    final conv = convs.where((c) => c.id == widget.conversationId).firstOrNull;
    if (conv == null) return;

    bool needsUpdate = false;
    final currentUserId = widget.currentUserId ?? _chatBloc.currentUserId ?? sl<ConversationsBloc>().currentUserId ?? '';
    final otherUser = conv.getOtherParticipant(currentUserId);

    if (_derivedOtherUserName == null || _derivedOtherUserName!.isEmpty) {
      _derivedOtherUserName = otherUser.name;
      needsUpdate = true;
    }
    if (_derivedOtherUserAvatar == null || _derivedOtherUserAvatar!.isEmpty) {
      _derivedOtherUserAvatar = otherUser.avatar;
      needsUpdate = true;
    }

    if (_listingId == null || _listingId!.isEmpty) {
      if (conv.listing.id.isNotEmpty) {
        _listingId = conv.listing.id;
        _listingTitle = conv.listing.title;
        _listingImage = conv.listing.firstImage;
        _listingPrice = conv.listing.price;
        _sellerId = conv.listing.sellerId;
        needsUpdate = true;
        
        // Fetch authoritative status
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _refreshListingMeta();
        });
      }
    }

    if (needsUpdate && mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshListingMeta() async {
    final listingId = _listingId;
    if (listingId == null || listingId.isEmpty) return;
    if (_isRefreshingListingMeta) return;

    _isRefreshingListingMeta = true;
    try {
      final listing = await sl<ListingRemoteDataSource>().getListingById(listingId);
      if (!mounted) return;

      debugPrint('🟦 ChatPage: fetched listing meta (id=$listingId, status=${listing.status})');

      setState(() {
        _sellerId = listing.sellerId;
        _isSold = listing.status == 'sold';
        _listingTitle ??= listing.title;
        _listingImage ??= listing.primaryImageUrl;
        _listingPrice ??= listing.price;
      });
    } catch (e) {
      debugPrint('❌ ChatPage: failed to refresh listing meta (id=$listingId): $e');
    } finally {
      _isRefreshingListingMeta = false;
      if (_pendingSoldListingId != null &&
          _pendingSoldListingId == listingId &&
          mounted) {
        _pendingSoldListingId = null;
        setState(() {
          _isSold = true;
        });
      } else {
        // Clear stale pending values when we reach the expected listingId.
        if (_pendingSoldListingId == listingId) {
          _pendingSoldListingId = null;
        }
      }
    }
  }

  bool _tryDeriveHeaderFromMessages(List<ChatMessage> messages) {
    if (_listingId != null && _listingId!.isNotEmpty) return false;

    for (final msg in messages) {
      final offer = msg.offer;
      final listingId = offer?.listingId;
      if (listingId != null && listingId.isNotEmpty) {
        final derivedTitle = offer?.listingTitle;
        final derivedImage = offer?.listingImage;
        final derivedPrice = offer?.listingPrice;

        setState(() {
          _listingId = listingId;
          _listingTitle = derivedTitle?.isNotEmpty == true ? derivedTitle : _listingTitle;
          _listingImage = derivedImage?.isNotEmpty == true ? derivedImage : _listingImage;
          _listingPrice = derivedPrice ?? _listingPrice;
        });

        debugPrint(
          '🟠 ChatPage: derived listing header from offer (id=$listingId, title=$_listingTitle, price=$_listingPrice)',
        );

        return true;
      }
    }

    return false;
  }

  void _showMakeOfferDialog(BuildContext context) {
    if (_listingId != null && _listingId!.isNotEmpty) {
      MakeOfferSheet.show(
        context,
        listingId: _listingId!,
        listingTitle: _listingTitle ?? 'Listing',
        listingPrice: _listingPrice ?? 0,
        listingImage: _listingImage,
        onOfferSent: (offerId, amount) {
          _chatBloc.add(
            SendOfferMessage(
              offerId: offerId,
              listingId: _listingId!,
              amount: amount,
              listingTitle: _listingTitle ?? 'Listing',
              listingImage: _listingImage,
              listingPrice: _listingPrice ?? 0,
            ),
          );
        },
      );
    }
  }

  void _showMarkAsSoldDialog(BuildContext context) {
    if (_listingId == null || _listingId!.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.sell_rounded,
              color: AppColors.of(context).success,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            const Text('Mark as Sold'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to mark this listing as sold?',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.of(context).textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.of(context).subtleFill,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.of(context).border),
              ),
              child: Row(
                children: [
                  if (_listingImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: AppCachedImage(
                        imageUrl: _listingImage,
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 48.w,
                          height: 48.w,
                          color: AppColors.of(context).border,
                          child: Icon(
                            Icons.image,
                            color: AppColors.of(context).iconMuted,
                          ),
                        ),
                      ),
                    ),
                  if (_listingImage != null) SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _listingTitle ?? 'Listing',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_listingPrice != null)
                          Text(
                            '\$${_listingPrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.of(context).accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This will cancel all pending offers and notify buyers.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.of(context).textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppColors.of(context).textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await sl<ListingRemoteDataSource>().markAsSold(
                  _listingId!,
                );
                if (!context.mounted) return;

                // Optimistic sold-state update for this header.
                setState(() {
                  _isSold = true;
                });
                ListingStatusNotifier.instance.notifyListingSold(_listingId!);

                // Send system message in chat
                _chatBloc.add(
                  SendTextMessage(
                    '🎉 "${_listingTitle ?? 'This item'}" has been marked as sold!',
                  ),
                );

                AppSnackBar.showSuccess(context, 'Listing marked as sold!');
              } catch (e) {
                if (!context.mounted) return;
                AppSnackBar.showError(context, 'Failed: ${e.toString()}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.of(context).success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Mark as Sold',
              style: TextStyle(color: AppColors.of(context).onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: BlocListener<ConversationsBloc, ConversationsState>(
        bloc: sl<ConversationsBloc>(),
        listener: (context, convState) {
          if (convState.status == ConversationsStatus.loaded) {
            _tryExtractMissingDataFromConversations(convState.conversations);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.of(context).background,
          appBar: _buildAppBar(),
        body: Column(
          children: [
            // ListingInfoBar - uses passed currentUserId for instant display
            ListingInfoBar(
              listingId: _listingId ?? '',
              title: _listingTitle ?? 'Listing',
              imageUrl: _listingImage,
              price: _listingPrice,
              sellerId: _sellerId,
              isSold: _isSold,
              currentUserId: widget.currentUserId ?? _chatBloc.currentUserId,
              onViewListing: () {
                if (_listingId != null && _listingId!.isNotEmpty) {
                  context.push('/listing/${_listingId}');
                }
              },
              onMarkAsSold: () {
                _showMarkAsSoldDialog(context);
              },
              onMakeOffer: () {
                _showMakeOfferDialog(context);
              },
            ),
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listenWhen: (prev, curr) =>
                    curr.messages.length > prev.messages.length ||
                    (curr.error != null && curr.error != prev.error && curr.status == ChatStatus.error),
                listener: (context, state) async {
                  if (state.error != null && state.status == ChatStatus.error) {
                    AppSnackBar.showError(context, state.error!);
                  } else if (state.messages.isNotEmpty) {
                    _scrollToBottom();

                    // If navigation didn't include listing metadata, derive it from
                    // the first offer message we find, then fetch authoritative status.
                    if (_tryDeriveHeaderFromMessages(state.messages)) {
                      await _refreshListingMeta();
                    }
                  }
                },
                builder: (context, state) {
                  if (state.status == ChatStatus.loading &&
                      state.messages.isEmpty) {
                    return const ChatMessageShimmer();
                  }

                  if (state.status == ChatStatus.error &&
                      state.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.sp,
                            color: AppColors.of(context).iconMuted,
                          ),
                          SizedBox(height: 16.h),
                          Text(state.error ?? 'Failed to load messages'),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => _chatBloc.add(
                              LoadMessages(
                                conversationId: widget.conversationId,
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildMessageList(state);
                },
              ),
            ),
            _buildTypingIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMessageList(ChatState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64.sp,
              color: AppColors.of(context).border,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.noMessagesYet,
              style: TextStyle(
                color: AppColors.of(context).textSecondary,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.startTheConversation,
              style: TextStyle(
                color: AppColors.of(context).textLight,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      reverse: true,
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        // Fix: Compare with currentUserId, not otherUserId
        // Message is "mine" if I sent it (sender.id == currentUserId)
        final currentUserId = widget.currentUserId ?? _chatBloc.currentUserId;
        final isMe = message.sender.id == currentUserId;
        final showTime =
            index == 0 || _shouldShowTime(message, state.messages[index - 1]);

        return Padding(
          padding: EdgeInsets.only(bottom: showTime ? 16.h : 4.h),
          child: _buildMessageBubble(message, isMe),
        );
      },
    );
  }

  bool _shouldShowTime(ChatMessage current, ChatMessage previous) {
    return current.createdAt.difference(previous.createdAt).inMinutes > 5;
  }

  /// Scrolls to the bottom of the chat (newest messages).
  /// With reverse: true, position 0 is the bottom.
  /// [force] = true always scrolls (e.g. when user sends a message).
  /// [force] = false only scrolls when already near the bottom, so pagination
  /// of older messages doesn't yank the user away from what they're reading.
  void _scrollToBottom({bool animated = true, bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (!force && _scrollController.position.pixels > 300) return;
      if (animated) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(0);
      }
    });
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    final time = DateFormat('h:mm a').format(message.createdAt);

    switch (message.messageType) {
      case MessageType.location:
        return _buildLocationBubble(message, isMe, time);
      case MessageType.image:
        return _buildImageBubble(message, isMe, time);
      case MessageType.offer:
        if (message.offer != null) {
          return OfferBubble(
            offer: message.offer!,
            isMe: isMe,
            time: time,
            otherUserId: widget.otherUserId ?? _chatBloc.state.otherUserId,
            otherUserName: widget.otherUserName,
            otherUserAvatar: widget.otherUserAvatar,
          );
        }
        return isMe
            ? _buildOutgoingMessage(message.text ?? '', time)
            : _buildIncomingMessage(message.text ?? '', time);
      default:
        return isMe
            ? _buildOutgoingMessage(message.text ?? '', time)
            : _buildIncomingMessage(message.text ?? '', time);
    }
  }

  Widget _buildLocationBubble(ChatMessage message, bool isMe, String time) {
    final l10n = AppLocalizations.of(context)!;
    final lat = message.location?.latitude ?? 0;
    final lon = message.location?.longitude ?? 0;

    // Guard against invalid coordinates
    if (lat == 0 && lon == 0) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 0.7.sw),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.of(context).chatBubbleOutgoing
                : AppColors.of(context).chatBubbleIncoming,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off,
                size: 24.sp,
                color: isMe 
                    ? AppColors.of(context).onPrimary.withOpacity(0.7)
                    : AppColors.of(context).iconMuted,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.locationUnavailable,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isMe 
                      ? AppColors.of(context).onPrimary.withOpacity(0.9)
                      : AppColors.of(context).textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final mapUrl =
        'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=14&size=200x120&markers=color:red%7C$lat,$lon&key=${MapsConfig.googleMapsApiKey}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _openLocationInMaps(lat, lon),
        child: Container(
          constraints: BoxConstraints(maxWidth: 0.7.sw),
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.of(context).chatBubbleOutgoing
                : AppColors.of(context).chatBubbleIncoming,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: CachedNetworkImage(
                  imageUrl: mapUrl,
                  height: 120.h,
                  width: 200.w,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 120.h,
                    width: 200.w,
                    color: AppColors.of(context).border,
                    child: const Center(child: AppLoaderFullPage()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 120.h,
                    width: 200.w,
                    color: AppColors.of(context).border,
                    child: Icon(
                      Icons.map,
                      size: 40.sp,
                      color: AppColors.of(context).iconMuted,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.sp,
                      color: isMe 
                          ? AppColors.of(context).onPrimary 
                          : AppColors.of(context).accent,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      l10n.sharedLocation,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isMe 
                            ? AppColors.of(context).onPrimary 
                            : AppColors.of(context).textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isMe 
                            ? AppColors.of(context).onPrimary.withOpacity(0.7) 
                            : AppColors.of(context).textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageBubble(ChatMessage message, bool isMe, String time) {
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = message.image?.url ?? '';

    // Guard against empty or invalid URLs
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 0.7.sw),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.of(context).chatBubbleOutgoing
                : AppColors.of(context).chatBubbleIncoming,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image,
                size: 24.sp,
                color: isMe 
                    ? AppColors.of(context).onPrimary.withOpacity(0.7)
                    : AppColors.of(context).iconMuted,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.imageUnavailable,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isMe 
                      ? AppColors.of(context).onPrimary.withOpacity(0.9)
                      : AppColors.of(context).textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.7.sw),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.of(context).chatBubbleOutgoing
              : AppColors.of(context).chatBubbleIncoming,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 200.w,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 150.h,
                  width: 200.w,
                  color: AppColors.of(context).border,
                  child: const Center(child: AppLoaderFullPage()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 150.h,
                  width: 200.w,
                  color: AppColors.of(context).border,
                  child: Icon(
                    Icons.broken_image,
                    size: 40.sp,
                    color: AppColors.of(context).iconMuted,
                  ),
                ),
              ),
            ),
            if (message.text?.isNotEmpty == true)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  message.text!, 
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isMe 
                        ? AppColors.of(context).onPrimary 
                        : AppColors.of(context).textPrimary,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isMe 
                      ? AppColors.of(context).onPrimary.withOpacity(0.7) 
                      : AppColors.of(context).textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.of(context).background,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.of(context).subtleFill, height: 1),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.of(context).accent,
          size: 24.sp,
        ),
        onPressed: () => context.pop(),
      ),
      title: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return GestureDetector(
            onTap: () {
              if (widget.otherUserId != null) {
                context.push('/profile/public/${widget.otherUserId}');
              }
            },
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage: _derivedOtherUserAvatar != null && _derivedOtherUserAvatar!.isNotEmpty
                          ? CachedNetworkImageProvider(_derivedOtherUserAvatar!)
                          : null,
                      backgroundColor: AppColors.of(context).border,
                      child: (_derivedOtherUserAvatar == null || _derivedOtherUserAvatar!.isEmpty)
                          ? Icon(
                              Icons.person,
                              color: AppColors.of(context).textSecondary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: state.isOtherUserOnline
                              ? AppColors.of(context).success
                              : AppColors.of(context).iconMuted,
                          border: Border.all(
                            color: AppColors.of(context).surface,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  _derivedOtherUserName ?? l10n.chat,
                  style: TextStyle(
                    color: AppColors.of(context).textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                Text(
                  state.isOtherUserOnline ? l10n.online : l10n.offline,
                  style: TextStyle(
                    color: state.isOtherUserOnline
                        ? AppColors.of(context).accent
                        : AppColors.of(context).iconMuted,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: AppColors.of(context).accent,
            size: 24.sp,
          ),
          onPressed: _showOptionsMenu,
        ),
      ],
      toolbarHeight: 80.h,
    );
  }

  Widget _buildTypingIndicator() {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (prev, curr) => prev.typingUsers != curr.typingUsers,
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        if (state.typingUsers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              SizedBox(width: 24.w, child: _buildTypingDots()),
              SizedBox(width: 8.w),
              Text(
                '${widget.otherUserName ?? 'User'} ${l10n.isTyping}',
                style: TextStyle(
                  color: AppColors.of(context).textSecondary,
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: AppColors.of(context).textLight,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildIncomingMessage(String message, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.of(context).chatBubbleIncoming,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.r),
                    topRight: Radius.circular(18.r),
                    bottomRight: Radius.circular(18.r),
                    bottomLeft: Radius.circular(18.r),
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: AppColors.of(context).textPrimary,
                    fontSize: 16.sp,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Text(
                time,
                style: TextStyle(
                  color: AppColors.of(context).textLight,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutgoingMessage(String message, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
              decoration: BoxDecoration(
                color: AppColors.of(context).chatBubbleOutgoing,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(4.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: message,
                      style: TextStyle(
                        color: AppColors.of(context).onPrimary,
                        fontSize: 16.sp,
                        height: 1.3,
                      ),
                    ),
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: time,
                      style: TextStyle(
                        color: AppColors.of(context).onPrimary.withOpacity(0.7),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (prev, curr) => prev.isUserBlocked != curr.isUserBlocked,
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        if (state.isUserBlocked) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.of(context).surface,
              border: Border(
                top: BorderSide(color: AppColors.of(context).subtleFill),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.blockedUsers,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () {
                      if (widget.otherUserId != null) {
                        _chatBloc.add(UnblockUser(widget.otherUserId!));
                      }
                    },
                    child: Text(
                      l10n.clickHere,
                      style: TextStyle(
                        color: AppColors.of(context).primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.of(context).surface,
            border: Border(
              top: BorderSide(color: AppColors.of(context).subtleFill),
            ),
          ),
          child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: _showAttachmentOptions,
              icon: Icon(
                Icons.add,
                color: AppColors.of(context).accent,
                size: 28.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _messageController,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (_) => _chatBloc.add(const StartTyping()),
                decoration: InputDecoration(
                  hintText: l10n.typeMessage,
                  hintStyle: TextStyle(
                    color: AppColors.of(context).textSecondary,
                    fontSize: 16.sp,
                  ),
                  filled: true,
                  fillColor: AppColors.of(context).chatBubbleIncoming,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(color: AppColors.of(context).border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(color: AppColors.of(context).border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(
                      color: AppColors.of(context).textLight,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                style: TextStyle(
                  color: AppColors.of(context).textPrimary,
                  fontSize: 16.sp,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.of(context).accent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: Icon(
                  Icons.arrow_upward,
                  color: AppColors.of(context).onPrimary,
                  size: 20.sp,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
    },
   );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _chatBloc.add(SendTextMessage(text));
    _messageController.clear();
    _scrollToBottom(force: true);
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.of(context).surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: AppColors.of(context).success,
                  onTap: () {
                    Navigator.pop(ctx);
                    _shareLocation();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: AppColors.of(context).accent,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: AppColors.of(context).warning,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.of(context).textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
          'Location permission permanently denied. Enable in settings.',
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: AppLoaderFullPage()),
      );

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) Navigator.pop(context); // Dismiss loading

      _chatBloc.add(
        SendLocationMessage(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError('Failed to get location: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (image != null) {
        _chatBloc.add(SendImageMessage(image.path));
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _showError(String message) {
    AppSnackBar.showError(context, message);
  }

  Future<void> _openLocationInMaps(double lat, double lon) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(context).surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  width: 48.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 8.h),
                child: Row(
                  children: [
                    Text(
                      'More Options',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.of(context).border),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 8.h,
                ),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.of(context).accent,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  'View Profile',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.of(context).textLight,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  if (widget.otherUserId != null) {
                    context.push('/profile/public/${widget.otherUserId}');
                  }
                },
              ),
              Divider(
                height: 1,
                indent: 72.w,
                color: AppColors.of(context).subtleFill,
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 8.h,
                ),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag_outlined,
                    color: AppColors.of(context).warning,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  'Report User',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.of(context).textLight,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  if (widget.otherUserId != null) {
                    ReportDialog.show(
                      context,
                      targetType: ReportTargetType.user,
                      targetId: widget.otherUserId!,
                      targetName: widget.otherUserName,
                    );
                  }
                },
              ),
              Divider(
                height: 1,
                indent: 72.w,
                color: AppColors.of(context).subtleFill,
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 8.h,
                ),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _chatBloc.state.isUserBlocked ? Icons.lock_open : Icons.block_outlined,
                    color: AppColors.of(context).error,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  _chatBloc.state.isUserBlocked ? 'Unblock User' : 'Block User',
                  style: TextStyle(
                    color: AppColors.of(context).error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                titleAlignment: ListTileTitleAlignment
                    .center, // Ensure vertical alignment if needed
                onTap: () {
                  Navigator.pop(ctx);
                  if (widget.otherUserId != null) {
                    if (_chatBloc.state.isUserBlocked) {
                      _chatBloc.add(UnblockUser(widget.otherUserId!));
                    } else {
                      _showBlockConfirmationDialog(context, widget.otherUserId!);
                    }
                  }
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlockConfirmationDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Block User'),
        content: Text(
          'Are you sure you want to block ${widget.otherUserName ?? 'this user'}? They will no longer be able to message you, and their active listings won\'t be visible to you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: AppColors.of(context).textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.of(context).error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _chatBloc.add(BlockUser(userId));
            },
            child: Text('Block', style: TextStyle(color: AppColors.of(context).onPrimary)),
          ),
        ],
      ),
    );
  }
}
