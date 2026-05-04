import 'package:book_user_app/core/theme/app_palette.dart';
import 'package:book_user_app/core/widgets/empty_state_widget.dart';
import 'package:book_user_app/core/widgets/shimmer_skeletons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:book_user_app/features/chat/data/models/conversation.dart';
import 'package:book_user_app/features/chat/presentation/bloc/conversations_bloc.dart';
import 'package:book_user_app/features/listings/presentation/widgets/custom_bottom_nav.dart';
import 'package:book_user_app/l10n/app_localizations.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  Color get iosBlue => AppColors.of(context).accent;
  Color get iosGray => AppColors.of(context).textSecondary;
  Color get iosLightGray => AppColors.of(context).inputFill;

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
      backgroundColor: AppColors.of(context).background,
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
    final l10n = AppLocalizations.of(context)!;
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
            l10n.messages,
            style: TextStyle(
              color: AppColors.of(context).textPrimary,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              _showNewConversationInfo();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: iosBlue,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: AppColors.of(context).onPrimary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    l10n.newLabel,
                    style: TextStyle(
                      color: AppColors.of(context).onPrimary,
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

  void _showNewConversationInfo() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(context).surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                l10n.messages,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.startChattingWithSellers,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Guide user to browse listings to start a conversation.
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).accent,
                    foregroundColor: AppColors.of(context).onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    l10n.exploreListings,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: l10n.search,
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
        style: TextStyle(
          fontSize: 17.sp,
          color: AppColors.of(context).textPrimary,
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    return BlocBuilder<ConversationsBloc, ConversationsState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
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
                Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: AppColors.of(context).textSecondary,
                ),
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
            child: EmptyStateWidget(
              icon: Icons.chat_bubble_outline,
              title: l10n.noConversationsYet,
              subtitle: l10n.startChattingWithSellers,
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
                color: AppColors.of(context).border,
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
        color: AppColors.of(context).error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        child: Icon(Icons.delete, color: AppColors.of(context).onPrimary),
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
                            color: AppColors.of(context).textPrimary,
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
                                color: AppColors.of(context).onPrimary,
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
        backgroundImage: CachedNetworkImageProvider(participant.avatar!),
        backgroundColor: AppColors.of(context).border,
      );
    }

    return CircleAvatar(
      radius: 24.r,
      backgroundColor: AppColors.of(context).subtleFill,
      child: Text(
        participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 22.sp,
          color: AppColors.of(context).textSecondary,
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
      return AppLocalizations.of(context)!.yesterday;
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
