import { useEffect, useState } from "react";
import { useFriendStore } from "../store/useFriendStore";
import { useAuthStore } from "../store/useAuthStore";
import { Users, Search, UserPlus, Check, X } from "lucide-react";
import { FriendsListSkeleton, RequestsListSkeleton, SearchResultsSkeleton } from "../components/skeletons/FriendsPageSkeleton";

export const FriendsPage = () => {
    const {
        friends,
        searchResults,
        pendingRequests,
        isLoading,
        isSearching,
        getFriends,
        searchUsers,
        clearSearch,
        sendFriendRequest,
        getPendingRequests,
        acceptRequest,
        rejectRequest,
    } = useFriendStore();
    const { onlineUsers } = useAuthStore();

    const [searchQuery, setSearchQuery] = useState("");
    const [activeTab, setActiveTab] = useState("friends"); // friends, search, requests

    useEffect(() => {
        getFriends();
        getPendingRequests();
    }, [getFriends, getPendingRequests]);

    useEffect(() => {
        const delayDebounce = setTimeout(() => {
            if (searchQuery.length >= 3) {
                searchUsers(searchQuery);
            } else {
                clearSearch();
            }
        }, 300);
        return () => clearTimeout(delayDebounce);
    }, [searchQuery, searchUsers, clearSearch]);

    return (
        <div className="h-screen bg-base-200">
            <div className="flex items-center justify-center pt-20 px-4">
                <div className="bg-base-100 rounded-lg shadow-cl w-full max-w-6xl h-[calc(100vh-8rem)]">
                    <div className="flex h-full rounded-lg overflow-hidden">
                        {/* Left Panel - Tabs */}
                        <aside className="h-full w-20 lg:w-72 border-r border-base-300 flex flex-col transition-all duration-200">
                            <div className="border-b border-base-300 w-full p-5">
                                <div className="flex items-center gap-2">
                                    <Users className="size-6" />
                                    <span className="font-medium hidden lg:block">Friends</span>
                                </div>
                            </div>

                            {/* Tab Buttons */}
                            <div className="flex flex-col p-2 gap-1">
                                <button
                                    onClick={() => setActiveTab("friends")}
                                    className={`btn btn-sm justify-start gap-2 ${activeTab === "friends" ? "btn-primary" : "btn-ghost"}`}
                                >
                                    <Users className="size-4" />
                                    <span className="hidden lg:inline">My Friends</span>
                                    <span className="hidden lg:inline badge badge-sm">{friends.length}</span>
                                </button>
                                <button
                                    onClick={() => setActiveTab("search")}
                                    className={`btn btn-sm justify-start gap-2 ${activeTab === "search" ? "btn-primary" : "btn-ghost"}`}
                                >
                                    <Search className="size-4" />
                                    <span className="hidden lg:inline">Find Users</span>
                                </button>
                                <button
                                    onClick={() => setActiveTab("requests")}
                                    className={`btn btn-sm justify-start gap-2 ${activeTab === "requests" ? "btn-primary" : "btn-ghost"}`}
                                >
                                    <UserPlus className="size-4" />
                                    <span className="hidden lg:inline">Requests</span>
                                    {pendingRequests.length > 0 && (
                                        <span className="badge badge-sm badge-error">{pendingRequests.length}</span>
                                    )}
                                </button>
                            </div>
                        </aside>

                        {/* Right Panel - Content */}
                        <div className="flex-1 flex flex-col overflow-hidden">
                            {/* Search Tab */}
                            {activeTab === "search" && (
                                <div className="flex-1 flex flex-col p-4">
                                    <div className="mb-4">
                                        <div className="relative">
                                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-5 text-base-content/40" />
                                            <input
                                                type="text"
                                                placeholder="Search by name or email (min 3 chars)..."
                                                className="input input-bordered w-full pl-10"
                                                value={searchQuery}
                                                onChange={(e) => setSearchQuery(e.target.value)}
                                            />
                                        </div>
                                    </div>

                                    <div className="overflow-y-auto flex-1">
                                        {isSearching && <SearchResultsSkeleton />}

                                        {!isSearching && searchResults.length === 0 && searchQuery.length >= 3 && (
                                            <div className="text-center text-zinc-500 py-8">No users found</div>
                                        )}

                                        {!isSearching && searchQuery.length < 3 && (
                                            <div className="text-center text-zinc-500 py-8">
                                                Enter at least 3 characters to search
                                            </div>
                                        )}

                                        {searchResults.map((user) => (
                                            <div
                                                key={user._id}
                                                className="flex items-center gap-3 p-3 hover:bg-base-300 rounded-lg transition-colors"
                                            >
                                                <div className="relative">
                                                    <img
                                                        src={user.profilePic || "/avatar.png"}
                                                        alt={user.fullName}
                                                        className="size-12 object-cover rounded-full"
                                                    />
                                                    {onlineUsers.includes(user._id) && (
                                                        <span className="absolute bottom-0 right-0 size-3 bg-green-500 rounded-full ring-2 ring-base-100" />
                                                    )}
                                                </div>
                                                <div className="flex-1 min-w-0">
                                                    <div className="font-medium truncate">{user.fullName}</div>
                                                </div>
                                                <button
                                                    onClick={() => sendFriendRequest(user._id)}
                                                    className="btn btn-sm btn-primary gap-1"
                                                >
                                                    <UserPlus className="size-4" />
                                                    <span className="hidden sm:inline">Add</span>
                                                </button>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            )}

                            {/* Friends Tab */}
                            {activeTab === "friends" && (
                                <div className="flex-1 flex flex-col p-4 overflow-y-auto">
                                    {/* {isLoading && <FriendsListSkeleton />} */}

                                    {!isLoading && friends.length === 0 && (
                                        <div className="text-center text-zinc-500 py-8">
                                            No friends yet. Search for users to add them!
                                        </div>
                                    )}

                                    {friends.map((friend) => (
                                        <div
                                            key={friend._id}
                                            className="flex items-center gap-3 p-3 hover:bg-base-300 rounded-lg transition-colors"
                                        >
                                            <div className="relative">
                                                <img
                                                    src={friend.profilePic || "/avatar.png"}
                                                    alt={friend.fullName}
                                                    className="size-12 object-cover rounded-full"
                                                />
                                                {onlineUsers.includes(friend._id) && (
                                                    <span className="absolute bottom-0 right-0 size-3 bg-green-500 rounded-full ring-2 ring-base-100" />
                                                )}
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <div className="font-medium truncate">{friend.fullName}</div>
                                                <div className="text-sm text-zinc-400">
                                                    {onlineUsers.includes(friend._id) ? "Online" : "Offline"}
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}

                            {/* Requests Tab */}
                            {activeTab === "requests" && (
                                <div className="flex-1 flex flex-col p-4 overflow-y-auto">
                                    {pendingRequests.length === 0 && (
                                        <div className="text-center text-zinc-500 py-8">
                                            No pending friend requests
                                        </div>
                                    )}

                                    {pendingRequests.map((request) => (
                                        <div
                                            key={request._id}
                                            className="flex items-center gap-3 p-3 hover:bg-base-300 rounded-lg transition-colors"
                                        >
                                            <div className="relative">
                                                <img
                                                    src={request.senderId?.profilePic || "/avatar.png"}
                                                    alt={request.senderId?.fullName}
                                                    className="size-12 object-cover rounded-full"
                                                />
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <div className="font-medium truncate">{request.senderId?.fullName}</div>
                                                <div className="text-sm text-zinc-400">{request.senderId?.email}</div>
                                            </div>
                                            <div className="flex gap-2">
                                                <button
                                                    onClick={() => acceptRequest(request._id)}
                                                    className="btn btn-sm btn-success gap-1"
                                                >
                                                    <Check className="size-4" />
                                                </button>
                                                <button
                                                    onClick={() => rejectRequest(request._id)}
                                                    className="btn btn-sm btn-error gap-1"
                                                >
                                                    <X className="size-4" />
                                                </button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};
