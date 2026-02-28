const mongoose = require('mongoose');

const conversationSchema = new mongoose.Schema(
    {
        participants: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        }],
        listing: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Listing',
            required: true,
        },
        lastMessage: {
            text: String,
            sender: {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'User',
            },
            timestamp: Date,
            hasImage: {
                type: Boolean,
                default: false,
            },
        },
        unreadCount: {
            type: Map,
            of: Number,
            default: new Map(),
        },
        isActive: {
            type: Boolean,
            default: true,
        },
        deletedFor: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
        }],
    },
    {
        timestamps: true,
    }
);

// Compound index for finding conversations
conversationSchema.index({ participants: 1, listing: 1 }, { unique: true });
conversationSchema.index({ participants: 1, updatedAt: -1 });

// Method to get unread count for a user
conversationSchema.methods.getUnreadCount = function (userId) {
    return this.unreadCount.get(userId.toString()) || 0;
};

// Method to increment unread count for other participants
conversationSchema.methods.incrementUnreadFor = function (senderId) {
    this.participants.forEach(participantId => {
        if (participantId.toString() !== senderId.toString()) {
            const currentCount = this.unreadCount.get(participantId.toString()) || 0;
            this.unreadCount.set(participantId.toString(), currentCount + 1);
        }
    });
};

// Method to reset unread count for a user
conversationSchema.methods.resetUnreadFor = function (userId) {
    this.unreadCount.set(userId.toString(), 0);
};

// Static method to find or create conversation
conversationSchema.statics.findOrCreate = async function (participant1, participant2, listingId) {
    // Sort participants to ensure consistent lookup
    const participants = [participant1, participant2].sort();

    let conversation = await this.findOne({
        participants: { $all: participants },
        listing: listingId,
    });

    if (!conversation) {
        conversation = await this.create({
            participants,
            listing: listingId,
            unreadCount: new Map([
                [participant1.toString(), 0],
                [participant2.toString(), 0],
            ]),
        });

        // Increment inquiries on listing
        await mongoose.model('Listing').findByIdAndUpdate(
            listingId,
            { $inc: { inquiries: 1 } }
        );
    }

    return conversation;
};

module.exports = mongoose.model('Conversation', conversationSchema);
