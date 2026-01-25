# MyApp - Flutter Project Guide

> Personal life management app with modular "Spaces" for recipes, expenses, photos, media tracking, and more.

---

## Project Overview

| Aspect | Details |
|--------|---------|
| **Tech Stack** | Flutter 3.6+, Dart, Supabase (auth + database), Provider |
| **Platforms** | iOS & Android |
| **Architecture** | MVC-inspired with Provider state management |
| **Current Features** | Email/Google auth, Books CRUD, Word Pair Generator |

---

## Current Folder Structure

```
lib/
├── main.dart              # App entry, Supabase init, Provider setup
├── controller/
│   ├── auth_service.dart  # Authentication operations
│   ├── book_service.dart  # Books CRUD via Supabase
│   ├── navigation.dart    # Navigation singleton
│   ├── auth_gate.dart     # Auth state routing
│   └── pages/             # Page-level logic (login, signup, profile)
├── model/
│   ├── main_state.dart    # Global app state (ChangeNotifier)
│   ├── menu.dart          # Navigation state
│   ├── book.dart          # Book data model
│   └── wordpair/          # Word pair state
└── view/
    ├── menu.dart          # Main scaffold
    ├── auth/              # Login, signup, profile UI
    ├── book/              # Books page and dialogs
    ├── wordpair/          # Generator and favorites
    ├── components/        # Reusable widgets
    └── navigation/        # Nav bar and rail widgets
```

---

## Immediate Improvements Needed

Before adding new features, address these issues:

### 1. Consistent Service Injection
**Problem**: Services created with `AuthService()` in pages instead of Provider.

```dart
// BAD - creates new instance each time
final authService = AuthService();

// GOOD - use Provider
final authService = Provider.of<AuthService>(context, listen: false);
// or
final authService = context.read<AuthService>();
```

### 2. Separate Business Logic from UI
**Problem**: Pages like `BooksPage` handle fetching and state directly.

**Solution**: Create dedicated controllers/blocs per feature.

### 3. Error Handling Layer
**Problem**: Ad-hoc try/catch scattered everywhere.

**Solution**: Create custom exception classes:
```dart
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class AuthException extends AppException {
  AuthException(super.message);
}

class NetworkException extends AppException {
  NetworkException(super.message);
}
```

### 4. Navigation Upgrade
**Problem**: Basic `Navigator.push` doesn't scale.

**Solution**: Migrate to `go_router` for:
- Typed routes
- Deep linking
- URL sync
- Route guards

### 5. Test Coverage
**Problem**: Almost no tests exist.

**Priority**: Add unit tests for `AuthService`, `BookService`, state classes.

### 6. Constants File
**Problem**: Magic strings throughout code.

**Solution**: Create `lib/core/constants.dart`:
```dart
class AppConstants {
  static const String booksTable = 'books';
  static const Duration animationDuration = Duration(milliseconds: 300);
}
```

---

## Vision & Roadmap

See [WIP.md](../WIP.md) for full feature specs.

### Core Concept: Spaces
Modular containers users create from templates:
- **Recipe Book** - Recipes with smart ingredient scaling
- **Expense Tracker** - Spending by category/trip with reports
- **Photo Album** - Shared collections with comments
- **Media Tracker** - Movies, books, games with progress
- **Notes** - Markdown notes and checklists
- **Custom** - User-defined field types

### Collaboration Model
```
Private → Shared (specific users) → Group (team access)
```

### Milestones
1. **MVP v0.1**: Auth + Spaces + Recipe Book + Basic offline
2. **v0.2**: Expense Tracker + Media Tracker
3. **v0.3**: Groups + Sharing + Real-time sync
4. **v0.4**: Chat + Push notifications
5. **v0.5**: Custom Space builder + Themes

---

## Target Architecture

Evolve toward this feature-based structure:

```
lib/
├── core/
│   ├── config/           # Environment, constants
│   ├── theme/            # ThemeData, colors, typography
│   ├── router/           # GoRouter configuration
│   └── utils/            # Extensions, helpers
├── data/
│   ├── models/           # Data classes (User, Space, Recipe)
│   ├── repositories/     # Data access abstraction
│   ├── providers/        # Supabase, local storage
│   └── services/         # Business logic
├── features/
│   ├── auth/
│   ├── spaces/
│   ├── recipes/
│   ├── expenses/
│   └── settings/
└── shared/
    ├── widgets/          # Reusable components
    └── layouts/          # Common screen layouts
```

---

## Flutter Learning Path

### 1. Widget Fundamentals

#### Everything is a Widget
Flutter uses composition: small widgets combine to build complex UIs.

```dart
// Composition example
Widget build(BuildContext context) {
  return Container(           // Layout widget
    padding: EdgeInsets.all(16),
    child: Column(            // Arranges children vertically
      children: [
        Text('Hello'),        // Display widget
        ElevatedButton(       // Interactive widget
          onPressed: () {},
          child: Text('Tap'),
        ),
      ],
    ),
  );
}
```

#### StatelessWidget vs StatefulWidget

| StatelessWidget | StatefulWidget |
|-----------------|----------------|
| Immutable | Has mutable state |
| Rebuilt when parent rebuilds | Rebuilt via `setState()` |
| Use for: static content | Use for: interactive content |

```dart
// StatelessWidget - no internal state
class Greeting extends StatelessWidget {
  final String name;
  const Greeting({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name');
  }
}

// StatefulWidget - has internal state
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => _count++),
      child: Text('Count: $_count'),
    );
  }
}
```

#### BuildContext
Widget's location in the tree. Used to:
- Access theme: `Theme.of(context)`
- Access providers: `Provider.of<T>(context)`
- Navigate: `Navigator.of(context)`
- Show dialogs: `showDialog(context: context, ...)`

#### Keys
Preserve widget state across rebuilds:
```dart
// Use when order might change
ListView(
  children: items.map((item) =>
    ListTile(
      key: ValueKey(item.id),  // Preserves state
      title: Text(item.name),
    ),
  ).toList(),
)
```

#### Widget Lifecycle (StatefulWidget)
```
createState() → initState() → didChangeDependencies() → build()
                    ↓
              didUpdateWidget() → build()
                    ↓
                 dispose()
```

| Method | When Called | Use For |
|--------|-------------|---------|
| `initState()` | Once, when created | Initialize state, subscriptions |
| `didChangeDependencies()` | After initState, when dependencies change | Access InheritedWidgets |
| `build()` | Every time state changes | Return widget tree |
| `didUpdateWidget()` | When parent passes new config | Compare old/new widget |
| `dispose()` | When removed from tree | Cancel subscriptions, dispose controllers |

---

### 2. Layout System

#### Box Constraints
Parent tells child: "You must be between minWidth-maxWidth and minHeight-maxHeight."

```dart
// Tight constraint - exact size
SizedBox(width: 100, height: 100, child: ...)

// Loose constraint - up to max
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 300),
  child: ...
)
```

#### Core Layout Widgets

**Row & Column**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Horizontal
  crossAxisAlignment: CrossAxisAlignment.center,      // Vertical
  children: [Widget1(), Widget2(), Widget3()],
)

Column(
  mainAxisAlignment: MainAxisAlignment.start,   // Vertical
  crossAxisAlignment: CrossAxisAlignment.stretch, // Horizontal (full width)
  children: [Widget1(), Widget2()],
)
```

**Expanded & Flexible**
```dart
Row(
  children: [
    Expanded(flex: 2, child: Container(color: Colors.red)),   // 2/3 width
    Expanded(flex: 1, child: Container(color: Colors.blue)),  // 1/3 width
  ],
)
```

**Stack** (overlay)
```dart
Stack(
  children: [
    Image.asset('background.png'),  // Bottom layer
    Positioned(                      // Positioned on top
      bottom: 16,
      right: 16,
      child: FloatingActionButton(...),
    ),
  ],
)
```

**ListView** (scrollable)
```dart
// Static list
ListView(children: [Widget1(), Widget2()])

// Dynamic list (efficient)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index])),
)
```

#### Responsive Design
```dart
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width < 600) {
    return MobileLayout();
  } else {
    return DesktopLayout();
  }
}

// Or use LayoutBuilder for parent constraints
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    }
    return DesktopLayout();
  },
)
```

---

### 3. State Management with Provider

#### ChangeNotifier
```dart
class CartState extends ChangeNotifier {
  final List<Item> _items = [];

  List<Item> get items => List.unmodifiable(_items);

  void addItem(Item item) {
    _items.add(item);
    notifyListeners();  // Triggers rebuild
  }

  void removeItem(Item item) {
    _items.remove(item);
    notifyListeners();
  }
}
```

#### Providing State
```dart
// In main.dart or widget tree
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CartState()),
    ChangeNotifierProvider(create: (_) => UserState()),
    Provider(create: (_) => ApiService()),  // No notifications
  ],
  child: MyApp(),
)
```

#### Consuming State
```dart
// Method 1: Provider.of (rebuilds entire widget)
Widget build(BuildContext context) {
  final cart = Provider.of<CartState>(context);
  return Text('Items: ${cart.items.length}');
}

// Method 2: Consumer (rebuilds only child)
Consumer<CartState>(
  builder: (context, cart, child) {
    return Text('Items: ${cart.items.length}');
  },
)

// Method 3: context.watch (same as Provider.of)
final cart = context.watch<CartState>();

// Method 4: context.read (no rebuild, for methods)
onPressed: () => context.read<CartState>().addItem(item)
```

#### When to Use What
| Scenario | Solution |
|----------|----------|
| Display data | `context.watch<T>()` or `Consumer<T>` |
| Call methods | `context.read<T>()` |
| Optimize rebuilds | Use `Consumer` around specific widgets |
| Listen without rebuild | Use `listen: false` |

---

### 4. Navigation

#### Navigator 1.0 (Current)
```dart
// Push new screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DetailScreen(id: item.id)),
);

// Pop current screen
Navigator.pop(context);

// Pop with result
Navigator.pop(context, selectedValue);

// Push and remove all previous
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => HomeScreen()),
  (route) => false,
);
```

#### go_router (Recommended for scaling)
```dart
// Define routes
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
      routes: [
        GoRoute(
          path: 'book/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BookDetailScreen(id: id);
          },
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = context.read<AuthState>().isLoggedIn;
    if (!isLoggedIn && state.matchedLocation != '/login') {
      return '/login';
    }
    return null;
  },
);

// Navigate
context.go('/book/123');
context.push('/book/123');
```

---

### 5. Supabase Integration

#### Authentication
```dart
final supabase = Supabase.instance.client;

// Sign up
await supabase.auth.signUp(
  email: email,
  password: password,
);

// Sign in
await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Sign out
await supabase.auth.signOut();

// Listen to auth changes
supabase.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  final session = data.session;

  if (event == AuthChangeEvent.signedIn) {
    // Handle sign in
  } else if (event == AuthChangeEvent.signedOut) {
    // Handle sign out
  }
});

// Get current user
final user = supabase.auth.currentUser;
```

#### Database Operations
```dart
// SELECT
final data = await supabase
    .from('books')
    .select()
    .eq('user_id', userId)
    .order('created_at', ascending: false);

// INSERT
await supabase.from('books').insert({
  'title': title,
  'author': author,
  'user_id': userId,
});

// UPDATE
await supabase
    .from('books')
    .update({'title': newTitle})
    .eq('id', bookId);

// DELETE
await supabase
    .from('books')
    .delete()
    .eq('id', bookId);

// Real-time subscription
supabase
    .from('books')
    .stream(primaryKey: ['id'])
    .eq('user_id', userId)
    .listen((data) {
      // Handle updates
    });
```

#### Storage
```dart
// Upload file
await supabase.storage
    .from('avatars')
    .upload('user_$userId.png', file);

// Get public URL
final url = supabase.storage
    .from('avatars')
    .getPublicUrl('user_$userId.png');

// Download file
final bytes = await supabase.storage
    .from('avatars')
    .download('user_$userId.png');
```

---

### 6. Platform-Specific Knowledge

#### iOS Configuration

**Info.plist** (`ios/Runner/Info.plist`)
```xml
<!-- Camera permission -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>

<!-- Photo library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo access to upload images</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location to show nearby items</string>
```

**Key iOS Concepts**:
- **Safe Area**: Use `SafeArea` widget for notch/home indicator
- **Cupertino widgets**: iOS-native look (`CupertinoButton`, `CupertinoTextField`)
- **App Icons**: Provide 1024x1024 source, use asset generator
- **Launch Screen**: Configure in `LaunchScreen.storyboard`

#### Android Configuration

**AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Internet permission -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- Camera permission -->
<uses-permission android:name="android.permission.CAMERA"/>

<!-- Storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**build.gradle** (`android/app/build.gradle`)
```groovy
android {
    compileSdk 34

    defaultConfig {
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

**Key Android Concepts**:
- **Material Design**: Use Material widgets for native look
- **Back button**: Handle with `WillPopScope` or `PopScope`
- **Runtime permissions**: Request at runtime for camera, location
- **App signing**: Keystore required for release builds

---

### 7. Testing

#### Unit Tests
```dart
// test/services/auth_service_test.dart
import 'package:test/test.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('validates email format', () {
      expect(authService.isValidEmail('test@example.com'), isTrue);
      expect(authService.isValidEmail('invalid'), isFalse);
    });
  });
}
```

#### Widget Tests
```dart
// test/widgets/book_card_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BookCard displays title and author', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BookCard(
          book: Book(title: 'Flutter Guide', author: 'John'),
        ),
      ),
    );

    expect(find.text('Flutter Guide'), findsOneWidget);
    expect(find.text('John'), findsOneWidget);
  });

  testWidgets('BookCard tap calls onTap', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: BookCard(
          book: testBook,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(BookCard));
    expect(tapped, isTrue);
  });
}
```

#### Mocking with Mocktail
```dart
import 'package:mocktail/mocktail.dart';

class MockBookService extends Mock implements BookService {}

void main() {
  late MockBookService mockService;

  setUp(() {
    mockService = MockBookService();
  });

  test('loads books from service', () async {
    when(() => mockService.getBooks())
        .thenAnswer((_) async => [testBook]);

    final books = await mockService.getBooks();
    expect(books.length, 1);
    verify(() => mockService.getBooks()).called(1);
  });
}
```

---

## iOS Deployment Guide

### Prerequisites
- Mac with Xcode 15+ installed
- Apple Developer account ($99/year): https://developer.apple.com
- Physical iOS device (required for push notifications, some APIs)

### Step 1: Apple Developer Portal Setup

1. **Create App ID**:
   - Go to Certificates, Identifiers & Profiles
   - Create new Identifier → App IDs
   - Bundle ID: `com.yourcompany.myapp` (must match Xcode)
   - Enable capabilities: Push Notifications, Sign in with Apple, etc.

2. **Create Certificates**:
   - Development certificate (for testing)
   - Distribution certificate (for App Store)
   - Download and double-click to install in Keychain

3. **Create Provisioning Profiles**:
   - Development profile (link to devices)
   - App Store distribution profile
   - Download and double-click to install

### Step 2: Xcode Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project → Signing & Capabilities
3. Set Team (your Apple Developer account)
4. Set Bundle Identifier (must match App ID)
5. Configure version and build number
6. Add app icons in Assets.xcassets

### Step 3: Build for Release

```bash
# Build IPA for App Store
flutter build ipa

# Output: build/ios/ipa/myapp.ipa
```

### Step 4: Upload to App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Create new app (if first time)
3. Fill in app information:
   - Name, subtitle, description
   - Keywords, categories
   - Screenshots (required sizes for each device)
   - App icon, privacy policy URL
4. Upload IPA via Xcode or Transporter app
5. Select build and submit for review

### Step 5: TestFlight (Beta Testing)

1. Upload build to App Store Connect
2. Go to TestFlight tab
3. **Internal Testing**: Add team members (up to 100, instant)
4. **External Testing**:
   - Create group
   - Add testers by email (up to 10,000)
   - Requires Beta App Review (usually 24-48 hours)

### Common iOS Issues

| Issue | Solution |
|-------|----------|
| Code signing error | Check provisioning profile matches bundle ID |
| Archive fails | Clean build folder (Cmd+Shift+K), rebuild |
| Push notifications not working | Enable in App ID capabilities |
| Rejected for permissions | Add all required Info.plist descriptions |

---

## Android Deployment Guide

### Prerequisites
- Google Play Console account ($25 one-time): https://play.google.com/console
- Java/OpenJDK for keytool

### Step 1: Create Signing Key

```bash
# Generate upload keystore
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# IMPORTANT: Save password securely, you cannot recover it!
```

### Step 2: Configure Signing

Create `android/key.properties` (add to .gitignore!):
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/Users/yourusername/upload-keystore.jks
```

Update `android/app/build.gradle`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Step 3: Build for Release

```bash
# Build App Bundle (preferred for Play Store)
flutter build appbundle

# Output: build/app/outputs/bundle/release/app-release.aab

# Or build APKs
flutter build apk --split-per-abi
```

### Step 4: Google Play Console Setup

1. Create application
2. Fill store listing:
   - App name, short/full description
   - Screenshots (phone, tablet, optional: TV, watch)
   - Feature graphic (1024x500)
   - App icon (512x512)
   - Category, tags
   - Contact email, privacy policy URL
3. Set content rating (complete questionnaire)
4. Set pricing and distribution

### Step 5: Release Process

**Testing Tracks** (recommended order):

1. **Internal Testing**
   - Up to 100 testers
   - Instant availability (no review)
   - Great for team testing

2. **Closed Testing**
   - Invite-only via email lists
   - Requires review (~hours to days)
   - Good for beta users

3. **Open Testing**
   - Anyone can join via link
   - Requires review
   - Public beta

4. **Production**
   - Full public release
   - Review required (usually 1-3 days)

### Step 6: Upload AAB

1. Go to Release → Production (or testing track)
2. Create new release
3. Upload app-release.aab
4. Add release notes
5. Submit for review

### Common Android Issues

| Issue | Solution |
|-------|----------|
| Signing key lost | Cannot update app, must create new listing |
| Version code conflict | Increment versionCode in build.gradle |
| 64-bit requirement | Flutter handles automatically |
| Target API level warning | Update targetSdk in build.gradle |

---

## Development Commands

```bash
# === Development ===
flutter run                     # Run debug on connected device
flutter run -d <device_id>      # Run on specific device
flutter run --release           # Run release build
flutter devices                 # List connected devices

# === Building ===
flutter build ios               # Build iOS (debug)
flutter build ipa               # Build iOS archive (release)
flutter build apk               # Build Android APK
flutter build appbundle         # Build Android App Bundle

# === Testing ===
flutter test                    # Run all tests
flutter test test/unit/         # Run tests in directory
flutter test --coverage         # Generate coverage report
flutter test --update-goldens   # Update golden files

# === Code Quality ===
flutter analyze                 # Static analysis
dart format lib/                # Format all code
dart fix --apply                # Apply automated fixes

# === Dependencies ===
flutter pub get                 # Install dependencies
flutter pub upgrade             # Upgrade dependencies
flutter pub outdated            # Check for updates

# === Maintenance ===
flutter clean                   # Clean build artifacts
flutter pub cache repair        # Fix corrupted cache
flutter doctor                  # Check environment

# === Useful Flags ===
flutter run --verbose           # Detailed output
flutter build apk --split-per-abi  # Separate APKs per architecture
flutter build ipa --export-options-plist=ExportOptions.plist
```

---

## Coding Standards

### File Naming
```
snake_case.dart          # All Dart files
auth_service.dart        # Classes
book_model.dart          # Models
home_screen.dart         # Screens/pages
primary_button.dart      # Widgets
```

### Class Naming
```dart
AuthService              # PascalCase for classes
_PrivateHelper           # Underscore prefix for private
BookModel                # Suffix with type (Model, Service, etc.)
```

### Widget Structure
```dart
class BookCard extends StatelessWidget {
  // 1. Constructor (use const when possible)
  const BookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  // 2. Final fields
  final Book book;
  final VoidCallback? onTap;

  // 3. Build method
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 8),
              _buildAuthor(),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Private helper methods
  Widget _buildTitle() {
    return Text(
      book.title,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAuthor() {
    return Text(book.author);
  }
}
```

### Error Handling
```dart
// Define custom exceptions
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

// Handle errors consistently
Future<void> signIn(String email, String password) async {
  try {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  } on AuthException catch (e) {
    // Known auth errors
    throw AuthException(e.message);
  } catch (e) {
    // Unexpected errors
    throw AppException('Failed to sign in. Please try again.');
  }
}

// In UI
try {
  await authService.signIn(email, password);
} on AuthException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
}
```

### Const Usage
```dart
// Use const for immutable widgets
const SizedBox(height: 16)
const EdgeInsets.all(8)
const Text('Static text')

// Use const constructors
const MyWidget({super.key});

// Don't use const when values are dynamic
SizedBox(height: spacing)  // spacing is variable
Text(userName)             // userName is variable
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, Supabase init, root widget |
| `lib/controller/auth_service.dart` | Authentication methods |
| `lib/controller/book_service.dart` | Book CRUD operations |
| `lib/model/main_state.dart` | Global app state |
| `lib/model/book.dart` | Book data model |
| `lib/view/menu.dart` | Main navigation scaffold |
| `pubspec.yaml` | Dependencies and metadata |
| `ios/Runner/Info.plist` | iOS permissions and config |
| `android/app/build.gradle` | Android build config |
| `WIP.md` | Full feature roadmap |

---

## Resources

- [Flutter Docs](https://docs.flutter.dev)
- [Supabase Docs](https://supabase.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [go_router Package](https://pub.dev/packages/go_router)
- [Material 3 Design](https://m3.material.io)
- [Apple HIG](https://developer.apple.com/design/human-interface-guidelines)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
