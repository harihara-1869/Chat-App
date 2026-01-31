import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    provider: {
      type: String,
      enum: ["local", "google"],
      default: "local",
    },
    googleId: {
      type: String,
      default: null,
      sparse: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
    },
    emailVerified: {
      type: Boolean,
      default: false,
    },
    fullName: {
      type: String,
      required: true,
    },
    profilePic: {
      type: String,
      default: "",
    },
    password: {
      type: String,
      required: function () {
        return this.provider === "local";
      },
      minLength: 6,
    },
    friends: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ]
  },
  { timestamps: true }
);

// Create sparse index for googleId (allows multiple nulls but unique non-null values)
userSchema.index({ googleId: 1 }, { sparse: true, unique: true });

const User = mongoose.model("User", userSchema);
export default User;