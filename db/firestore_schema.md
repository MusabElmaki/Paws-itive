# Firestore Schema

All collections are limited to the UTM stray cat ecosystem. No support is included for other campuses or non-cat animals.

## `users`
- `email`: string
- `fullName`: string
- `role`: `user | volunteer | admin`
- `status`: `active | pending | suspended`
- `phoneNumber`: string | null
- `photoUrl`: string | null
- `bio`: string
- `points`: number
- `isApprovedVolunteer`: bool
- `isSuspended`: bool
- `pushToken`: string | null
- `createdAt`: timestamp

## `volunteers`
- `userId`: string
- `approvalStatus`: `pending | approved | rejected`
- `role`: `volunteer`
- `createdAt`: timestamp
- `reviewedBy`: string | null
- `notes`: string | null

## `admins`
- `userId`: string
- `role`: `admin`
- `createdAt`: timestamp

## `cats`
- `name`: string | null
- `photoUrls`: array<string>
- `currentLocationName`: string
- `latitude`: number | null
- `longitude`: number | null
- `healthStatus`: `unknown | healthy | injured | sick | recovering | critical`
- `classification`: `stray | domestic`
- `feedingHistory`: array<string>
- `volunteerNotes`: array<string>
- `medicalNotes`: array<string>
- `reportIds`: array<string>
- `imageSignature`: array<number>
- `currentStatus`: `reported | underReview | beingAssisted | resolved`
- `lastUpdated`: timestamp
- `matchedReportId`: string | null

## `reports`
- `reporterId`: string
- `reporterName`: string
- `catId`: string | null
- `photoUrl`: string
- `locationName`: string
- `latitude`: number | null
- `longitude`: number | null
- `description`: string
- `status`: `reported | underReview | beingAssisted | resolved`
- `imageSignature`: array<number>
- `duplicateMessage`: string
- `duplicateConfidence`: number
- `assignedVolunteerId`: string | null
- `analysisLabel`: string
- `analysisConfidence`: number
- `createdAt`: timestamp
- `updatedAt`: timestamp

## `notifications`
- `title`: string
- `body`: string
- `targetUserId`: string | null
- `type`: string
- `actionPath`: string | null
- `read`: bool
- `createdAt`: timestamp

## `donations`
- `userId`: string
- `amount`: number
- `source`: string
- `createdAt`: timestamp

## `shop_items`
- `name`: string
- `price`: number
- `category`: string
- `description`: string
- `imageUrl`: string | null
- `active`: bool

## `orders`
- `userId`: string
- `items`: array<object>
- `total`: number
- `status`: string
- `createdAt`: timestamp

## `leaderboard`
- `name`: string
- `points`: number
- `weeklyPoints`: number
- `monthlyPoints`: number
- `casesClosed`: number
- `healthUpdates`: number
- `feedingUpdates`: number

## `clinics`
- `name`: string
- `address`: string
- `latitude`: number
- `longitude`: number
- `phone`: string | null
- `emergency`: bool

## `fund_requests`
- `catId`: string
- `requestedBy`: string
- `amount`: number
- `reason`: string
- `status`: `pending | approved | rejected`
- `reviewedBy`: string | null
- `reviewNote`: string | null
- `createdAt`: timestamp