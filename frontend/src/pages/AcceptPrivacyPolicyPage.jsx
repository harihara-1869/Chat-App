import React from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuthStore } from "../store/useAuthStore";
import {
    Shield,
    Eye,
    Lock,
    Database,
    Target,
    Users,
    AlertTriangle,
    Clock,
    Scale,
    Mail,
    FileText,
    Info,
    CheckCircle,
    Loader2,
} from "lucide-react";
import toast from "react-hot-toast";

export const AcceptPrivacyPolicyPage = () => {
    const [agreed, setAgreed] = React.useState(false);
    const [isAccepting, setIsAccepting] = React.useState(false);
    const { acceptPrivacyPolicy, authUser } = useAuthStore();
    const navigate = useNavigate();

    const handleAccept = async () => {
        if (!agreed) {
            toast.error("Please check the box to accept the Privacy Policy");
            return;
        }
        setIsAccepting(true);
        try {
            await acceptPrivacyPolicy();
            toast.success("Privacy policy accepted!");
            navigate("/");
        } catch {
            toast.error("Failed to accept privacy policy. Please try again.");
        } finally {
            setIsAccepting(false);
        }
    };

    const sections = [
        {
            icon: <Eye className="w-5 h-5 text-primary" />,
            title: "Information We Collect",
            intro: "We may collect the following information:",
            bullets: [
                "Name",
                "Email address (for account verification)",
                "Messages sent within the application",
                "Images uploaded by users",
                "Basic technical logs (such as login timestamps or IP logs, if applicable)",
            ],
        },
        {
            icon: <Database className="w-5 h-5 text-primary" />,
            title: "How Information Is Stored",
            bullets: [
                "Messages are stored in plain text.",
                "Uploaded images are stored and accessible via public URLs.",
                "Account details are stored in a database for authentication purposes.",
            ],
            warning: "This application does NOT provide end-to-end encryption.",
        },
        {
            icon: <Target className="w-5 h-5 text-primary" />,
            title: "Purpose of Data Collection",
            intro: "Your information is used solely for:",
            bullets: [
                "Account creation and verification",
                "Providing chat functionality",
                "Demonstrating application features",
                "Improving the project for learning purposes",
            ],
            note: "This project is non-commercial.",
        },
        {
            icon: <Lock className="w-5 h-5 text-primary" />,
            title: "Data Security",
            paragraphs: [
                "Reasonable efforts are made to protect basic account information. However, this application is not production-grade and should not be considered secure for confidential communication.",
                "Users are strongly advised not to share sensitive personal information.",
            ],
        },
        {
            icon: <Users className="w-5 h-5 text-primary" />,
            title: "Data Sharing",
            paragraphs: [
                "No personal data is sold, rented, or shared with third parties for marketing purposes.",
            ],
            intro2: "Data will only be disclosed:",
            bullets: [
                "If required by applicable Indian law",
                "To comply with legal obligations",
            ],
        },
        {
            icon: <AlertTriangle className="w-5 h-5 text-warning" />,
            title: "User Responsibility",
            intro: "Users are responsible for the information they choose to share on this platform.",
            intro2: "Do not upload or share:",
            bullets: [
                "Financial information",
                "Government identification numbers",
                "Passwords",
                "Confidential business information",
                "Any sensitive personal data",
            ],
        },
        {
            icon: <Clock className="w-5 h-5 text-primary" />,
            title: "Data Retention",
            paragraphs: [
                "User data may be retained as long as the project remains active. Users may request account deletion by contacting the developer.",
            ],
        },
        {
            icon: <Scale className="w-5 h-5 text-primary" />,
            title: "Your Rights",
            intro: "Under applicable Indian data protection laws, users may request:",
            bullets: [
                "Access to their personal data",
                "Correction of inaccurate information",
                "Deletion of their account data",
            ],
            note: "Requests may be made by contacting the developer (see below).",
        },
    ];

    return (
        <div className="min-h-screen bg-base-200 pt-20 pb-32">
            <div className="container mx-auto px-4 py-8 max-w-4xl">
                {/* Header */}
                <div className="mb-8">
                    <div className="flex items-center gap-3 mb-3">
                        <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                            <Shield className="w-6 h-6 text-primary" />
                        </div>
                        <div>
                            <h1 className="text-3xl font-bold">Privacy Policy</h1>
                            <p className="text-base-content/60 text-sm">
                                Last Updated: February 12, 2026
                            </p>
                        </div>
                    </div>
                    {authUser && (
                        <div className="alert alert-info mt-4 text-sm">
                            <Info className="w-4 h-4 shrink-0" />
                            <span>
                                Please review and accept our Privacy Policy to continue using the
                                application.
                            </span>
                        </div>
                    )}
                </div>

                {/* Introduction */}
                <div className="card bg-base-100 shadow-md mb-4">
                    <div className="card-body">
                        <div className="flex items-center gap-3 mb-3">
                            <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center shrink-0">
                                <Info className="w-5 h-5 text-primary" />
                            </div>
                            <h2 className="card-title text-lg">Introduction</h2>
                        </div>
                        <p className="text-base-content/80 leading-relaxed ml-1">
                            This application is a personal portfolio and demonstration chat
                            application created for educational and resume purposes. This
                            Privacy Policy explains how user information is collected, used,
                            and stored.
                        </p>
                        <p className="text-base-content/80 leading-relaxed ml-1 mt-2">
                            By using this application, you agree to this Privacy Policy.
                        </p>
                    </div>
                </div>

                {/* Sections */}
                <div className="space-y-4">
                    {sections.map((section, index) => (
                        <div
                            key={index}
                            className="card bg-base-100 shadow-md hover:shadow-lg transition-shadow duration-300"
                        >
                            <div className="card-body">
                                <div className="flex items-center gap-3 mb-3">
                                    <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center shrink-0">
                                        {section.icon}
                                    </div>
                                    <h2 className="card-title text-lg">{section.title}</h2>
                                </div>

                                {/* Paragraphs */}
                                {section.paragraphs &&
                                    section.paragraphs.map((p, i) => (
                                        <p
                                            key={i}
                                            className="text-base-content/80 leading-relaxed ml-1 mb-2"
                                        >
                                            {p}
                                        </p>
                                    ))}

                                {/* Intro text */}
                                {section.intro && (
                                    <p className="text-base-content/80 leading-relaxed ml-1 mb-2">
                                        {section.intro}
                                    </p>
                                )}

                                {/* Secondary intro */}
                                {section.intro2 && (
                                    <p className="text-base-content/80 leading-relaxed ml-1 mb-2 font-medium">
                                        {section.intro2}
                                    </p>
                                )}

                                {/* Bullet list */}
                                {section.bullets && (
                                    <ul className="space-y-2 ml-1">
                                        {section.bullets.map((item, i) => (
                                            <li
                                                key={i}
                                                className="flex gap-3 text-base-content/80"
                                            >
                                                <span className="text-primary mt-1 shrink-0">•</span>
                                                <span className="leading-relaxed">{item}</span>
                                            </li>
                                        ))}
                                    </ul>
                                )}

                                {/* Warning alert */}
                                {section.warning && (
                                    <div className="alert alert-warning mt-4 text-sm">
                                        <AlertTriangle className="w-4 h-4 shrink-0" />
                                        <span>{section.warning}</span>
                                    </div>
                                )}

                                {/* Info note */}
                                {section.note && (
                                    <p className="text-base-content/60 text-sm mt-3 ml-1 italic">
                                        {section.note}
                                    </p>
                                )}
                            </div>
                        </div>
                    ))}
                </div>

                {/* Contact Information */}
                <div className="card bg-base-100 shadow-md mt-4">
                    <div className="card-body">
                        <div className="flex items-center gap-3 mb-3">
                            <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center shrink-0">
                                <Mail className="w-5 h-5 text-primary" />
                            </div>
                            <h2 className="card-title text-lg">Contact Information</h2>
                        </div>
                        <p className="text-base-content/80 leading-relaxed ml-1">
                            For privacy-related concerns, contact:
                        </p>
                        <div className="ml-1 mt-2 space-y-1">
                            <p className="text-base-content/80">P R Hari Hara Sai Pratham</p>
                            <p className="text-base-content/80">harihara1869@gmail.com</p>
                        </div>
                    </div>
                </div>

                {/* Changes to Policy */}
                <div className="card bg-base-100 shadow-md mt-4">
                    <div className="card-body">
                        <div className="flex items-center gap-3 mb-3">
                            <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center shrink-0">
                                <FileText className="w-5 h-5 text-primary" />
                            </div>
                            <h2 className="card-title text-lg">Changes to This Policy</h2>
                        </div>
                        <p className="text-base-content/80 leading-relaxed ml-1">
                            This Privacy Policy may be updated at any time. Continued use of
                            the application constitutes acceptance of any changes.
                        </p>
                    </div>
                </div>

                {/* Footer */}
                <div className="text-center text-base-content/50 text-sm py-8">
                    <p>© 2026 — All rights reserved.</p>
                </div>
            </div>

            {/* Fixed Bottom Acceptance Banner */}
            <div className="fixed bottom-0 left-0 right-0 bg-base-100 border-t border-base-300 shadow-[0_-4px_20px_rgba(0,0,0,0.15)] z-50">
                <div className="container mx-auto px-4 py-4 max-w-4xl">
                    <div className="flex flex-col sm:flex-row items-center gap-4">
                        <label className="flex items-center gap-3 cursor-pointer flex-1">
                            <input
                                type="checkbox"
                                className="checkbox checkbox-primary"
                                checked={agreed}
                                onChange={(e) => setAgreed(e.target.checked)}
                            />
                            <span className="text-sm text-base-content/80">
                                I have read and agree to the{" "}
                                <span className="font-semibold text-base-content">
                                    Privacy Policy
                                </span>
                            </span>
                        </label>
                        <button
                            className="btn btn-primary gap-2 min-w-[180px]"
                            onClick={handleAccept}
                            disabled={!agreed || isAccepting}
                        >
                            {isAccepting ? (
                                <>
                                    <Loader2 className="w-4 h-4 animate-spin" />
                                    Accepting...
                                </>
                            ) : (
                                <>
                                    <CheckCircle className="w-4 h-4" />
                                    Accept & Continue
                                </>
                            )}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};
