import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_user_app/core/widgets/app_loader.dart';
import 'package:book_user_app/core/widgets/shimmer_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:book_user_app/core/services/fcm_service.dart';
import 'package:book_user_app/injection_container/injection_container.dart';

import 'package:book_user_app/features/chat/data/models/chat_message.dart';
import 'package:book_user_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:book_user_app/features/chat/presentation/widgets/listing_info_bar.dart';
import 'package:book_user_app/features/report/domain/entities/report.dart';
import 'package:book_user_app/features/report/presentation/widgets/report_dialog.dart';
import 'package:book_user_app/features/offers/presentation/widgets/make_offer_sheet.dart';
import 'package:book_user_app/features/listings/data/datasources/listing_remote_datasource.dart';

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

  // Colors
  static const Color chatIncoming = Color(0xFFF2F2F7);
  static const Color chatOutgoing = Color(0xFFDDF2FD);
  static const Color chatBlueText = Color(0xFF007AFF);

  // Mapbox token for static maps
  static const String _mapboxToken =
      'pk.eyJ1IjoiYm9va3NhbGVhcHAiLCJhIjoiY200dTJjOXE1MDFhOTJrcXk0OG5jbjlyZyJ9.token';

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc();
    _chatBloc.add(LoadMessages(conversationId: widget.conversationId));

    // Track active conversation for notification suppression
    sl<FCMService>().activeConversationId = widget.conversationId;

    _scrollController.addListener(_onScroll);
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

    // ChatBloc.close() calls leaveConversation directly — no need to
    // add(LeaveConversation()) here (it races with close() and is dropped).
    _chatBloc.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showMakeOfferDialog(BuildContext context) {
    if (widget.listingId != null) {
      MakeOfferSheet.show(
        context,
        listingId: widget.listingId!,
        listingTitle: widget.listingTitle ?? 'Listing',
        listingPrice: widget.listingPrice ?? 0,
        listingImage: widget.listingImage,
        onOfferSent: (amount) {
          _chatBloc.add(
            SendTextMessage('💰 Made an offer: \$${amount.toStringAsFixed(2)}'),
          );
        },
      );
    }
  }

  void _showMarkAsSoldDialog(BuildContext context) {
    if (widget.listingId == null) return;

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
              color: const Color(0xFF22C55E),
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
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  if (widget.listingImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        widget.listingImage!,
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48.w,
                          height: 48.w,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                  if (widget.listingImage != null) SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.listingTitle ?? 'Listing',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.listingPrice != null)
                          Text(
                            '\$${widget.listingPrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF4794E6),
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
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await sl<ListingRemoteDataSource>().markAsSold(
                  widget.listingId!,
                );
                if (!mounted) return;

                // Send system message in chat
                _chatBloc.add(
                  SendTextMessage(
                    '🎉 "${widget.listingTitle ?? 'This item'}" has been marked as sold!',
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('✅ Listing marked as sold!'),
                    backgroundColor: const Color(0xFF22C55E),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text(
              'Mark as Sold',
              style: TextStyle(color: Colors.white),
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
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // ListingInfoBar - uses passed currentUserId for instant display
            ListingInfoBar(
              listingId: widget.listingId ?? '',
              title: widget.listingTitle ?? 'Listing',
              imageUrl: widget.listingImage,
              price: widget.listingPrice,
              sellerId: widget.sellerId,
              currentUserId: widget.currentUserId ?? _chatBloc.currentUserId,
              onViewListing: () {
                if (widget.listingId != null) {
                  context.push('/listing/${widget.listingId}');
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
                    curr.messages.length > prev.messages.length,
                listener: (context, state) => _scrollToBottom(),
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
                            color: Colors.grey,
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
    );
  }

  Widget _buildMessageList(ChatState state) {
    if (state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              'No messages yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start the conversation!',
              style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
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
      default:
        return isMe
            ? _buildOutgoingMessage(message.text ?? '', time)
            : _buildIncomingMessage(message.text ?? '', time);
    }
  }

  Widget _buildLocationBubble(ChatMessage message, bool isMe, String time) {
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
            color: isMe ? chatOutgoing : chatIncoming,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off, size: 24.sp, color: Colors.grey),
              SizedBox(width: 8.w),
              Text(
                'Location unavailable',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final mapUrl =
        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/$lon,$lat,14/200x120?access_token=$_mapboxToken';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.7.sw),
        decoration: BoxDecoration(
          color: isMe ? chatOutgoing : chatIncoming,
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
                  color: Colors.grey[200],
                  child: const Center(child: AppLoaderFullPage()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 120.h,
                  width: 200.w,
                  color: Colors.grey[200],
                  child: Icon(Icons.map, size: 40.sp, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: chatBlueText),
                  SizedBox(width: 4.w),
                  Text(
                    'Shared Location',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    time,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBubble(ChatMessage message, bool isMe, String time) {
    final imageUrl = message.image?.url ?? '';

    // Guard against empty or invalid URLs
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 0.7.sw),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isMe ? chatOutgoing : chatIncoming,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, size: 24.sp, color: Colors.grey),
              SizedBox(width: 8.w),
              Text(
                'Image unavailable',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
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
          color: isMe ? chatOutgoing : chatIncoming,
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
                  color: Colors.grey[200],
                  child: const Center(child: AppLoaderFullPage()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 150.h,
                  width: 200.w,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    size: 40.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            if (message.text?.isNotEmpty == true)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(message.text!, style: TextStyle(fontSize: 14.sp)),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: Text(
                time,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey[100], height: 1),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: chatBlueText, size: 24.sp),
        onPressed: () => context.pop(),
      ),
      title: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
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
                      backgroundImage: widget.otherUserAvatar != null
                          ? NetworkImage(widget.otherUserAvatar!)
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: widget.otherUserAvatar == null
                          ? Icon(Icons.person, color: Colors.grey[600])
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
                              ? Colors.green
                              : Colors.grey,
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.otherUserName ?? 'Chat',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                Text(
                  state.isOtherUserOnline ? 'online' : 'offline',
                  style: TextStyle(
                    color: state.isOtherUserOnline ? chatBlueText : Colors.grey,
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
          icon: Icon(Icons.more_horiz, color: chatBlueText, size: 24.sp),
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
                '${widget.otherUserName ?? 'User'} is typing...',
                style: TextStyle(
                  color: Colors.grey[600],
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
            color: Colors.grey[400],
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
                  color: chatIncoming,
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
                    color: Colors.black,
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
                style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
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
                color: chatOutgoing,
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
                        color: Colors.black,
                        fontSize: 16.sp,
                        height: 1.3,
                      ),
                    ),
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: time,
                      style: TextStyle(
                        color: Colors.grey[500],
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: _showAttachmentOptions,
              icon: Icon(Icons.add, color: chatBlueText, size: 28.sp),
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
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 16.sp),
                  filled: true,
                  fillColor: chatIncoming,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                style: TextStyle(color: Colors.black, fontSize: 16.sp),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: chatBlueText,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 20.sp,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
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
          color: Colors.white,
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
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(ctx);
                    _shareLocation();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.purple,
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
              color: Colors.black87,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                    color: Colors.grey[300],
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
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[200]),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 8.h,
                ),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4794E6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: const Color(0xFF4794E6),
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
                  color: Colors.grey[400],
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  if (widget.otherUserId != null) {
                    context.push('/profile/public/${widget.otherUserId}');
                  }
                },
              ),
              Divider(height: 1, indent: 72.w, color: Colors.grey[100]),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 8.h,
                ),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag_outlined,
                    color: const Color(0xFFF59E0B),
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
                  color: Colors.grey[400],
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
              Divider(height: 1, indent: 72.w, color: Colors.grey[100]),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 8.h,
                ),
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.block_outlined,
                    color: Colors.red,
                    size: 22.sp,
                  ),
                ),
                title: const Text(
                  'Block User',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                titleAlignment: ListTileTitleAlignment
                    .center, // Ensure vertical alignment if needed
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Implement block
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Block user - coming soon')),
                  );
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
