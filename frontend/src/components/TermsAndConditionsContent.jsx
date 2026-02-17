import {
    Gavel,
    Users,
    Shield,
    Cloud,
    Ban,
    Copyright,
    Eye,
    AlertCircle,
    Scale,
    ShieldAlert,
    LogOut,
    Globe,
    RefreshCw,
    Mail,
    Info,
    FileText,
} from "lucide-react";

export const TermsAndConditionsContent = ({ showContact = true }) => {
    const sections = [
        {
            icon: <Info className="w-5 h-5 text-primary" />,
            title: "1. Nature of the Platform",
            paragraphs: [
                "This Platform is a demo and portfolio project developed for educational, evaluation, and demonstration purposes.",
            ],
            intro2: "The Platform:",
            bullets: [
                "Is not a commercial messaging service",
                "Is not intended for sensitive, confidential, financial, medical, or legal communication",
                "May be modified, suspended, or discontinued at any time without notice",
            ],
            note: "Users acknowledge that the Platform is provided primarily for demonstration purposes.",
        },
        {
            icon: <Users className="w-5 h-5 text-primary" />,
            title: "2. Eligibility",
            intro: "By using the Platform, you confirm that:",
            bullets: [
                "You are at least 18 years of age; or",
                "You are using the Platform under lawful supervision",
                "You are legally competent to enter into a binding agreement under Indian law",
            ],
        },
        {
            icon: <Shield className="w-5 h-5 text-primary" />,
            title: "3. User Accounts",
            intro: "To use certain features, you may be required to create an account.",
            intro2: "You agree to:",
            bullets: [
                "Provide accurate and complete information",
                "Maintain the confidentiality of your login credentials",
                "Notify us immediately of any unauthorized access",
            ],
            paragraphs: [
                "You are responsible for all activities conducted through your account.",
            ],
            warning: "We reserve the right to suspend or terminate accounts that violate these Terms.",
        },
        {
            icon: <Eye className="w-5 h-5 text-primary" />,
            title: "4. Data Storage and Security",
            subsections: [
                {
                    title: "4.1 Message Storage",
                    paragraphs: [
                        "Messages exchanged through the Platform are currently stored in plain text format within our database.",
                        "The Platform does not provide end-to-end encryption.",
                    ],
                    warning: "Users are strongly advised not to share sensitive or confidential information through the Platform.",
                },
                {
                    title: "4.2 Image Uploads",
                    paragraphs: [
                        "Images uploaded by users may be hosted using Cloudinary or similar third-party storage services.",
                    ],
                    intro2: "Uploaded images:",
                    bullets: [
                        "May be accessible via public URLs",
                        "May not be protected by private access controls",
                        "Are subject to Cloudinary's terms and policies",
                    ],
                    warning: "Users should not upload private, confidential, or sensitive content.",
                },
                {
                    title: "4.3 Data Use",
                    intro2: "We:",
                    bullets: [
                        "Do not sell user data",
                        "Do not rent or commercially distribute personal information",
                        "Do not intentionally share personal data with third parties except as described below",
                    ],
                    intro3: "Data may be shared:",
                    bullets2: [
                        "With hosting or infrastructure providers strictly for service operation",
                        "When required by applicable law, regulation, or court order",
                        "To protect the rights, safety, or security of the Platform or others",
                    ],
                },
            ],
        },
        {
            icon: <Ban className="w-5 h-5 text-primary" />,
            title: "5. Acceptable Use",
            intro: "You agree not to:",
            bullets: [
                "Use the Platform for unlawful purposes",
                "Share illegal, harmful, abusive, or infringing content",
                "Upload malicious software or attempt to compromise the Platform",
                "Harass, threaten, or impersonate others",
            ],
            warning: "We reserve the right to remove content and suspend accounts violating this section.",
        },
        {
            icon: <Copyright className="w-5 h-5 text-primary" />,
            title: "6. Intellectual Property",
            paragraphs: [
                "All software, design, branding, and content (excluding user-generated content) remain the intellectual property of P R Hari Hara Sai Pratham.",
                "Users retain ownership of their own uploaded content but grant us a limited license to store and display such content for the purpose of operating the Platform.",
            ],
        },
        {
            icon: <Eye className="w-5 h-5 text-primary" />,
            title: "7. Privacy",
            paragraphs: [
                "Use of the Platform is also governed by our Privacy Policy.",
            ],
            intro2: "Users acknowledge that:",
            bullets: [
                "Absolute security cannot be guaranteed",
                "Internet transmissions may carry inherent risks",
            ],
        },
        {
            icon: <AlertCircle className="w-5 h-5 text-warning" />,
            title: "8. Disclaimer of Warranties",
            intro: "The Platform is provided on an \"as is\" and \"as available\" basis.",
            intro2: "We make no warranties regarding:",
            bullets: [
                "Continuous availability",
                "Security against all possible vulnerabilities",
                "Accuracy or reliability of communications",
            ],
        },
        {
            icon: <Scale className="w-5 h-5 text-primary" />,
            title: "9. Limitation of Liability",
            intro: "To the maximum extent permitted under Indian law:",
            bullets: [
                "We shall not be liable for indirect, incidental, special, or consequential damages",
                "We are not responsible for loss of data, unauthorized access, or service interruptions",
                "Total liability shall not exceed the amount paid by the user (if any), which in this case is zero for demo usage",
            ],
        },
        {
            icon: <ShieldAlert className="w-5 h-5 text-primary" />,
            title: "10. Indemnification",
            intro: "You agree to indemnify and hold harmless P R Hari Hara Sai Pratham from any claims, damages, liabilities, or expenses arising out of:",
            bullets: [
                "Your misuse of the Platform",
                "Violation of these Terms",
                "Violation of applicable laws",
            ],
        },
        {
            icon: <LogOut className="w-5 h-5 text-primary" />,
            title: "11. Termination",
            intro: "We reserve the right to:",
            bullets: [
                "Suspend or terminate accounts",
                "Remove content",
                "Discontinue the Platform",
            ],
            note: "At our sole discretion, without prior notice.",
        },
        {
            icon: <Globe className="w-5 h-5 text-primary" />,
            title: "12. Governing Law and Jurisdiction",
            paragraphs: [
                "These Terms shall be governed by and interpreted in accordance with the laws of India.",
                "Any disputes arising shall be subject to the exclusive jurisdiction of the courts located in India.",
            ],
        },
        {
            icon: <RefreshCw className="w-5 h-5 text-primary" />,
            title: "13. Changes to Terms",
            paragraphs: [
                "We may update these Terms at any time. Continued use of the Platform constitutes acceptance of revised Terms.",
            ],
        },
    ];

    return (
        <div className="space-y-4">
            {/* Header */}
            <div className="flex items-center gap-3 mb-3">
                <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                    <Gavel className="w-6 h-6 text-primary" />
                </div>
                <div>
                    <h1 className="text-2xl font-bold">Terms and Conditions</h1>
                    <p className="text-base-content/60 text-sm">
                        Effective Date: February 13, 2026
                    </p>
                </div>
            </div>

            {/* Introduction */}
            <div className="card bg-base-100 shadow-md">
                <div className="card-body">
                    <div className="flex items-center gap-3 mb-3">
                        <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center shrink-0">
                            <Info className="w-5 h-5 text-primary" />
                        </div>
                        <h2 className="card-title text-lg">Welcome</h2>
                    </div>
                    <p className="text-base-content/80 leading-relaxed ml-1">
                        Welcome to Talkio ("Platform", "Service", "we", "our", or "us").
                    </p>
                    <p className="text-base-content/80 leading-relaxed ml-1 mt-2">
                        These Terms and Conditions ("Terms") govern your access to and use of the Platform
                        operated by P R Hari Hara Sai Pratham, based in India.
                    </p>
                    <p className="text-base-content/80 leading-relaxed ml-1 mt-2 font-medium">
                        By accessing or using this Platform, you agree to be bound by these Terms.
                        If you do not agree, please discontinue use immediately.
                    </p>
                </div>
            </div>

            {/* Sections */}
            {sections.map((section, index) => (
                <div
                    key={index}
                    className="card bg-base-100 shadow-md"
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

                        {/* Tertiary intro */}
                        {section.intro3 && (
                            <p className="text-base-content/80 leading-relaxed ml-1 mb-2 font-medium">
                                {section.intro3}
                            </p>
                        )}

                        {/* Subsections */}
                        {section.subsections &&
                            section.subsections.map((subsection, subIndex) => (
                                <div key={subIndex} className="mb-4 ml-1">
                                    <h3 className="font-semibold text-base-content/90 mb-2">
                                        {subsection.title}
                                    </h3>

                                    {subsection.paragraphs &&
                                        subsection.paragraphs.map((p, i) => (
                                            <p key={i} className="text-base-content/80 leading-relaxed mb-2">
                                                {p}
                                            </p>
                                        ))}

                                    {subsection.intro2 && (
                                        <p className="text-base-content/80 leading-relaxed mb-2 font-medium">
                                            {subsection.intro2}
                                        </p>
                                    )}

                                    {subsection.intro3 && (
                                        <p className="text-base-content/80 leading-relaxed mb-2 font-medium">
                                            {subsection.intro3}
                                        </p>
                                    )}

                                    {subsection.bullets && (
                                        <ul className="space-y-2">
                                            {subsection.bullets.map((item, i) => (
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

                                    {subsection.bullets2 && (
                                        <ul className="space-y-2 mt-2">
                                            {subsection.bullets2.map((item, i) => (
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

                                    {subsection.warning && (
                                        <div className="alert alert-warning mt-3 text-sm">
                                            <AlertCircle className="w-4 h-4 shrink-0" />
                                            <span>{subsection.warning}</span>
                                        </div>
                                    )}

                                    {subsection.note && (
                                        <p className="text-base-content/60 text-sm mt-2 italic">
                                            {subsection.note}
                                        </p>
                                    )}
                                </div>
                            ))}

                        {/* Bullet list */}
                        {section.bullets && !section.subsections && (
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

                        {/* Secondary bullet list */}
                        {section.bullets2 && (
                            <ul className="space-y-2 ml-1 mt-2">
                                {section.bullets2.map((item, i) => (
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
                                <AlertCircle className="w-4 h-4 shrink-0" />
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

            {/* Contact Information */}
            {showContact && (
                <div className="card bg-base-100 shadow-md">
                    <div className="card-body">
                        <div className="flex items-center gap-3 mb-3">
                            <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center shrink-0">
                                <Mail className="w-5 h-5 text-primary" />
                            </div>
                            <h2 className="card-title text-lg">14. Contact Information</h2>
                        </div>
                        <p className="text-base-content/80 leading-relaxed ml-1">
                            For any questions regarding these Terms, please contact:
                        </p>
                        <div className="ml-1 mt-2 space-y-1">
                            <p className="text-base-content/80">📧 harihara1869@gmail.com</p>
                            <p className="text-base-content/80">Location: India</p>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};