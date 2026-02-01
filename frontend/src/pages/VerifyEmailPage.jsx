import { useEffect, useState } from "react";
import { useAuthStore } from "../store/useAuthStore";
import { useSearchParams, Link, useNavigate } from "react-router-dom";
import { Loader2, Mail, BadgeCheck, AlertCircle } from "lucide-react";
import AuthImagePattern from "../components/AuthImagePattern";

export const VerifyEmailPage = () => {
    const [searchParams] = useSearchParams();
    const token = searchParams.get("token");
    const { verifyEmail, isVerifyingEmail } = useAuthStore();
    const [status, setStatus] = useState("verifying"); // verifying, success, error
    const navigate = useNavigate();

    useEffect(() => {
        if (token) {
            handleVerification();
        } else {
            setStatus("error");
        }
    }, [token]);

    const handleVerification = async () => {
        try {
            await verifyEmail(token);
            setStatus("success");
            setTimeout(() => {
                navigate("/");
            }, 3000);
        } catch (error) {
            setStatus("error");
        }
    };

    return (
        <div className="min-h-screen grid lg:grid-cols-2">
            {/* Left Side */}
            <div className="flex flex-col justify-center items-center p-6 sm:p-12">
                <div className="w-full max-w-md space-y-8 text-center">
                    {/* Status Icon */}
                    <div className="flex justify-center">
                        <div className={`size-20 rounded-2xl flex items-center justify-center ${status === "verifying" ? "bg-primary/10" :
                            status === "success" ? "bg-green-500/10" : "bg-red-500/10"
                            }`}>
                            {status === "verifying" && <Loader2 className="size-10 text-primary animate-spin" />}
                            {status === "success" && <BadgeCheck className="size-10 text-green-500" />}
                            {status === "error" && <AlertCircle className="size-10 text-red-500" />}
                        </div>
                    </div>

                    {/* Status Text */}
                    <div className="space-y-4">
                        <h1 className="text-2xl font-bold">
                            {status === "verifying" && "Verifying your email"}
                            {status === "success" && "Email Verified!"}
                            {status === "error" && "Verification Failed"}
                        </h1>
                        <p className="text-base-content/60">
                            {status === "verifying" && "Please wait while we verify your email address..."}
                            {status === "success" && "Your email has been successfully verified. Redirecting you to the home page..."}
                            {status === "error" && "Invalid or expired verification link. Please request a new one."}
                        </p>
                    </div>

                    {/* Action Buttons */}
                    {status === "error" && (
                        <Link to="/login" className="btn btn-primary w-full">
                            Back to Login
                        </Link>
                    )}
                </div>
            </div>

            {/* Right Side */}
            <AuthImagePattern
                title="Verify your email"
                subtitle="Join thousands of users who are already part of our community. Verification helps keep our platform secure."
            />
        </div>
    );
};
