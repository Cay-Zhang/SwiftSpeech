<div align=center>
<img src="Readme Assets/Icon.png" width="180" height="180" align=center>
</div>
<h1 align=center>SwiftSpeech</h1>
<h3 align=center>Speech Recognition Made Simple</h3>

<p align=center>
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift-5.2+-fe562e"></a>
<a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/iOS-13%2B-blue"></a>
<a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat"></a>
<a href="https://github.com/Cay-Zhang/SwiftSpeech/blob/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat"></a>
</p>

![A few lines of code to do this!](Readme%20Assets/Pitch.gif)

**Recognize your user's voice elegantly without having to figure out authorization and audio engines.**

- [SwiftSpeech Examples](#swiftspeech-examples)
- [Features](#features)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [SwiftSpeech.Session](#swiftspeechsession)
- [Customized View Components](#customized-view-components)
- [Support SwiftSpeech Modifiers](#support-swiftspeech-modifiers)
- [License](#license)

## SwiftSpeech Examples
Aside from the readme, the best way to learn more about SwiftSpeech and how speech recognition capabilities are implemented in apps like WeChat is to check out my new project [**SwiftSpeech Examples**](https://github.com/Cay-Zhang/SwiftSpeechExamples). For now, it contains a WeChat voice message interface mock and the three demos in SwiftSpeech.

![WeChat](Readme%20Assets/WeChat.gif)

## Features
**SwiftSpeech** is a wrapper for Apple's **Speech** framework with deep **SwiftUI** and **Combine** integration.

- [x] UI control + speech recognition functionality in just several lines of code.
- [x] Customizable cancelling.
- [x] SwiftUI style reactive APIs and Combine support.
- [x] Highly customizable but also keeping your code highly reusable via a composable structure.
- [x] Fully open low-level APIs.

## Installation
### Swift Package Manager (Recommended)
In Xcode, select `Add Packages...` from the `File` menu and enter the following package URL:
```html
https://github.com/Cay-Zhang/SwiftSpeech
```

### CocoaPods
```ruby
pod 'SwiftSpeech'
```

## Getting Started
### 1. Authorization
Although SwiftSpeech takes care of all the verbose stuff of authorization for you, you still have to state the usage descriptions and specify where you want the authorization process to happen before you start to use it.
#### Usage Descriptions in Info.plist
If you haven't, add these two rows in your `Info.plist`:
`NSSpeechRecognitionUsageDescription` and `NSMicrophoneUsageDescription`.

These are the messages your users will see on their first use, in the alerts that ask them for permission to use speech recognition and to access the microphone.

Here's an exmample:
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to convert your speech into text.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app uses the mircrophone to record audio for speech recognition.</string>
```
#### Request Authorization
Place `SwiftSpeech.requestSpeechRecognitionAuthorization()` where you want the request to happen. A common location is inside an `onAppear` modifier. Common enough that there is a snippet called **Request Speech Recognition Authorization on Appear** exposed in the Xcode Modifiers library.
```swift
.onAppear {
    SwiftSpeech.requestSpeechRecognitionAuthorization()
}
```
### 2. Try some demos
You can now start to try out some light-weight demos bundled with the framework using Xcode preview. Click the "Preview on Device" button to try the demo on your device.
```swift
static var previews: some View {
    // Two of the demo views below can take a `localeIdentifier: String` as an argument.
    // Example locale identifiers:
    // 简体中文（中国）= "zh_Hans_CN"
    // English (US) = "en_US"
    // 日本語（日本）= "ja_JP"
    
    Group {
        SwiftSpeech.Demos.Basic(localeIdentifier: yourLocaleString)
        SwiftSpeech.Demos.Colors()
        SwiftSpeech.Demos.List(localeIdentifier: yourLocaleString)
    }
}
```

Here are the "previews" of your `previews`:

![Demos](Readme%20Assets/Demos.gif)

### 3. Build it yourself

Knowing what this framework can do, you can now start to learn about the concepts in SwiftSpeech.

Inspect the source code of `SwiftSpeech.Demos.Basic`. The only new thing here is this:
```swift
SwiftSpeech.RecordButton()                                        // 1. The View Component
    .swiftSpeechRecordOnHold(sessionConfiguration:animation:distanceToCancel:)  // 2. The Functional Component
    .onRecognizeLatest(update: $text)                             // 3. SwiftSpeech Modifier(s)
```
There are three parts here (and luckily, you can customize every one of them!):
1. **The View Component**: A `View` that is only responsible for UI.
2. **The Functional Component**: A component that handles user interaction and provides the essential functionality of speech recognition. In the built-in one here, the first two arguments let you specify the [configuration](#configuration) for the recording session (locales and more) and an animation used when the user interacts with the **View Component**. The third argument sets the distance the user has to swipe up in order to cancel the recording. The framework also provides another **Functional Component**: `.swiftSpeechToggleRecordingOnTap(sessionConfiguration:animation:)`.
3. **SwiftSpeech Modifier(s)**: One or more components allowing you to receive and manipulate the recognition results. They can be stacked together to create powerful effects.

For now, you can just use the built-in View Component and Functional Component. Let's explore some **SwiftSpeech Modifiers** first since every app handles its data differently:

**Important: Chaining multiple or identical SwiftSpeech Modifiers together doesn't override any behavior. All actions of the modifiers will be executed in the order where the closest to the Functional Component executes first and the farthest executes last.**

```swift
// 1
// All three demos use these modifiers.
// Inspect the source code of them if you want examples!
.onRecognizeLatest(
    includePartialResults: Bool = true,
    handleResult: (SwiftSpeech.Session, SFSpeechRecognitionResult) -> Void,
    handleError: (SwiftSpeech.Session, Error) -> Void
)

.onRecognize(
    includePartialResults: Bool = true,
    handleResult: (SwiftSpeech.Session, SFSpeechRecognitionResult) -> Void,
    handleError: (SwiftSpeech.Session, Error) -> Void
)

// This one simply assigns the recognized text to the binding in `handleResult` and ignores errors.
.onRecognizeLatest(
    includePartialResults: Bool = true,
    update: Binding<String>
)

// This one prints the recognized text and ignores errors.
.printRecognizedText(includePartialResults: Bool = true)
```
The first group of modifiers encapsulates the core value of SwiftSpeech. It does all the publisher transformation and subscription for you and calls the closures with enough information to facilitate a sophisticated task when a recognition result is yielded.

`onRecognizeLatest` ignores recognition results from the last recording session (if any) when a new session is started, while `onRecognize` subscribes to results from every recording session.

In `handleResult`, the first closure parameter is a `SwiftSpeech.Session`, which has a unique `id` for every recording. Use it to distinguish the recognition result from one recording and that from another.

The second is a [`SFSpeechRecognitionResult`](https://developer.apple.com/documentation/speech/sfspeechrecognitionresult), which contains rich information about the recognition. Not only the recognized text (`result.bestTranscription.formattedString`), but also interesting stuff like **speaking rate** and **pitch**!

In `handleError`, you will handle the errors produced in the recognition process and also during the initialization of the recording session (such as a microphone activation failure).

```swift
// 2
.onStartRecording(appendAction: (SwiftSpeech.Session) -> Void)
.onStopRecording(appendAction: (SwiftSpeech.Session) -> Void)
.onCancelRecording(appendAction: (SwiftSpeech.Session) -> Void)
```

The second group gives you utter control over the whole lifespan of a `SwiftSpeech.Session`.  It runs the provided closures after a recording was started/stopped/cancelled. Inside the closures, you will have access to the corresponding `SwiftSpeech.Session`, which is discussed [below](#swiftspeech.session).

```swift
// 3
// `SwiftSpeech.ViewModifiers.OnRecognize` uses these modifiers.
// Inspect the source code of it if you want examples!
.onStartRecording(sendSessionTo: Subject)
.onStopRecording(sendSessionTo: Subject)
.onCancelRecording(sendSessionTo: Subject)
```

The third group might be useful if you prefer a reactive programming style. The only new argument here is a `Combine.Subject` (e.g. `CurrentValueSubject` and `PassthroughSubject`) and the modifier will send the corresponding `SwiftSpeech.Session` to the `Subject` after a recording is started/stopped/cancelled.

## SwiftSpeech.Session
### Configuration
A session can be configured using a `SwiftSpeech.Session.Configuration` struct. A configuration contains information such as the locale, the task hint, custom phrases to recognize, options for on-device recognition, and audio session configurations. Inspect `SwiftSpeech.Session.Configuration` for more details.
### Customized Subscription to Recognition Results
If the built-in `onRecognize(Latest)` modifiers do not satisfy your needs, you can subscribe to recognition results via `onStart/Stop/CancelRecording`.

A `Session` publishes its recognition results via its `resultPublisher`. It has an `Output` type of `SFSpeechRecognitionResult` and an `Failure` type of `Error`.

You will receive a completion event when the `Session` finishes processing the user's voice (i.e. `result.isFinal == true`), an error happens, or you have explicitly called the `cancelRecording()` on the session.

A `Session` also has a convenient publisher called `stringPublisher` that maps the results to the recognized string.
### Independent Use
Here's an example of using `Session` to recognize user's voice and receive updates.
```swift
let session = SwiftSpeech.Session(configuration: SwiftSpeech.Session.Configuration(locale: Locale(identifier: "en-US"), contextualStrings: ["SwiftSpeech"]))
try session.startRecording()
session.stringPublisher?
    .sink { text in
        // do something with the text
    }
    .store(in: &cancelBag)
```
For more, please refer to the documentation of `SwiftSpeech.Session`.

## Customized View Components
A **View Component** is a dedicated `View` for design. It does not react to user interaction directly, but instead reacts to its environments, allowing developers to only focus on the view design and making the view more composable. User interactions are handled by the **Functional Component**.

Inspect the source code of `SwiftSpeech.RecordButton` (again, it's not a `Button` since it doesn't respond to user interaction). You will notice that it doesn't own any state or apply any gestures. It only responds to the two variables below.

```swift
@Environment(\.swiftSpeechState) var state: SwiftSpeech.State
@SpeechRecognitionAuthStatus var authStatus
```

Both are pretty self-explanatory: the first one represents its current state of recording, and the second one indicates the authorization status of speech recognition.

Here are more details of `SwiftSpeech.State`:

```swift
enum SwiftSpeech.State {
    /// Indicating there is no recording in progress.
    /// - Note: It's the default value for `@Environment(\.swiftSpeechState)`.
    case pending
    /// Indicating there is a recording in progress and the user does not intend to cancel it.
    case recording
    /// Indicating there is a recording in progress and the user intends to cancel it.
    case cancelling
}
```

`authStatus` here is a `SFSpeechRecognizerAuthorizationStatus`. You can also use `$authStatus` for a short hand of `authStatus == .authorized`.

Combined with a **Functional Component** and some **SwiftSpeech Modifiers**, hopefully, you can build your own fancy record systems now!
## Support SwiftSpeech Modifiers
The library provides two general functional components that add a gesture to the view it modifies and perform speech recognition for you:
```swift
// They already support SwiftSpeech Modifiers.
func swiftSpeechRecordOnHold(
    sessionConfiguration: SwiftSpeech.Session.Configuration = SwiftSpeech.Session.Configuration(),
    animation: Animation = SwiftSpeech.defaultAnimation,
    distanceToCancel: CGFloat = 50.0
) -> some View

func swiftSpeechToggleRecordingOnTap(
    sessionConfiguration: SwiftSpeech.Session.Configuration = SwiftSpeech.Session.Configuration(),
    animation: Animation = SwiftSpeech.defaultAnimation
)
```
If you decide to implement a view that involves a custom gesture other than a hold or a tap, you can also support SwiftSpeech Modifiers by adding a delegate and calling its methods at the appropriate time:
```swift
var delegate = SwiftSpeech.FunctionalComponentDelegate()
```
For guidance on how to implement a custom view for speech recognition, refer to `ViewModifiers.swift` and SwiftSpeechExamples. It is not that hard, really.

## License
SwiftSpeech is available under the [MIT license](https://choosealicense.com/licenses/mit/).
