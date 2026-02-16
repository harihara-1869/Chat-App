import { useEffect, useState } from "react";
import { useAuthStore } from "../store/useAuthStore";
import { useSearchParams, Link, useNavigate } from "react-router-dom";
import { Loader2, Mail, Lock, KeyRound, BadgeCheck, AlertCircle, Eye, EyeOff, Check, X } from "lucide-react";
import AuthImagePattern from "../components/AuthImagePattern";

export const ResetPassword = () => {
    const [searchParams] = useSearchParams();
    const token = searchParams.get("token");
    const navigate = useNavigate();

    const { requestPasswordReset, updatePassword, isResettingPassword } = useAuthStore();

    // Mode: "request" (enter email) or "reset" (enter new password)
    const [mode, setMode] = useState(token ? "reset" : "request");
    const [status, setStatus] = useState("idle"); // idle, loading, success, error
    const [errorMessage, setErrorMessage] = useState("");

    // Request mode state
    const [email, setEmail] = useState("");

    // Reset mode state
    const [newPassword, setNewPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirmPassword, setShowConfirmPassword] = useState(false);

    // Password validation rules
    const passwordRules = [
        { id: "length", label: "At least 10 characters", regex: /.{10,}/ },
        { id: "lowercase", label: "One lowercase letter", regex: /[a-z]/ },
        { id: "uppercase", label: "One uppercase letter", regex: /[A-Z]/ },
        { id: "number", label: "One number", regex: /\d/ },
        { id: "special", label: "One special character (@$!%*?&)", regex: /[@$!%*?&]/ },
    ];

    // Check which rules are met
    const getPasswordValidation = (password) => {
        return passwordRules.map((rule) => ({
            ...rule,
            isValid: rule.regex.test(password),
        }));
    };

    const passwordValidation = getPasswordValidation(newPassword);
    const allRulesMet = passwordValidation.every((rule) => rule.isValid);
    const passwordsMatch = newPassword && confirmPassword && newPassword === confirmPassword;

    useEffect(() => {
        if (token) {
            setMode("reset");
        }
    }, [token]);

    const handleRequestReset = async (e) => {
        e.preventDefault();
        if (!email) return;

        setStatus("loading");
        setErrorMessage("");

        try {
            await requestPasswordReset(email);
            setStatus("success");
        } catch (error) {
            setStatus("error");
            setErrorMessage(error.response?.data?.message || "Failed to send reset email");
        }
    };

    const handleResetPassword = async (e) => {
        e.preventDefault();

        if (newPassword !== confirmPassword) {
            setStatus("error");
            setErrorMessage("Passwords do not match");
            return;
        }

        if (!allRulesMet) {
            setStatus("error");
            setErrorMessage("Password does not meet all requirements");
            return;
        }

        setStatus("loading");
        setErrorMessage("");

        try {
            await updatePassword(token, newPassword);
            setStatus("success");
            setTimeout(() => {
                navigate("/login");
            }, 3000);
        } catch (error) {
            setStatus("error");
            setErrorMessage(error.response?.data?.message || "Failed to reset password");
        }
    };

    return (
        <div className="min-h-screen grid lg:grid-cols-2">
            {/* Left Side - Form */}
            <div className="flex flex-col justify-center items-center p-6 sm:p-12">
                <div className="w-full max-w-md space-y-8">
                    {/* Icon */}
                    <div className="flex justify-center">
                        <div className={`size-16 rounded-2xl flex items-center justify-center ${status === "success" ? "bg-green-500/10" :
                            status === "error" ? "bg-red-500/10" : "bg-primary/10"
                            }`}>
                            {status === "loading" && <Loader2 className="size-8 text-primary animate-spin" />}
                            {status === "success" && <BadgeCheck className="size-8 text-green-500" />}
                            {status === "error" && <AlertCircle className="size-8 text-red-500" />}
                            {status === "idle" && <KeyRound className="size-8 text-primary" />}
                        </div>
                    </div>

                    {/* Title */}
                    <div className="text-center">
                        <h1 className="text-2xl font-bold">
                            {mode === "request" ? "Forgot Password?" : "Reset Password"}
                        </h1>
                        <p className="text-base-content/60 mt-2">
                            {mode === "request"
                                ? "Enter your email and we'll send you a reset link"
                                : "Enter your new password below"}
                        </p>
                    </div>

                    {/* Success/Error Messages */}
                    {status === "success" && (
                        <div className="text-center space-y-4">
                            <p className="text-green-500 font-medium">
                                {mode === "request"
                                    ? "Reset link sent! Check your email inbox."
                                    : "Password reset successful! Redirecting to login..."}
                            </p>
                            {mode === "request" && (
                                <Link to="/login" className="btn btn-primary w-full">
                                    Back to Login
                                </Link>
                            )}
                        </div>
                    )}

                    {status === "error" && (
                        <div className="alert alert-error">
                            <AlertCircle className="size-5" />
                            <span>{errorMessage}</span>
                        </div>
                    )}

                    {/* Request Form */}
                    {mode === "request" && status !== "success" && (
                        <form onSubmit={handleRequestReset} className="space-y-6">
                            <div className="form-control">
                                <label className="label">
                                    <span className="label-text font-medium">Email</span>
                                </label>
                                <div className="relative">
                                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <Mail className="h-5 w-5 text-base-content/40" />
                                    </div>
                                    <input
                                        type="email"
                                        className="input input-bordered w-full pl-10"
                                        placeholder="you@example.com"
                                        value={email}
                                        onChange={(e) => setEmail(e.target.value)}
                                        disabled={status === "loading"}
                                    />
                                </div>
                            </div>

                            <button
                                type="submit"
                                className="btn btn-primary w-full"
                                disabled={status === "loading" || !email}
                            >
                                {status === "loading" ? (
                                    <>
                                        <Loader2 className="h-5 w-5 animate-spin" />
                                        Sending...
                                    </>
                                ) : (
                                    "Send Reset Link"
                                )}
                            </button>
                        </form>
                    )}

                    {/* Reset Form */}
                    {mode === "reset" && status !== "success" && (
                        <form onSubmit={handleResetPassword} className="space-y-6">
                            <div className="form-control">
                                <label className="label">
                                    <span className="label-text font-medium">New Password</span>
                                </label>
                                <div className="relative">
                                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <Lock className="h-5 w-5 text-base-content/40" />
                                    </div>
                                    <input
                                        type={showPassword ? "text" : "password"}
                                        className="input input-bordered w-full pl-10"
                                        placeholder="••••••••"
                                        value={newPassword}
                                        onChange={(e) => setNewPassword(e.target.value)}
                                        disabled={status === "loading"}
                                    />
                                    <button
                                        type="button"
                                        className="absolute inset-y-0 right-0 pr-3 flex items-center"
                                        onClick={() => setShowPassword(!showPassword)}
                                    >
                                        {showPassword ? (
                                            <EyeOff className="h-5 w-5 text-base-content/40" />
                                        ) : (
                                            <Eye className="h-5 w-5 text-base-content/40" />
                                        )}
                                    </button>
                                </div>
                                
                                {/* Password Requirements */}
                                {newPassword && (
                                    <div className="mt-3 p-3 bg-base-200 rounded-lg">
                                        <p className="text-sm font-medium mb-2">Password requirements:</p>
                                        <ul className="space-y-1.5">
                                            {passwordValidation.map((rule) => (
                                                <li
                                                    key={rule.id}
                                                    className={`flex items-center gap-2 text-sm transition-colors ${
                                                        rule.isValid ? "text-success" : "text-base-content/60"
                                                    }`}
                                                >
                                                    {rule.isValid ? (
                                                        <Check className="h-4 w-4 shrink-0" />
                                                    ) : (
                                                        <X className="h-4 w-4 shrink-0" />
                                                    )}
                                                    <span>{rule.label}</span>
                                                </li>
                                            ))}
                                        </ul>
                                    </div>
                                )}
                            </div>

                            <div className="form-control">
                                <label className="label">
                                    <span className="label-text font-medium">Confirm Password</span>
                                </label>
                                <div className="relative">
                                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <Lock className="h-5 w-5 text-base-content/40" />
                                    </div>
                                    <input
                                        type={showConfirmPassword ? "text" : "password"}
                                        className="input input-bordered w-full pl-10"
                                        placeholder="••••••••"
                                        value={confirmPassword}
                                        onChange={(e) => setConfirmPassword(e.target.value)}
                                        disabled={status === "loading"}
                                    />
                                    <button
                                        type="button"
                                        className="absolute inset-y-0 right-0 pr-3 flex items-center"
                                        onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                                    >
                                        {showConfirmPassword ? (
                                            <EyeOff className="h-5 w-5 text-base-content/40" />
                                        ) : (
                                            <Eye className="h-5 w-5 text-base-content/40" />
                                        )}
                                    </button>
                                </div>
                            </div>

                            <button
                                type="submit"
                                className="btn btn-primary w-full"
                                disabled={status === "loading" || !newPassword || !confirmPassword}
                            >
                                {status === "loading" ? (
                                    <>
                                        <Loader2 className="h-5 w-5 animate-spin" />
                                        Resetting...
                                    </>
                                ) : (
                                    "Reset Password"
                                )}
                            </button>
                        </form>
                    )}

                    {/* Back to Login Link */}
                    {status !== "success" && (
                        <div className="text-center">
                            <p className="text-base-content/60">
                                Remember your password?{" "}
                                <Link to="/login" className="link link-primary">
                                    Sign in
                                </Link>
                            </p>
                        </div>
                    )}
                </div>
            </div>

            {/* Right Side - Pattern */}
            <AuthImagePattern
                title={mode === "request" ? "Forgot your password?" : "Almost there!"}
                subtitle={mode === "request"
                    ? "No worries! We'll help you reset it in no time."
                    : "Choose a strong password to keep your account secure."}
            />
        </div>
    );
};
