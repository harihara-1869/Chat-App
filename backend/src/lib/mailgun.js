import FormData from "form-data";
import Mailgun from "mailgun.js";
import dotenv from "dotenv";

dotenv.config();

const mailgun = new Mailgun(FormData);
const mg = mailgun.client({
    username: "api",
    key: process.env.MAILGUN_API_KEY,
});

export const sendVerificationEmail = async (email, token) => {
    try {
        const frontendUrl = process.env.FRONTEND_URL || "http://localhost:5173";
        const verificationLink = `${frontendUrl}/verify-email?token=${token}`;

        const data = await mg.messages.create(process.env.MAILGUN_DOMAIN || "manidweepa.site", {
            from: `Talkio <postmaster@${process.env.MAILGUN_DOMAIN || "manidweepa.site"}>`,
            to: [email],
            subject: "Verify your email address",
            html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Verify your email</h2>
          <p>Thanks for signing up for Talkio! Please click the button below to verify your email address.</p>
          <a href="${verificationLink}" style="background-color: #4F46E5; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0;">Verify Email</a>
          <p>Or click this link: <a href="${verificationLink}">${verificationLink}</a></p>
          <p>This link will expire in 24 hours.</p>
        </div>
      `,
        });

        console.log("Verification email sent:", data);
        return { success: true, data };
    } catch (error) {
        console.error("Error sending verification email:", error);
        return { success: false, error };
    }
};

export const sendResetPasswordEmail = async (email, token) => {
    try {
        const frontendUrl = process.env.FRONTEND_URL || "http://localhost:5173";
        const verificationLink = `${frontendUrl}/reset-password?token=${token}`;

        const data = await mg.messages.create(process.env.MAILGUN_DOMAIN || "manidweepa.site", {
            from: `Talkio <postmaster@${process.env.MAILGUN_DOMAIN || "manidweepa.site"}>`,
            to: [email],
            subject: "Reset your password",
            html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Reset your password</h2>
          <p>Thanks for signing up for Talkio! Please click the button below to reset your password.</p>
          <a href="${verificationLink}" style="background-color: #4F46E5; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0;">Reset Password</a>
          <p>Or click this link: <a href="${verificationLink}">${verificationLink}</a></p>
          <p>This link will expire in 15 mins.</p>
        </div>
      `,
        });

        console.log("Reset password email sent:", data);
        return { success: true, data };
    } catch (error) {
        console.error("Error sending reset password email:", error);
        return { success: false, error };
    }
};