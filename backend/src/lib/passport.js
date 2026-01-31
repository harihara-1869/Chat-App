import passport from "passport";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import User from "../models/user.model.js";
import dotenv from "dotenv";

dotenv.config();

// Configure Google OAuth 2.0 Strategy
passport.use(
    new GoogleStrategy(
        {
            clientID: process.env.GOOGLE_CLIENT_ID,
            clientSecret: process.env.GOOGLE_CLIENT_SECRET,
            callbackURL: process.env.GOOGLE_CALLBACK_URL,
        },
        async (accessToken, refreshToken, profile, done) => {
            try {
                // Check if user already exists with this Google ID
                let user = await User.findOne({ googleId: profile.id });

                if (user) {
                    return done(null, user);
                }

                // Check if user exists with same email (from local registration)
                user = await User.findOne({ email: profile.emails[0].value });

                if (user) {
                    // Link Google account to existing user
                    user.googleId = profile.id;
                    user.provider = "google";
                    user.emailVerified = profile.emails[0].verified || true;
                    if (profile.photos && profile.photos[0]) {
                        user.profilePic = profile.photos[0].value;
                    }
                    await user.save();
                    return done(null, user);
                }

                // Create new user
                const newUser = new User({
                    provider: "google",
                    googleId: profile.id,
                    email: profile.emails[0].value,
                    emailVerified: profile.emails[0].verified || true,
                    fullName: profile.displayName,
                    profilePic: profile.photos?.[0]?.value || "",
                });

                await newUser.save();
                return done(null, newUser);
            } catch (error) {
                return done(error, null);
            }
        }
    )
);

// Serialize user for session (not used in JWT-based auth, but required by Passport)
passport.serializeUser((user, done) => {
    done(null, user._id);
});

passport.deserializeUser(async (id, done) => {
    try {
        const user = await User.findById(id);
        done(null, user);
    } catch (error) {
        done(error, null);
    }
});

export default passport;
