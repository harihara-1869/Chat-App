import { useAuthStore } from "../store/useAuthStore";
import { useChatStore } from "../store/useChatStore";
import { useFriendStore } from "../store/useFriendStore";
import { useNotificationStore } from "../store/useNotificationStore";
import toast from "react-hot-toast";

export function initSocketListeners() {
    const socket = useAuthStore.getState().socket;
    if (!socket) return;

    // Always clean up first so this is safe to call multiple times (HMR, reconnect)
    cleanupSocketListeners();

    // --- Online users ---
    socket.on("getOnlineUsers", (userIds) => {
        useAuthStore.setState({ onlineUsers: userIds });
    });

    // --- New message ---
    socket.on("newMessage", (message) => {
        handleIncomingMessage(message);
    });

    // --- Friend request received ---
    socket.on("newFriendRequest", (request) => {
        const friendStore = useFriendStore.getState();
        useFriendStore.setState({
            pendingRequests: [...friendStore.pendingRequests, request],
        });
        const senderName = request.senderId?.fullName || "Someone";

        if (document.visibilityState === "visible") {
            toast.success(`${senderName} sent you a friend request!`);
        } else {
            const notificationStore = useNotificationStore.getState();
            notificationStore.showNotification({
                title: "Friend Request",
                body: `${senderName} sent you a friend request!`,
                icon: request.senderId?.profilePic || "/avatar.png",
                tag: `friend-request-${request._id}`,
            });
        }
    });

    // --- Friend request accepted ---
    socket.on("friendRequestAccepted", ({ friend }) => {
        const friendStore = useFriendStore.getState();
        useFriendStore.setState({
            friends: [...friendStore.friends, friend],
        });

        if (document.visibilityState === "visible") {
            toast.success(`${friend.fullName} is now your friend!`);
        } else {
            const notificationStore = useNotificationStore.getState();
            notificationStore.showNotification({
                title: "Friend Request Accepted",
                body: `${friend.fullName} is now your friend!`,
                icon: friend.profilePic || "/avatar.png",
                tag: `friend-accepted-${friend._id}`,
            });
        }
    });
}

export function cleanupSocketListeners() {
    const socket = useAuthStore.getState().socket;
    if (socket) {
        socket.off("getOnlineUsers");
        socket.off("newMessage");
        socket.off("newFriendRequest");
        socket.off("friendRequestAccepted");
    }
}

function handleIncomingMessage(message) {
    const chatStore = useChatStore.getState();
    const authStore = useAuthStore.getState();

    const currentUserId = authStore.authUser?._id;
    if (!currentUserId) return;

    const isOwnMessage = message.senderId === currentUserId;

    // Determine who the other participant is
    const otherUserId = isOwnMessage ? message.receiverId : message.senderId;

    const selectedUser = chatStore.selectedUser;

    // The chat is only truly "active" if: ChatContainer is mounted,
    // the right chat is selected, AND the tab is visible
    const isChatOpenAndVisible =
        chatStore.isChatOpen &&
        selectedUser &&
        selectedUser._id === otherUserId &&
        document.visibilityState === "visible";

    // Always append to the message list if the chat is open for this user
    if (chatStore.isChatOpen && selectedUser && selectedUser._id === otherUserId) {
        chatStore.addMessage(message);
    }

    // Notify for all incoming messages (not own) UNLESS the user is
    // actively viewing that exact chat in a visible tab
    if (!isOwnMessage && !isChatOpenAndVisible) {
        if (document.visibilityState === "visible") {
            // Tab is visible but this chat isn't open — show a toast
            const friends = useFriendStore.getState().friends;
            const sender = friends.find((f) => f._id === message.senderId);
            const senderName = sender?.fullName || "New message";
            toast(message.text || "Sent an image", {
                icon: "💬",
                duration: 3000,
            });
        } else {
            // Tab is hidden — show browser notification
            const notificationStore = useNotificationStore.getState();
            notificationStore.notifyIfNeeded(message);
        }
    }
}
