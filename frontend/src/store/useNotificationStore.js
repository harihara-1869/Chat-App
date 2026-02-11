import { create } from "zustand";
import { useChatStore } from "./useChatStore";
import { useFriendStore } from "./useFriendStore";

export const useNotificationStore = create((set, get) => ({
    permission: typeof Notification !== "undefined" ? Notification.permission : "denied",

    requestPermission: async () => {
        if (typeof Notification === "undefined") return;
        if (Notification.permission !== "granted") {
            const permission = await Notification.requestPermission();
            set({ permission });
        }
    },

    notifyIfNeeded: (message) => {
        if (typeof Notification === "undefined") return;

        const { permission } = get();
        if (permission !== "granted") return;

        // Look up the sender's name from the friends list
        const friends = useFriendStore.getState().friends;
        const sender = friends.find((f) => f._id === message.senderId);
        const senderName = sender?.fullName || "New message";

        const notification = new Notification(senderName, {
            body: message.text || "Sent an image",
            icon: sender?.profilePic || "/avatar.png",
            tag: message.senderId,
        });

        notification.onclick = () => {
            window.focus();

            // Open the correct chat
            const chatStore = useChatStore.getState();
            if (sender) {
                chatStore.setSelectedUser(sender);
            } else {
                chatStore.setSelectedUser({
                    _id: message.senderId,
                    fullName: senderName,
                });
            }

            notification.close();
        };
    },

    showNotification: ({ title, body, icon, tag, onClick }) => {
        if (typeof Notification === "undefined") return;

        const { permission } = get();
        if (permission !== "granted") return;

        const notification = new Notification(title, {
            body,
            icon: icon || "/avatar.png",
            tag: tag || undefined,
        });

        notification.onclick = () => {
            window.focus();
            if (onClick) onClick();
            notification.close();
        };
    },
}));
