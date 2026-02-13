import { Link } from "react-router-dom";
import { ArrowLeft } from "lucide-react";
import { TermsAndConditionsContent } from "../components/TermsAndConditionsContent";

export const TermsAndConditionsPage = () => {
    return (
        <div className="min-h-screen bg-base-200 pt-20">
            <div className="container mx-auto px-4 py-8 max-w-4xl">
                {/* Back Button */}
                <div className="mb-8">
                    <Link
                        to="/"
                        className="btn btn-ghost btn-sm gap-2 mb-4 text-base-content/70 hover:text-base-content"
                    >
                        <ArrowLeft className="w-4 h-4" />
                        Back
                    </Link>
                </div>

                {/* Terms and Conditions Content */}
                <TermsAndConditionsContent showContact={true} />

                {/* Footer */}
                <div className="text-center text-base-content/50 text-sm py-8">
                    <p>© 2026 — All rights reserved.</p>
                </div>
            </div>
        </div>
    );
};