# MyApp - Work In Progress

> A modular, minimalistic personal & collaborative life management app

## Vision

A single app that consolidates fragmented daily tools (notes, expenses, recipes, media tracking, photo sharing) into one cohesive experience. Users create **Spaces** - customizable modules that can be personal or shared with groups.

---

## Core Concepts

### 1. Spaces (formerly "Tabs")

A **Space** is a customizable container for a specific purpose. Instead of hardcoded features, users create Spaces from templates:

| Template | Description |
|----------|-------------|
| **Recipe Book** | Store recipes with smart ingredient scaling, media attachments |
| **Expense Tracker** | Track spending by category, trip, or event |
| **Photo Album** | Shared photo collections with comments |
| **Media Tracker** | Track movies, series, books with progress & ratings |
| **Notes** | Simple markdown notes or checklists |
| **Custom** | Build your own with available field types |

### 2. Collaboration Model

Every Space can be:
- **Private** - Only you
- **Shared** - Invite specific people (view or edit permissions)
- **Group** - Belongs to a Group, all members have access

### 3. Groups

Groups are collections of people (like Telegram/WhatsApp groups):
- Create a group, invite members
- Attach Spaces to groups
- Group chat for coordination
- Role-based permissions (admin, editor, viewer)

---

## Feature Breakdown

### Phase 1: Foundation

#### Authentication
- [X] Email/password login
- [ ] Google Sign-In
- [ ] Apple Sign-In (iOS)
- [ ] Password reset flow
- [ ] Profile management (avatar, display name)

#### Core Navigation
- [ ] Bottom navigation with dynamic Space tabs
- [ ] Space creation wizard
- [ ] Space settings (rename, archive, delete)
- [ ] Reorder Spaces via drag-and-drop

#### Data Architecture
- [ ] Offline-first with local SQLite/Hive cache
- [ ] Supabase real-time sync
- [ ] Conflict resolution for collaborative edits
- [ ] Optimistic UI updates

---

### Phase 2: Space Templates

#### Recipe Book
- [ ] Recipe card: title, description, prep time, cook time, servings
- [ ] Ingredients list with quantities and units
- [ ] **Smart scaling**: adjust servings, auto-recalculate quantities
- [ ] Step-by-step instructions
- [ ] Media attachments:
  - [ ] Photos (multiple per recipe)
  - [ ] Video links (YouTube, Vimeo) with in-app playback
  - [ ] Uploaded video clips
- [ ] Categories/tags for organization
- [ ] Search and filter
- [ ] Favorites
- [ ] Shopping list generation from selected recipes

#### Expense Tracker
- [ ] Expense entry: amount, category, date, notes, receipt photo
- [ ] **Trip/Event mode**: group expenses under a context (e.g., "Italy Trip 2025")
- [ ] Budget setting per category or trip
- [ ] Visual reports: pie charts, bar graphs, trends
- [ ] Currency support with conversion
- [ ] Split expenses (for shared Spaces)
- [ ] Export to CSV/PDF

#### Photo Album
- [ ] Create albums within the Space
- [ ] Upload photos with compression options
- [ ] Captions and comments per photo
- [ ] Slideshow view
- [ ] Download originals
- [ ] Timeline view

#### Media Tracker
- [ ] Track: Movies, TV Series, Books, Games, Podcasts
- [ ] Status: Want to watch/read, In progress, Completed, Dropped
- [ ] Rating (1-10 or 5 stars)
- [ ] Notes/review
- [ ] Progress tracking (episode X of Y, page X of Y)
- [ ] Integration with external APIs (TMDB, OpenLibrary) for metadata
- [ ] Recommendations based on history (future)

#### Notes
- [ ] Markdown support
- [ ] Checklists with completion tracking
- [ ] Pin important notes
- [ ] Search within notes
- [ ] Tags

#### Custom Space Builder
- [ ] Select field types:
  - Text (short, long)
  - Number (integer, decimal, currency)
  - Date / DateTime
  - Checkbox / Toggle
  - Dropdown (predefined options)
  - Rating
  - Media (photo, video, link)
  - Location
- [ ] Define card layout
- [ ] Set required vs optional fields
- [ ] Choose list vs grid view

---

### Phase 3: Collaboration

#### Groups
- [ ] Create group with name and avatar
- [ ] Invite via link or username search
- [ ] Member management (remove, change role)
- [ ] Roles: Owner, Admin, Member
- [ ] Leave group

#### Shared Spaces
- [ ] Share personal Space with specific users
- [ ] Permission levels: View only, Can edit, Can manage
- [ ] Activity log (who changed what, when)
- [ ] Transfer ownership

#### Real-time Sync
- [ ] Live updates when collaborators make changes
- [ ] Presence indicators (who's viewing/editing)
- [ ] Typing indicators in chat

#### Messaging
- [ ] Group chat per Group
- [ ] Optional chat per Space
- [ ] Message types: text, photo, voice note
- [ ] Reply and reactions
- [ ] Push notifications

---

### Phase 4: Social & Discovery

#### Contacts / Friends
- [ ] Add friends by username or phone number
- [ ] Friend requests with accept/decline
- [ ] Direct messaging (1:1 chat)
- [ ] See friends' public Spaces (if they share)
- [ ] Quick share to friend

#### Public Spaces (Optional)
- [ ] Publish a Space as public (e.g., share your recipe book)
- [ ] Browse community Spaces
- [ ] Clone public Space to your account
- [ ] Like and comment

---

### Phase 5: Polish & Advanced

#### Notifications
- [ ] Push notifications for:
  - New messages
  - Space updates (when shared)
  - Friend requests
  - Reminders (if set)
- [ ] In-app notification center
- [ ] Notification preferences per Space

#### Search & Organization
- [ ] Global search across all Spaces
- [ ] Tags system
- [ ] Archive old Spaces
- [ ] Trash with 30-day recovery

#### Settings
- [ ] Theme: Light, Dark, System
- [ ] Accent color picker
- [ ] Language selection
- [ ] Data export (all your data as JSON/ZIP)
- [ ] Account deletion

#### Performance & UX
- [ ] Skeleton loaders
- [ ] Pull-to-refresh
- [ ] Infinite scroll with pagination
- [ ] Image caching and lazy loading
- [ ] Haptic feedback

---

## Technical Architecture

### Frontend (Flutter)

```
lib/
├── core/
│   ├── config/          # App configuration, environment
│   ├── theme/           # ThemeData, colors, typography
│   ├── router/          # GoRouter navigation
│   └── utils/           # Helpers, extensions
├── data/
│   ├── models/          # Data classes (User, Space, Recipe, etc.)
│   ├── repositories/    # Data access layer
│   ├── providers/       # Supabase, local storage providers
│   └── services/        # Business logic services
├── features/
│   ├── auth/
│   ├── spaces/
│   ├── recipes/
│   ├── expenses/
│   ├── photos/
│   ├── media_tracker/
│   ├── groups/
│   ├── chat/
│   └── settings/
└── shared/
    ├── widgets/         # Reusable UI components
    └── layouts/         # Common screen layouts
```

### Backend (Supabase)

#### Tables

```sql
-- Users (extends Supabase auth.users)
profiles
  - id (uuid, FK to auth.users)
  - username (unique)
  - display_name
  - avatar_url
  - created_at

-- Spaces
spaces
  - id (uuid)
  - owner_id (uuid, FK to profiles)
  - type (enum: recipe, expense, photo, media, notes, custom)
  - name
  - icon
  - config (jsonb - template-specific settings)
  - is_archived
  - created_at
  - updated_at

-- Space content varies by type, stored in dedicated tables
recipes, expenses, photos, media_items, notes

-- Collaboration
groups
  - id
  - name
  - avatar_url
  - created_by
  - created_at

group_members
  - group_id
  - user_id
  - role (owner, admin, member)
  - joined_at

space_shares
  - space_id
  - shared_with_user_id (nullable)
  - shared_with_group_id (nullable)
  - permission (view, edit, manage)

-- Messaging
messages
  - id
  - conversation_id
  - sender_id
  - content
  - message_type
  - created_at

conversations
  - id
  - type (direct, group, space)
  - reference_id (group_id or space_id if applicable)
```

#### Security
- Row Level Security (RLS) on all tables
- Users can only access their own data or shared content
- Real-time subscriptions respect RLS

#### Storage Buckets
- `avatars` - Profile pictures
- `space-media` - Photos, videos, receipts
- Public/private access based on Space sharing settings

---

## Design Principles

1. **Minimalist UI**: Clean, uncluttered. Content first.
2. **Progressive disclosure**: Show basics, reveal advanced on demand.
3. **Offline-capable**: Core features work without internet.
4. **Fast**: Optimistic updates, lazy loading, efficient queries.
5. **Accessible**: Support screen readers, dynamic text sizes.

---

## Milestones

### MVP (v0.1)
- [ ] Auth (email + Google)
- [ ] Create/manage personal Spaces
- [ ] Recipe Book template (full features)
- [ ] Basic offline support

### v0.2 - Expenses & Media
- [ ] Expense Tracker template
- [ ] Media Tracker template
- [ ] Improved search

### v0.3 - Collaboration
- [ ] Groups
- [ ] Space sharing
- [ ] Real-time sync

### v0.4 - Communication
- [ ] Group chat
- [ ] Direct messages
- [ ] Push notifications

### v0.5 - Customization
- [ ] Custom Space builder
- [ ] Themes
- [ ] Public Spaces

---

## Open Questions

1. **Monetization**: Free with limits? Premium subscription? What features are premium?
2. **Data limits**: Max photos per album? Max Spaces per user?
3. **Moderation**: How to handle public Spaces? Report system?
4. **Integrations**: Calendar sync? Import from other apps?

---

## References

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Material 3 Design](https://m3.material.io/)

---

*Last updated: January 2026*
