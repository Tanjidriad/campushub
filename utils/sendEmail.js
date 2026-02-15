const { sendEmail, emailTemplates } = require('../config/nodemailer');

// Send verification email
const sendVerificationEmail = async (user, token) => {
    // Use backend API URL for verification (not frontend)
    const verificationUrl = `${process.env.API_URL || process.env.FRONTEND_URL}/api/auth/verify/${token}`;
    const template = emailTemplates.verification(user.name, verificationUrl);

    return await sendEmail({
        to: user.email,
        subject: template.subject,
        html: template.html,
    });
};

// Send password reset email
const sendPasswordResetEmail = async (user, token) => {
    // Use HTTPS URL that will redirect to app deep link (email clients don't support custom URL schemes)
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password/${token}`;
    const template = emailTemplates.passwordReset(user.name, resetUrl);

    return await sendEmail({
        to: user.email,
        subject: template.subject,
        html: template.html,
    });
};

// Send listing approved email
const sendListingApprovedEmail = async (user, listing) => {
    const listingUrl = `${process.env.APP_URL}listing/${listing._id}`;
    const template = emailTemplates.listingApproved(user.name, listing.title, listingUrl);

    return await sendEmail({
        to: user.email,
        subject: template.subject,
        html: template.html,
    });
};

// Send listing rejected email
const sendListingRejectedEmail = async (user, listing, reason) => {
    const template = emailTemplates.listingRejected(user.name, listing.title, reason);

    return await sendEmail({
        to: user.email,
        subject: template.subject,
        html: template.html,
    });
};

module.exports = {
    sendVerificationEmail,
    sendPasswordResetEmail,
    sendListingApprovedEmail,
    sendListingRejectedEmail,
};
