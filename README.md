# FocusZone

FocusZone is a Flutter Android app concept combining a study space, vertical short-video feeds, a focus timer, and playable mini games.

## Features

- Swipe vertically through study and fun demo video feeds; tap to pause/play, mute, scrub, and like.
- Study hub with focus and revision prompts.
- 25-minute focus timer.
- Playable two-player Tic-Tac-Toe and a memory-matching game.
- Dark, mobile-first interface with bottom navigation.

## Run locally

1. Install the Flutter SDK and Android Studio/Android SDK.
2. From the repository root, add the Android platform project if it is not present: `flutter create --platforms=android --project-name=focus_zone --org=com.focuszone .`
3. Run `flutter pub get`.
4. Run on a connected device/emulator with `flutter run`, or build an APK with `flutter build apk --release`.

The feed uses public Google sample videos as playback demos and needs internet access. Replace the sample URLs with short videos you own or have permission to publish before releasing. The comment and share controls are UI demos; they do not publish or send content yet. This repository contains Flutter source, not a prebuilt APK.
