# Tan · URBAN ECHO

**Tan · URBAN ECHO** is an iOS application that helps preserve the stories of mobile street vendors, traditional craftspeople, and changing urban neighborhoods.

Instead of operating as a shopping or delivery platform, the project combines AI-assisted archiving, location-based discovery, a MapKit memory guide, and community contributions to record people, skills, places, and local memories.

The project was developed for the China Collegiate Computing Contest — Mobile Application Innovation Competition.

## Product Vision

Street stalls and small traditional crafts often disappear before their stories are properly recorded. Tan provides two complementary experiences:

- Visitors discover nearby archives, follow memory routes, and contribute photos or status clues.
- Vendors and craftspeople describe their work in natural language, then use AI to organize the description into an editable archive.

The four core experiences are:

1. AI-assisted archive creation
2. Map-based discovery
3. Xilian, the urban memory guide
4. Community archive contributions

## Implemented Features

### Visitor Experience

- Browse seeded and user-created urban archives
- Search and filter by category, place, and archive status
- View archive stories, craft processes, historical activity areas, and reference prices
- Discover stalls on an Apple MapKit map
- Request walking routes with `MKDirections`
- Watch Xilian move along the geographical coordinates of an `MKPolyline`
- Ask Xilian questions using the currently selected archive as context
- Add text comments and up to three photo attachments
- Take a photo or choose one from the photo library
- Submit community status clues with an optional on-site photo
- Maintain a personal protection list and contribution records

Community status clues are archive contributions and do not represent a real-time business guarantee from a vendor.

### Vendor Experience

- Create an archive from a natural-language description
- Take or select a cover photo
- Use real-time speech-to-text before submitting the text to AI
- Choose Mandarin, Chengdu speech, or Zigong speech as a user-facing input mode
- Use DashScope Sichuan speech recognition capability for the Chengdu and Zigong modes
- Edit the transcription with the system keyboard
- Generate an editable structured archive through DashScope Qwen
- Review and confirm the archive before saving
- Edit existing archive information, cover images, craft steps, and display metrics
- Review community contributions associated with owned archives

The selected photo is currently stored as archive material and a cover image. The AI archive builder primarily uses the user's text or speech transcription; the application does not claim that visual recognition is already implemented.

## Xilian: Urban Memory Guide

Xilian is not presented as a generic customer-service chatbot. She is an urban memory guide connected to the selected archive.

The route experience uses:

- `MKMapView`
- `MKDirections`
- `MKRoute`
- `MKPolyline`
- Core Location
- Reusable geographical annotations

Route coordinates are converted into cumulative distances. Xilian's current coordinate is interpolated by travelled distance rather than by raw polyline point index, producing a more consistent demonstration speed even when MapKit coordinates are unevenly spaced.

Xilian remains a map annotation driven by latitude and longitude. Zooming, panning, rotating, or pitching the map does not turn her movement into a fixed screen-space animation.

If a walking route cannot be generated, the application can display a demonstration direction line that is explicitly labelled as **not a real walking route**.

## AI and Speech

### Structured Archive Generation

`QwenArchiveAgent` sends the user's text to DashScope and requests structured archive data. The result is parsed into an editable draft.

The current flow includes:

- A visible loading state
- Duplicate-request prevention
- A 20-second request timeout
- JSON cleanup and parsing
- A locally generated, editable draft when the network response cannot be used

### Contextual Xilian Chat

`XilianChatAgent` uses the selected archive as conversation context. If the network request fails, the UI remains usable and can show a local contextual fallback.

### Real-Time Speech Recognition

The speech layer is abstracted through `SpeechRecognitionService`. The current implementation connects to DashScope `fun-asr-realtime` through `URLSessionWebSocketTask`.

- 16 kHz mono PCM microphone input
- Partial and final transcription events
- Tap to start and tap again to stop
- Maximum recording duration of 60 seconds
- Cancellation when the page disappears or the app enters the background
- No automatic AI submission
- No raw audio persistence
- No API key logging

Chengdu and Zigong are separate user-facing speaking modes, but both use the same Sichuan speech recognition capability. They are not represented as separate recognition models.

## Local Persistence

The competition build is designed as a stable single-device demonstration.

- Archive snapshots are encoded as JSON in Application Support.
- User images are normalized and saved in the private Application Support directory.
- A display image is limited to approximately 2048 pixels on its longest edge.
- A separate thumbnail is generated.
- Codable models store relative filenames instead of `UIImage`, temporary picker URLs, or photo-library asset references.
- User-created records and images survive an app restart.
- Deleting a user record also removes its related local image files.
- Bundled seed images remain read-only resources.

The UI does not write JSON or image files directly. Storage is accessed through:

```swift
protocol ArchiveRepository {
    func loadSnapshot() async throws -> ArchiveSnapshot
    func saveSnapshot(_ snapshot: ArchiveSnapshot) async throws
}

protocol PhotoStorageService {
    func saveImage(_ image: UIImage, caption: String?) async throws -> PhotoAttachment
    func deletePhoto(_ attachment: PhotoAttachment) async throws
    func loadImage(_ attachment: PhotoAttachment, thumbnail: Bool) async -> UIImage?
}
```

The current implementations are `LocalArchiveRepository` and `LocalPhotoStorageService`. A remote database and object-storage implementation can be added later without coupling the views to a specific backend.

## Technology

- Swift
- SwiftUI
- UIKit interoperability
- Apple MapKit
- Core Location
- PhotosUI
- AVFoundation
- DashScope Qwen
- DashScope `fun-asr-realtime`
- Codable JSON persistence

Minimum deployment target: **iOS 16.0**

The latest competition build has been compiled and tested with Xcode 26.6 and the iOS 26.5 Simulator runtime.

## Project Structure

```text
TanApp/
├── RootView.swift                  Login, role selection, and main tabs
├── DiscoverView.swift              Archive discovery and filtering
├── ArchiveMapView.swift            MapKit map, route, and Xilian presentation
├── ArchiveDetailView.swift         Archive content and community contributions
├── AIArchiveBuilderView.swift      Speech, text, AI generation, and confirmation
├── ArchiveStore.swift              Main observable application state
├── CloudArchiveService.swift       Repository protocols and local repository
├── LocalPhotoStorageService.swift  Local image persistence
├── ImageAttachmentPicker.swift     Shared camera and photo-library UI
├── UnifiedQwenService.swift        Shared DashScope text request layer
├── SpeechRecognitionService.swift  Real-time ASR abstraction and implementation
├── MockArchiveData.swift           First-install competition seed data
└── Xilian/                         Route interpolation, annotations, and chat UI
```

## Running the Project

### Requirements

- macOS with a complete Xcode installation
- Xcode capable of building the selected iOS Simulator runtime
- iOS 16.0 or later
- A DashScope API key for real AI and speech requests

### Local Secrets

Create `TanApp/LocalSecrets.json`:

```json
{
  "dashscopeAPIKey": "YOUR_DASHSCOPE_API_KEY",
  "qwenModel": "qwen-plus",
  "funASRModel": "fun-asr-realtime"
}
```

`LocalSecrets.json` is excluded by `.gitignore`. Do not commit a real API key.

Open `TanApp.xcodeproj`, select the `3180941` scheme, choose a simulator or a signing team for a physical device, and run the application.

Command-line simulator build:

```bash
xcodebuild \
  -project TanApp.xcodeproj \
  -scheme 3180941 \
  -sdk iphonesimulator \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Permissions

The app requests permission only when the related feature is used:

- Location for map positioning and walking-route planning
- Camera for archive and community photos
- Photo library for selecting archive and contribution images
- Microphone for converting Mandarin or Sichuan speech into archive text

Permission denial does not prevent the user from continuing with text input or browsing existing archives.

## Seed Data and Image Credits

The first-install competition state contains five curated archive examples. Names and narratives are competition aliases.

Bundled seed images are real reference images of similar stalls or crafts. They must not be interpreted as photographs of the named archive person or exact archive location. Attribution and licence information is recorded in [`TanApp/SeedPhotoCredits.txt`](TanApp/SeedPhotoCredits.txt).

## Current Scope

Implemented for the competition demonstration:

- Local archive and image persistence
- Real DashScope text requests
- Real DashScope speech-to-text
- MapKit walking routes and Xilian route animation
- Comments, photo contributions, and community status clues
- Stable visitor and vendor demonstration flows

Not currently implemented:

- Production user authentication
- A deployed cloud database
- Cross-device community synchronization
- Remote object storage
- Content moderation and reporting
- Server-side AI key proxying
- Shopping, ordering, payment, delivery, or booking

These items are future architecture directions, not claims about the current MVP.

## Privacy and Security Notes

- API credentials are loaded only from the ignored local configuration file.
- API credentials must not be printed, shown in the UI, added to documentation, or committed.
- Raw microphone audio is not saved.
- Community photos are stored locally in the application sandbox in the current build.
- A production release should move AI credentials behind a server-side proxy before public distribution.
