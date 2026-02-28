import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class ChatInputArea extends StatefulWidget {
  final TextEditingController controller;

  const ChatInputArea({super.key, required this.controller});

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isTyping = widget.controller.text.trim().isNotEmpty;
    if (isTyping != _isTyping) {
      setState(() {
        _isTyping = isTyping;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 1. Plus / Attachment Button
            _buildIconButton(
              icon: Icons.add,
              color: const Color(0xFF007AFF), // iOS Blue / Messenger Blue
              onTap: () {},
            ),

            SizedBox(width: 8.w),

            // 2. Make Offer Icon Button
            // Replaces the bulky "Make Offer" text button
            _buildIconButton(
              icon: Iconsax.dollar_circle,
              color: const Color(
                0xFFFE2C55,
              ), // Distinction color (e.g. TikTok/accent) or Green
              onTap: () {
                // Trigger offer logic
              },
              tooltip: 'Make an Offer',
            ),

            SizedBox(width: 12.w),

            // 3. Modern Pill Input Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F5), // Messenger/Telegram grey
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TextField(
                          controller: widget.controller,
                          minLines: 1,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Message...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15.sp,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Emoji Icon inside the text field
                    Padding(
                      padding: EdgeInsets.only(right: 8.w, bottom: 6.h),
                      child: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey[500],
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // 4. Send Button
            // Animates or changes color based on typing state is common,
            // but for now we keep the sleek circle style.
            GestureDetector(
              onTap: _isTyping
                  ? () {
                      // Send logic
                      widget.controller.clear();
                    }
                  : null, // Disable if empty? Or keep enabled for mic like WhatsApp
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: _isTyping ? const Color(0xFF007AFF) : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isTyping
                      ? Iconsax.send_15
                      : Icons.mic, // Switch to mic if not typing (mock)
                  color: _isTyping ? Colors.white : const Color(0xFF007AFF),
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: 6.h), // Align with text field bottom
        child: Icon(icon, color: color, size: 28.sp),
      ),
    );
  }
}
