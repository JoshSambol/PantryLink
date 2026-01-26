# Volunteer Scheduling System & User Management

Implemented volunteer scheduling across iOS and React with username tracking, duplicate prevention, and pantry-side configuration options.

## Changes

- Added iOS volunteer schedule views (browse pantries, view/manage shifts, directions to pantries)
- Added React dashboard settings for volunteer scheduling (open days, excluded dates, scheduling modes)
- Implemented username uniqueness validation for user and pantry accounts (returns 409 error)
- Added volunteer duplicate checking to prevent multiple registrations with same username
- Created new backend routes for schedule settings and volunteer checking
- Fixed username field in volunteer registration (autofilled and locked for logged-in users)
- Enhanced CORS configuration and fixed React component initialization bugs
