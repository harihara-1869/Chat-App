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
    Cloud,
    Globe,
    Baby,
    RefreshCw,
} from "lucide-react";

export const PrivacyPolicyContent = ({ showContact = true }) => {
    const sections = [
        {
            icon: <Eye className="w-5 h-5 text-primary" />,
            title: "1. Information We Collect",
            intro: "We may collect the following categories of information:",
            subsections: [
                {
                    title: "1.1 Account Information",
                    bullets: [
                        "Name",
                        "Email address",
                        "Profile picture (if provided)",
                        "Authentication provider information (e.g., Google ID)",
                    ],
                },
                {
                    title: "1.2 Communication Data",
                    bullets: [
                        "Messages sent through the Platform",
                        "Images uploaded by users",
                    ],
                    warning: "Messages are stored in plain text format and are not end-to-end encrypted.",
                },
                {
                    title: "1.3 Technical Information",
                    bullets: [
                        "IP address",
                        "Browser type",
                        "Device information",
                        "Basic usage logs",
                    ],
                    note: "This information may be automatically collected for security and operational purposes.",
                },
            ],
        },
        {
            icon: <Target className="w-5 h-5 text-primary" />,
            title: "2. How We Use Your Information",
            intro: "We use collected information to:",
            bullets: [
                "Create and manage user accounts",
                "Enable messaging functionality",
                "Store and display uploaded images",
                "Maintain platform security",
                "Monitor technical performance",
                "Comply with legal obligations",
            ],
            note: "We do not sell, rent, or commercially trade your personal data.",
        },
        {
            icon: <Cloud className="w-5 h-5 text-primary" />,
            title: "3. Image Hosting and Third-Party Services",
            paragraphs: [
                "Uploaded images may be stored using third-party cloud storage providers such as Cloudinary.",
            ],
            intro2: "Images:",
            bullets: [
                "May be accessible via publicly accessible URLs",
                "Are subject to the third-party provider's infrastructure and policies",
            ],
            warning: "We are not responsible for the independent privacy practices of third-party services. Users are advised not to upload sensitive or confidential content.",
        },
        {
            icon: <Lock className="w-5 h-5 text-primary" />,
            title: "4. Data Storage and Security",
            intro: "We implement reasonable technical and organizational safeguards to protect user information.",
            intro2: "However:",
            bullets: [
                "Messages are stored in plain text",
                "Internet transmission carries inherent risks",
                "No system can guarantee absolute security",
            ],
            warning: "Users should avoid sharing highly sensitive personal information through the Platform.",
        },
        {
            icon: <Users className="w-5 h-5 text-primary" />,
            title: "5. Data Sharing",
            intro: "We may share information only in the following situations:",
            bullets: [
                "With hosting or infrastructure providers strictly for service operation",
                "When required by law, court order, or governmental authority",
                "To protect the rights, safety, or integrity of the Platform",
            ],
            note: "We do not intentionally disclose personal data to unrelated third parties for marketing or advertising.",
        },
        {
            icon: <Database className="w-5 h-5 text-primary" />,
            title: "6. Data Retention",
            intro: "We retain personal data:",
            bullets: [
                "For as long as your account remains active",
                "For operational, security, or legal purposes",
            ],
            warning: "As this is a demo application, data may be deleted, reset, or removed at any time without prior notice. Users may request deletion of their account by contacting us.",
        },
        {
            icon: <Scale className="w-5 h-5 text-primary" />,
            title: "7. Your Rights (Under Indian Law)",
            intro: "In accordance with applicable Indian data protection principles, including the Digital Personal Data Protection Act, 2023, you may have the right to:",
            bullets: [
                "Request access to your personal data",
                "Request correction of inaccurate information",
                "Request deletion of your personal data",
                "Withdraw consent for data processing",
            ],
            note: "Requests may be sent to: harihara1869@gmail.com - We will respond within a reasonable time.",
        },
        {
            icon: <Baby className="w-5 h-5 text-primary" />,
            title: "8. Children's Privacy",
            paragraphs: [
                "This Platform is not intended for individuals under 18 years of age.",
                "We do not knowingly collect personal data from minors.",
                "If we become aware that a minor has provided personal information, we may delete such data.",
            ],
        },
        {
            icon: <Globe className="w-5 h-5 text-primary" />,
            title: "9. International Data Transfers",
            paragraphs: [
                "If third-party infrastructure providers store data outside India, your data may be transferred to and processed in other jurisdictions.",
                "By using the Platform, you consent to such transfers where necessary for service operation.",
            ],
        },
        {
            icon: <AlertTriangle className="w-5 h-5 text-warning" />,
            title: "10. Disclaimer (Demo Nature)",
            intro: "This Platform is a demo and portfolio project.",
            intro2: "It is not intended for production-grade confidential communications.",
            intro3: "Users acknowledge that:",
            bullets: [
                "Security features may be limited",
                "The Platform may be modified or discontinued at any time",
                "Data may be deleted as part of development or maintenance",
            ],
        },
        {
            icon: <RefreshCw className="w-5 h-5 text-primary" />,
            title: "11. Changes to This Policy",
            paragraphs: [
                "We may update this Privacy Policy at any time.",
                "Continued use of the Platform after changes constitutes acceptance of the revised Policy.",
            ],
        },
    ];

    return (
        <div className="space-y-4">
            {/* Header */}
            <div className="flex items-center gap-3 mb-3">
                <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                    <Shield className="w-6 h-6 text-primary" />
                </div>
                <div>
                    <h1 className="text-2xl font-bold">Privacy Policy</h1>
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
                        <h2 className="card-title text-lg">Introduction</h2>
                    </div>
                    <p className="text-base-content/80 leading-relaxed ml-1">
                        This Privacy Policy describes how Talkio ("Platform", "we", "our", or "us")
                        collects, uses, and protects your information.
                    </p>
                    <p className="text-base-content/80 leading-relaxed ml-1 mt-2">
                        The Platform is operated by P R Hari Hara Sai Pratham, located in India.
                    </p>
                    <p className="text-base-content/80 leading-relaxed ml-1 mt-2">
                        This Platform is a demo and portfolio project developed for demonstration
                        and educational purposes.
                    </p>
                    <p className="text-base-content/80 leading-relaxed ml-1 mt-2 font-medium">
                        By using the Platform, you agree to this Privacy Policy.
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

                                    {subsection.intro && (
                                        <p className="text-base-content/80 leading-relaxed mb-2">
                                            {subsection.intro}
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

                                    {subsection.warning && (
                                        <div className="alert alert-warning mt-3 text-sm">
                                            <AlertTriangle className="w-4 h-4 shrink-0" />
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

            {/* Contact Information */}
            {showContact && (
                <div className="card bg-base-100 shadow-md">
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
                            <p className="text-base-content/80">📧 harihara1869@gmail.com</p>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};