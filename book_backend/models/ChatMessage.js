const mongoose = require('mongoose');

const chatMessageSchema = new mongoose.Schema(
    {
        conversation: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Conversation',
            required: true,
            index: true,
        },
        sender: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        text: {
            type: String,
            maxlength: [2000, 'Message cannot exceed 2000 characters'],
        },
        image: {
            url: String,
            publicId: String,
        },
        messageType: {
            type: String,
            enum: ['text', 'image', 'system', 'location'],
            default: 'text',
        },
        location: {
            latitude: Number,
            longitude: Number,
            address: String,
        },

        // Delivery status
        deliveredAt: {
            type: Date,
            default: null,
        },
        readAt: {
            type: Date,
            default: null,
        },

        // Soft delete
        isDeleted: {
            type: Boolean,
            default: false,
        },
        deletedFor: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
        }],
        isDeletedForEveryone: {
            type: Boolean,
            default: false,
        },

        // Edit tracking
        isEdited: {
            type: Boolean,
            default: false,
        },
        editedAt: {
            type: Date,
            default: null,
        },
    },
    {
        timestamps: true,
    }
);

// Indexes for efficient message retrieval
chatMessageSchema.index({ conversation: 1, createdAt: -1 });
chatMessageSchema.index({ sender: 1, createdAt: -1 });

// Validate that message has either text or image
chatMessageSchema.pre('validate', function () {
    if (!this.text && !this.image?.url && !this.location && this.messageType !== 'system') {
        throw new Error('Message must have content (text, image, or location)');
    }
});

// Update conversation's last message after save
chatMessageSchema.post('save', async function () {
    if (!this.isDeleted) {
        await mongoose.model('Conversation').findByIdAndUpdate(
            this.conversation,
            {
                lastMessage: {
                    text: this.text || (this.location ? '\ud83d\udccd Location' : '\ud83d\udcf7 Image'),
                    sender: this.sender,
                    timestamp: this.createdAt,
                    hasImage: !!this.image?.url,
                },
            }
        );
    }
});

// Static method to mark messages as delivered
chatMessageSchema.statics.markDelivered = async function (conversationId, userId) {
    return await this.updateMany(
        {
            conversation: conversationId,
            sender: { $ne: userId },
            deliveredAt: null,
        },
        {
            $set: { deliveredAt: new Date() },
        }
    );
};

// Static method to mark messages as read
chatMessageSchema.statics.markRead = async function (conversationId, userId) {
    const result = await this.updateMany(
        {
            conversation: conversationId,
            sender: { $ne: userId },
            readAt: null,
        },
        {
            $set: { readAt: new Date() },
        }
    );

    // Reset unread count in conversation
    await mongoose.model('Conversation').findByIdAndUpdate(
        conversationId,
        { [`unreadCount.${userId}`]: 0 }
    );

    return result;
};

module.exports = mongoose.model('ChatMessage', chatMessageSchema);
