// Production data model plan
// users/{uid}: name, username, avatarUrl, bio, createdAt
// posts/{postId}: uid, type(text/photo/video/audio), text, mediaUrl, createdAt, likesCount, commentsCount
// posts/{postId}/likes/{uid}
// posts/{postId}/comments/{commentId}
// users/{uid}/following/{otherUid}
// users/{uid}/followers/{otherUid}
// reports/{reportId}: reporterUid, targetId, reason, createdAt
