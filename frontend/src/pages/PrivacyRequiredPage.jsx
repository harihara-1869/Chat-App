import { useState, useEffect } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useAuthStore } from "../store/useAuthStore";
import { PrivacyPolicyContent } from "../components/PrivacyPolicyContent";
import { 
  Loader2, 
  Shield,
  ArrowLeft,
  CheckCircle,
  XCircle
} from "lucide-react";
import toast from "react-hot-toast";

export const PrivacyRequiredPage = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const email = searchParams.get("email");
  
  const { acceptPrivacyPolicy, isLoggingIn } = useAuthStore();
  
  const [privacyAccepted, setPrivacyAccepted] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (!email) {
      toast.error("Invalid request");
      navigate("/login");
    }
  }, [email, navigate]);

  const handleAccept = async () => {
    if (!privacyAccepted) {
      toast.error("You must accept the privacy policy to continue");
      return;
    }

    setIsLoading(true);
    const result = await acceptPrivacyPolicy({
      email,
      privacyPolicy: true,
    });
    setIsLoading(false);

    if (result.success) {
      navigate("/");
    }
  };

  const handleDecline = () => {
    toast.error("You must accept the privacy policy to use this application");
    navigate("/login");
  };

  if (!email) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="size-10 animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-base-200 pt-20 pb-12">
      <div className="container mx-auto px-4 max-w-4xl">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={() => navigate("/login")}
            className="btn btn-ghost btn-sm gap-2 mb-4 text-base-content/70 hover:text-base-content"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Login
          </button>
          
          <div className="card bg-primary/10 border border-primary/20">
            <div className="card-body">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-primary/20 flex items-center justify-center shrink-0">
                  <Shield className="w-6 h-6 text-primary" />
                </div>
                <div>
                  <h1 className="text-2xl font-bold mb-2">Privacy Policy Update Required</h1>
                  <p className="text-base-content/80">
                    Before you can continue using your account, please review and accept our updated Privacy Policy. 
                    This is required to ensure you understand how we handle your data.
                  </p>
                  <p className="text-base-content/60 text-sm mt-2">
                    Account: {email}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Privacy Policy Content */}
        <div className="mb-8">
          <PrivacyPolicyContent showContact={true} />
        </div>

        {/* Acceptance Section */}
        <div className="card bg-base-100 shadow-lg border-2 border-primary/20">
          <div className="card-body">
            <h2 className="text-xl font-bold mb-4">Accept Privacy Policy</h2>
            
            {/* Checkbox */}
            <div className="form-control mb-6">
              <label className="label cursor-pointer justify-start gap-4">
                <input
                  type="checkbox"
                  className="checkbox checkbox-primary checkbox-lg"
                  checked={privacyAccepted}
                  onChange={(e) => setPrivacyAccepted(e.target.checked)}
                />
                <span className="label-text text-lg">
                  I have read and agree to the Privacy Policy
                </span>
              </label>
            </div>

            {/* Action Buttons */}
            <div className="flex flex-col sm:flex-row gap-4">
              <button
                onClick={handleAccept}
                disabled={isLoggingIn || isLoading}
                className="btn btn-primary flex-1 gap-2"
              >
                {(isLoggingIn || isLoading) ? (
                  <>
                    <Loader2 className="size-5 animate-spin" />
                    Processing...
                  </>
                ) : (
                  <>
                    <CheckCircle className="size-5" />
                    Accept and Continue
                  </>
                )}
              </button>
              
              <button
                onClick={handleDecline}
                disabled={isLoggingIn || isLoading}
                className="btn btn-ghost btn-outline gap-2"
              >
                <XCircle className="size-5" />
                Decline
              </button>
            </div>

            <p className="text-base-content/60 text-sm mt-4 text-center">
              By clicking "Accept and Continue", you acknowledge that you have read, understood, 
              and agree to be bound by our Privacy Policy.
            </p>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center text-base-content/50 text-sm py-8">
          <p>© 2026 — All rights reserved.</p>
        </div>
      </div>
    </div>
  );
};