import 'package:book_user_app/core/widgets/shimmer_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:book_user_app/features/chat/data/models/conversation.dart';
import 'package:book_user_app/features/chat/presentation/bloc/conversations_bloc.dart';
import 'package:book_user_app/features/listings/presentation/widgets/custom_bottom_nav.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosGray = Color(0xFF8E8E93);
  static const Color iosLightGray = Color(0xFFF2F2F7);

  // Reference to the root-level ConversationsBloc — do NOT close it here.
  late ConversationsBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Grab the root-level instance provided by main.dart
      _bloc = context.read<ConversationsBloc>();
      // Refresh the list and ensure the listener is active
      _bloc.add(const LoadConversations(page: 1, refresh: true));
      _scrollController.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _bloc.state;
      if (state.hasMore && state.status != ConversationsStatus.loading) {
        _bloc.add(LoadConversations(page: state.currentPage + 1));
      }
    }
  }

  @override
  void dispose() {
    // Do NOT close _bloc — it belongs to the root and outlives this page.
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No BlocProvider wrapper needed — root already provides ConversationsBloc.
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildConversationsList()),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Edit',
            style: TextStyle(
              color: iosBlue,
              fontSize: 17.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            'Messages',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: New conversation
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: iosBlue,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(color: iosGray, fontSize: 17.sp),
          prefixIcon: Icon(Icons.search, color: iosGray, size: 20.sp),
          filled: true,
          fillColor: iosLightGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        style: TextStyle(fontSize: 17.sp, color: Colors.black),
      ),
    );
  }

  Widget _buildConversationsList() {
    return BlocBuilder<ConversationsBloc, ConversationsState>(
      builder: (context, state) {
        if (state.status == ConversationsStatus.loading &&
            state.conversations.isEmpty) {
          return const ConversationListShimmer();
        }

        if (state.status == ConversationsStatus.error &&
            state.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(state.error ?? 'Failed to load conversations'),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => _bloc.add(const LoadConversations()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.conversations.isEmpty) {
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
                  'No conversations yet',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Start chatting with sellers!',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _bloc.add(const RefreshConversations());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.separated(
            controller: _scrollController,
            itemCount: state.conversations.length,
            separatorBuilder: (_, __) => Padding(
              padding: EdgeInsets.only(left: 76.w),
              child: Divider(
                color: Colors.grey[300],
                height: 1,
                thickness: 0.5,
              ),
            ),
            itemBuilder: (context, index) {
              return _buildConversationItem(state.conversations[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    final currentUserId = _bloc.currentUserId;
    final otherParticipant = conversation.participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => conversation.participants.first,
    );

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        _bloc.add(DeleteConversation(conversation.id));
      },
      child: GestureDetector(
        onTap: () {
          final listing = conversation.listing;
          final firstImage = listing.images.isNotEmpty
              ? listing.images.first
              : '';
          final avatar = otherParticipant.avatar ?? '';

          context
              .push(
                '/chat/detail/${conversation.id}'
                '?name=${Uri.encodeComponent(otherParticipant.name)}'
                '&avatar=${Uri.encodeComponent(avatar)}'
                '&userId=${otherParticipant.id}'
                '&listingId=${listing.id}'
                '&listingTitle=${Uri.encodeComponent(listing.title)}'
                '&listingImage=${Uri.encodeComponent(firstImage)}'
                '&listingPrice=${listing.price ?? 0}'
                '&sellerId=${listing.sellerId ?? ''}'
                '&currentUserId=${currentUserId ?? ''}',
              )
              .then((_) {
                if (context.mounted) {
                  _bloc.add(const RefreshConversations());
                }
              });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              _buildAvatar(otherParticipant),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          otherParticipant.name,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _formatTime(conversation.lastMessage?.timestamp),
                          style: TextStyle(fontSize: 15.sp, color: iosGray),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _getMessagePreview(conversation),
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: iosGray,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_getUnreadCount(conversation) > 0)
                          Container(
                            constraints: BoxConstraints(minWidth: 20.w),
                            height: 20.w,
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            decoration: BoxDecoration(
                              color: iosBlue,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getUnreadCount(conversation).toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
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

  Widget _buildAvatar(ConversationParticipant participant) {
    if (participant.avatar != null && participant.avatar!.isNotEmpty) {
      return CircleAvatar(
        radius: 24.r,
        backgroundImage: NetworkImage(participant.avatar!),
        backgroundColor: Colors.grey[300],
      );
    }

    return CircleAvatar(
      radius: 24.r,
      backgroundColor: const Color(0xFFE9E9EB),
      child: Text(
        participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 22.sp,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('M/d/yy').format(dateTime);
    }
  }

  int _getUnreadCount(Conversation conversation) {
    final userId = _bloc.currentUserId;
    if (userId == null) return 0;
    return conversation.getUnreadFor(userId);
  }

  String _getMessagePreview(Conversation conversation) {
    final lastMsg = conversation.lastMessage;
    if (lastMsg == null) return 'No messages yet';

    final isMe = lastMsg.sender == _bloc.currentUserId;
    final prefix = isMe ? 'You: ' : '';

    if (lastMsg.hasImage) {
      return '${prefix}📷 Photo';
    }

    final text = lastMsg.text ?? '';
    if (text.startsWith('📍 Location:')) {
      return '${prefix}📍 Location';
    }

    return '$prefix$text';
  }
}
