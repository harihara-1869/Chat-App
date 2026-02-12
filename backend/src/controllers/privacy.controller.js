import User from "../models/user.model.js";

/**
 * GET /api/privacy-policy/status
 * Returns the privacy policy acceptance status for the authenticated user.
 */
export const getPrivacyPolicyStatus = async (req, res) => {
    try {
        const user = await User.findById(req.user._id).select(
            "privacyPolicyAccepted privacyPolicyAcceptedAt"
        );

        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        return res.status(200).json({
            accepted: user.privacyPolicyAccepted,
            acceptedAt: user.privacyPolicyAcceptedAt || null,
        });
    } catch (error) {
        console.error("Error fetching privacy policy status:", error);
        return res.status(500).json({ message: "Internal server error" });
    }
};

/**
 * POST /api/privacy-policy/accept
 * Accepts the privacy policy for the authenticated user.
 * Expects { accepted: true } in the request body.
 */
export const acceptPrivacyPolicy = async (req, res) => {
    try {
        const { accepted } = req.body;

        if (accepted !== true) {
            return res.status(400).json({
                message: "You must accept the privacy policy. Send { accepted: true }.",
            });
        }

        const user = await User.findByIdAndUpdate(
            req.user._id,
            {
                privacyPolicyAccepted: true,
                privacyPolicyAcceptedAt: new Date(),
            },
            { new: true }
        ).select("privacyPolicyAccepted privacyPolicyAcceptedAt");

        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        return res.status(200).json({
            message: "Privacy policy accepted successfully",
            accepted: user.privacyPolicyAccepted,
            acceptedAt: user.privacyPolicyAcceptedAt,
        });
    } catch (error) {
        console.error("Error accepting privacy policy:", error);
        return res.status(500).json({ message: "Internal server error" });
    }
};
