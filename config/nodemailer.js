const nodemailer = require('nodemailer');

// Create transporter
const createTransporter = () => {
    return nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: process.env.SMTP_PORT,
        secure: process.env.SMTP_PORT === '465', // true for 465, false for other ports
        auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
        },
    });
};

// Send email
const sendEmail = async ({ to, subject, html, text }) => {
    try {
        const transporter = createTransporter();

        const mailOptions = {
            from: process.env.EMAIL_FROM,
            to,
            subject,
            html,
            text: text || html.replace(/<[^>]*>/g, ''), // Fallback plain text
        };

        const info = await transporter.sendMail(mailOptions);
        console.log(`📧 Email sent: ${info.messageId}`);
        return { success: true, messageId: info.messageId };
    } catch (error) {
        console.error('❌ Email error:', error);
        return { success: false, error: error.message };
    }
};

// Email templates
const emailTemplates = {
    verification: (name, verificationUrl) => ({
        subject: 'Verify Your CampusHub Pro Account',
        html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #4F46E5;">Welcome to CampusHub Pro! 🎓</h2>
        <p>Hi ${name},</p>
        <p>Thanks for signing up! Please verify your email address by clicking the button below:</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${verificationUrl}" 
             style="background-color: #4F46E5; color: white; padding: 14px 28px; text-decoration: none; border-radius: 8px; display: inline-block;">
            Verify Email
          </a>
        </div>
        <p style="color: #666;">This link will expire in 24 hours.</p>
        <p style="color: #666;">If you didn't create an account, you can safely ignore this email.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        <p style="color: #999; font-size: 12px;">CampusHub Pro - Your Campus Marketplace</p>
      </div>
    `,
    }),

    passwordReset: (name, resetUrl) => ({
        subject: 'Reset Your Password - CampusHub Pro',
        html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #4F46E5;">Password Reset Request 🔐</h2>
        <p>Hi ${name},</p>
        <p>We received a request to reset your password. Click the button below to create a new password:</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${resetUrl}" 
             style="background-color: #4F46E5; color: white; padding: 14px 28px; text-decoration: none; border-radius: 8px; display: inline-block;">
            Reset Password
          </a>
        </div>
        <p style="color: #666;">This link will expire in 1 hour.</p>
        <p style="color: #666;">If you didn't request this, please ignore this email.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        <p style="color: #999; font-size: 12px;">CampusHub Pro - Your Campus Marketplace</p>
      </div>
    `,
    }),

    listingApproved: (name, listingTitle, listingUrl) => ({
        subject: 'Your Listing Has Been Approved! 🎉',
        html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #22C55E;">Listing Approved! ✅</h2>
        <p>Hi ${name},</p>
        <p>Great news! Your listing "<strong>${listingTitle}</strong>" has been approved and is now live.</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${listingUrl}" 
             style="background-color: #22C55E; color: white; padding: 14px 28px; text-decoration: none; border-radius: 8px; display: inline-block;">
            View Listing
          </a>
        </div>
        <p style="color: #666;">Good luck with your sale!</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        <p style="color: #999; font-size: 12px;">CampusHub Pro - Your Campus Marketplace</p>
      </div>
    `,
    }),

    listingRejected: (name, listingTitle, reason) => ({
        subject: 'Listing Needs Changes',
        html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #EF4444;">Listing Not Approved</h2>
        <p>Hi ${name},</p>
        <p>Your listing "<strong>${listingTitle}</strong>" was not approved for the following reason:</p>
        <div style="background-color: #FEF2F2; padding: 15px; border-radius: 8px; margin: 20px 0;">
          <p style="margin: 0; color: #991B1B;">${reason}</p>
        </div>
        <p>Please update your listing and resubmit.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        <p style="color: #999; font-size: 12px;">CampusHub Pro - Your Campus Marketplace</p>
      </div>
    `,
    }),
};

module.exports = { sendEmail, emailTemplates };
