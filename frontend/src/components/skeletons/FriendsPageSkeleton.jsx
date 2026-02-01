/**
 * FriendsPageSkeleton - Skeleton loaders for the friends page
 */

// Skeleton for friend/user list items
export const UserCardSkeleton = () => {
    return (
        <div className="flex items-center gap-3 p-3">
            {/* Avatar skeleton */}
            <div className="skeleton size-12 rounded-full shrink-0" />

            {/* User info skeleton */}
            <div className="flex-1 min-w-0">
                <div className="skeleton h-4 w-32 mb-2" />
                <div className="skeleton h-3 w-20" />
            </div>
        </div>
    );
};

// Skeleton for friend request items (with action buttons)
export const RequestCardSkeleton = () => {
    return (
        <div className="flex items-center gap-3 p-3">
            {/* Avatar skeleton */}
            <div className="skeleton size-12 rounded-full shrink-0" />

            {/* User info skeleton */}
            <div className="flex-1 min-w-0">
                <div className="skeleton h-4 w-32 mb-2" />
                <div className="skeleton h-3 w-40" />
            </div>

            {/* Action buttons skeleton */}
            <div className="flex gap-2">
                <div className="skeleton size-8 rounded-lg" />
                <div className="skeleton size-8 rounded-lg" />
            </div>
        </div>
    );
};

// Full skeleton for "My Friends" tab
export const FriendsListSkeleton = () => {
    const skeletonItems = Array(6).fill(null);

    return (
        <div className="flex-1 flex flex-col p-4 overflow-y-auto">
            {skeletonItems.map((_, idx) => (
                <UserCardSkeleton key={idx} />
            ))}
        </div>
    );
};

// Full skeleton for "Requests" tab
export const RequestsListSkeleton = () => {
    const skeletonItems = Array(3).fill(null);

    return (
        <div className="flex-1 flex flex-col p-4 overflow-y-auto">
            {skeletonItems.map((_, idx) => (
                <RequestCardSkeleton key={idx} />
            ))}
        </div>
    );
};

// Skeleton for search results
export const SearchResultsSkeleton = () => {
    const skeletonItems = Array(4).fill(null);

    return (
        <div className="overflow-y-auto flex-1">
            {skeletonItems.map((_, idx) => (
                <div key={idx} className="flex items-center gap-3 p-3">
                    {/* Avatar skeleton */}
                    <div className="skeleton size-12 rounded-full shrink-0" />

                    {/* User info skeleton */}
                    <div className="flex-1 min-w-0">
                        <div className="skeleton h-4 w-32" />
                    </div>

                    {/* Add button skeleton */}
                    <div className="skeleton h-8 w-16 rounded-lg" />
                </div>
            ))}
        </div>
    );
};
