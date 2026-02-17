import React from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import { HomePage } from "./pages/HomePage";
import { SignUpPage } from "./pages/SignUpPage";
import { LoginPage } from "./pages/LoginPage";
import { SettingsPage } from "./pages/SettingsPage";
import { ProfilePage } from "./pages/ProfilePage";
import { FriendsPage } from "./pages/FriendsPage";
import { VerifyEmailPage } from "./pages/VerifyEmailPage";
import { PrivacyPolicyPage } from "./pages/PrivacyPolicyPage";
import { TermsAndConditionsPage } from "./pages/TermsAndConditionsPage";
import { CompleteGoogleSignupPage } from "./pages/CompleteGoogleSignupPage";
import { AcceptPoliciesPage } from "./pages/AcceptPoliciesPage";
import { ResetPassword } from "./pages/ResetPassword";
import { Navbar } from "./components/Navbar";
import { useAuthStore } from "./store/useAuthStore";
import { useThemeStore } from "./store/useThemeStore";
import { Loader } from "lucide-react";
import { Toaster } from "react-hot-toast";
import { useNotificationStore } from "./store/useNotificationStore";

function App() {
  const { authUser, checkAuth, isCheckingAuth, onlineUsers, requiresPrivacyPolicy } = useAuthStore();
  const { theme } = useThemeStore();

  console.log(onlineUsers)

  React.useEffect(() => {
    checkAuth();
  }, [checkAuth]);

  const requestPermission = useNotificationStore(
    (s) => s.requestPermission
  );

  React.useEffect(() => {
    if (authUser && !requiresPrivacyPolicy) {
      requestPermission();
    }
  }, [authUser, requiresPrivacyPolicy, requestPermission]);

  if (isCheckingAuth && !authUser) return (
    <div className="flex items-center justify-center h-screen">
      <Loader className="size-10 animate-spin" />
    </div>
  )

  // Helper: redirect to accept-privacy-policy if policy not accepted
  const protectedRoute = (element) => {
    if (!authUser) return <LoginPage />;
    if (requiresPrivacyPolicy) return <Navigate to="/accept-privacy-policy" />;
    return element;
  };

  return (
    <div data-theme={theme}>
      <Navbar />
      <Routes>
        <Route path="/" element={protectedRoute(<HomePage />)} />
        <Route path="/signup" element={!authUser ? <SignUpPage /> : requiresPrivacyPolicy ? <Navigate to="/accept-privacy-policy" /> : <HomePage />} />
        <Route path="/login" element={!authUser ? <LoginPage /> : requiresPrivacyPolicy ? <Navigate to="/accept-privacy-policy" /> : <HomePage />} />
        <Route path="/settings" element={<SettingsPage />} />
        <Route path="/profile" element={protectedRoute(<ProfilePage />)} />
        <Route path="/friends" element={protectedRoute(<FriendsPage />)} />
        <Route path="/verify-email" element={<VerifyEmailPage />} />
        <Route path="/reset-password" element={<ResetPassword />} />
        <Route path="/privacy-policy" element={<PrivacyPolicyPage />} />
        <Route path="/terms-and-conditions" element={<TermsAndConditionsPage />} />
        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
        <Route path="/accept-policies" element={<AcceptPoliciesPage />} />
      </Routes>

      <Toaster />
    </div>
  );
}

export default App;
