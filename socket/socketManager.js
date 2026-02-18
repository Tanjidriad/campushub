/**
 * Socket Manager - provides global access to the Socket.io instance
 * so controllers can emit events without direct access to the io object.
 */
let _io = null;

module.exports = {
    setIO(io) {
        _io = io;
    },

    getIO() {
        if (!_io) {
            console.warn('Socket.io not initialized yet');
        }
        return _io;
    },

    /**
     * Emit a system message to a conversation room in real-time.
     * Creates the message in DB and broadcasts via Socket.io.
     */
    async emitSystemMessage(conversationId, senderId, text) {
        const ChatMessage = require('../models/ChatMessage');

        const message = await ChatMessage.create({
            conversation: conversationId,
            sender: senderId,
            text,
            messageType: 'system',
        });

        await message.populate('sender', 'name avatar');

        if (_io) {
            _io.to(`conversation:${conversationId}`).emit('message:new', {
                message: message.toObject(),
                conversationId,
            });
        }

        return message;
    },
};
