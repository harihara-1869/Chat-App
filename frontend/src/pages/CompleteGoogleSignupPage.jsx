import { useState, useEffect } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useAuthStore } from "../store/useAuthStore";
import AuthImagePattern from "../components/AuthImagePattern";
import { 
  User, 
  Mail, 
  Loader2, 
  AlertTriangle,
  MessageSquare,
  ArrowLeft
} from "lucide-react";
import toast from "react-hot-toast";

export const CompleteGoogleSignupPage = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const token = searchParams.get("token");
  
  const { verifyGoogleToken, completeGoogleSignup, isSigningUp } = useAuthStore();
  
  const [formData, setFormData] = useState({
    fullName: "",
    email: "",
    profilePic: "",
    privacyPolicy: false,
    termsAndConditions: false,
  });
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!token) {
      toast.error("Invalid signup link");
      navigate("/login");
      return;
    }

    // Verify token and get user data
    const fetchUserData = async () => {
      const result = await verifyGoogleToken(token);
      if (result.success) {
        setFormData(prev => ({
          ...prev,
          fullName: result.data.fullName,
          email: result.data.email,
          profilePic: result.data.profilePic,
        }));
        setIsLoading(false);
      } else {
        setError(result.error || "Failed to load user data");
        setIsLoading(false);
        // If token is expired/invalid, user must restart
        setTimeout(() => {
          navigate("/login");
        }, 3000);
      }
    };

    fetchUserData();
  }, [token, navigate, verifyGoogleToken]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formData.privacyPolicy || !formData.termsAndConditions) {
      toast.error("You must accept the Privacy Policy and Terms and Conditions to continue");
      return;
    }

    const result = await completeGoogleSignup({
      tempToken: token,
      privacyPolicy: formData.privacyPolicy,
      termsAndConditions: formData.termsAndConditions,
      fullName: formData.fullName,
    });

    if (result.success) {
      navigate("/");
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="size-10 animate-spin" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <AlertTriangle className="size-16 text-error mx-auto mb-4" />
          <h2 className="text-2xl font-bold mb-2">Signup Expired</h2>
          <p className="text-base-content/60 mb-4">{error}</p>
          <p className="text-base-content/60">Redirecting to login...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen grid lg:grid-cols-2">
      {/* Left Side - Form */}
      <div className="flex flex-col justify-center items-center p-6 sm:p-12">
        <div className="w-full max-w-md space-y-8">
          {/* Logo */}
          <div className="text-center mb-8">
            <div className="flex flex-col items-center gap-2 group">
              <div className="size-12 rounded-xl bg-primary/10 flex items-center justify-center group-hover:bg-primary/20 transition-colors">
                <MessageSquare className="size-6 text-primary" />
              </div>
              <h1 className="text-2xl font-bold mt-2">Complete Your Profile</h1>
              <p className="text-base-content/60">
                One more step to get started
              </p>
            </div>
          </div>

          {/* Warning Alert */}
          <div className="alert alert-warning text-sm shadow-sm">
            <AlertTriangle className="w-4 h-4 shrink-0" />
            <span>
              Messages are stored in plain text and are not end-to-end encrypted.
            </span>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Full Name */}
            <div className="form-control">
              <label className="label">
                <span className="label-text font-medium">Full Name</span>
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <User className="size-5 text-base-content/40" />
                </div>
                <input
                  type="text"
                  className="input input-bordered w-full pl-10"
                  placeholder="Your full name"
                  value={formData.fullName}
                  onChange={(e) =>
                    setFormData({ ...formData, fullName: e.target.value })
                  }
                />
              </div>
              <label className="label">
                <span className="label-text-alt text-base-content/50">
                  You can edit your name from Google
                </span>
              </label>
            </div>

            {/* Email (Read Only) */}
            <div className="form-control">
              <label className="label">
                <span className="label-text font-medium">Email</span>
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Mail className="size-5 text-base-content/40" />
                </div>
                <input
                  type="email"
                  className="input input-bordered w-full pl-10 bg-base-200"
                  value={formData.email}
                  readOnly
                />
              </div>
              <label className="label">
                <span className="label-text-alt text-base-content/50">
                  Email from your Google account (cannot be changed)
                </span>
              </label>
            </div>

            {/* Privacy Policy and Terms Checkbox */}
            <div className="form-control">
              <label className="label cursor-pointer justify-start gap-3">
                <input
                  type="checkbox"
                  className="checkbox checkbox-primary checkbox-sm"
                  checked={formData.privacyPolicy && formData.termsAndConditions}
                  onChange={(e) =>
                    setFormData({ 
                      ...formData, 
                      privacyPolicy: e.target.checked,
                      termsAndConditions: e.target.checked
                    })
                  }
                />
                <span className="label-text">
                  I agree to the{" "}
                  <a
                    href="/privacy-policy"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="link link-primary"
                  >
                    Privacy Policy
                  </a>
                  {" "}and{" "}
                  <a
                    href="/terms-and-conditions"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="link link-primary"
                  >
                    Terms and Conditions
                  </a>
                </span>
              </label>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              className="btn btn-primary w-full"
              disabled={isSigningUp}
            >
              {isSigningUp ? (
                <>
                  <Loader2 className="size-5 animate-spin" />
                  Creating Account...
                </>
              ) : (
                "Create Account"
              )}
            </button>

            {/* Back to Login */}
            <button
              type="button"
              onClick={() => navigate("/login")}
              className="btn btn-ghost w-full gap-2"
            >
              <ArrowLeft className="size-4" />
              Back to Login
            </button>
          </form>
        </div>
      </div>

      {/* Right Side - Image Pattern */}
      <AuthImagePattern
        title="Join our community"
        subtitle="Connect with friends, share moments, and stay in touch with the people who matter most."
      />
    </div>
  );
};