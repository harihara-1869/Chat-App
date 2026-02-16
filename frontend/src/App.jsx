import React from "react";
import { Routes, Route } from "react-router-dom";
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
  const { authUser, checkAuth, isCheckingAuth, onlineUsers } = useAuthStore();
  const { theme } = useThemeStore();

  console.log(onlineUsers)

  React.useEffect(() => {
    checkAuth();
  }, [checkAuth]);

  const requestPermission = useNotificationStore(
    (s) => s.requestPermission
  );

  React.useEffect(() => {
    if (authUser) {
      requestPermission();
    }
  }, [authUser, requestPermission]);

  if (isCheckingAuth && !authUser) return (
    <div className="flex items-center justify-center h-screen">
      <Loader className="size-10 animate-spin" />
    </div>
  )

  return (
    <div data-theme={theme}>
      <Navbar />
      <Routes>
        <Route path="/" element={authUser ? <HomePage /> : <LoginPage />} />
        <Route path="/signup" element={!authUser ? <SignUpPage /> : <HomePage />} />
        <Route path="/login" element={!authUser ? <LoginPage /> : <HomePage />} />
        <Route path="/settings" element={<SettingsPage />} />
        <Route path="/profile" element={authUser ? <ProfilePage /> : <LoginPage />} />
        <Route path="/friends" element={authUser ? <FriendsPage /> : <LoginPage />} />
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

