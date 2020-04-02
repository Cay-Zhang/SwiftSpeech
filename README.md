<div align=center>
<img src="https://i.loli.net/2020/04/02/pYZ3vzNB9jq7xfC.png" width="125" height="125" align=center>
</div>
<p style="font-size: 48px" align=center>SwiftSpeech</p>
<h3 align=center>Speech Recognition Made Simple</h3>

<p align=center>
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift-5.2-fe562e"></a>
<a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/iOS-13%2B-blue"></a>
<a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat"></a>
<a href="https://codebeat.co/projects/github-com-cay-zhang-swiftspeech-master"><img alt="codebeat badge" src="https://codebeat.co/badges/7151eef2-438b-4428-99cd-776961dcf8ab" /></a>
<a href="https://github.com/Cay-Zhang/SwiftSpeech/blob/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat"></a>
</p>

![A few lines of code to do this!](https://github.com/Cay-Zhang/SwiftSpeech/blob/master/Readme%20Assets/Pitch.gif?raw=true)

**Recognize your user's voice elegantly without having to figure out authorization and audio engines.**

- [Features](#features)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [SwiftSpeech.Session](#swiftspeechsession)
- [Customized View Components](#customized-view-components)
- [Customized Functional Components](#customized-functional-components)
- [License](#license)

## Features
**SwiftSpeech** is a wrapper for Apple's **Speech** framework with deep **SwiftUI** and **Combine** integration.

- [x] UI control + speech recognition functionality in just several lines of code.
- [x] Customizable cancelling.
- [x] SwiftUI style reactive APIs and Combine support.
- [x] Highly customizable but also keeping your code highly reusable via a composable structure.
- [x] Fully open low-level APIs.w

## Installation
SwiftSpeech is available through Swift Package Manager. To use it, add a package dependency using URL:
```html
https://github.com/Cay-Zhang/SwiftSpeech.git
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
#### One line of code to tackle authorization
In your `SceneDelegate.swift`, add  `.automaticEnvironmentForSpeechRecognition()` after the initialization of your root view. *Boom! That's it! One line of code!* 
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    let contentView = ContentView()
        .automaticEnvironmentForSpeechRecognition()  // Just add this line of code!

    if let windowScene = scene as? UIWindowScene {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
    }
}
```
For more information, please refer to the documentation for `automaticEnvironmentForSpeechRecognition()` in `Extensions.swift`.
### 2. Try some demos
You can now start to try out some light-weight demos bundled with the framework using Xcode 11's new preview feature.
In any of your previews, initialize one of the demo views:
```swift
static var previews: some View {

    // Two of the demo views below can take a `localeIdentifier: String` as an argument.
    // Example locale identifiers:
    // 简体中文（中国）= "zh_Hans_CN"
    // English (US) = "en_US"
    // 日本語（日本）= "ja_JP"
    
    // Try one of these at a time and have fun!
    SwiftSpeech.Demos.Basic(localeIdentifier: yourLocaleString)
    SwiftSpeech.Demos.Colors()
    SwiftSpeech.Demos.List(localeIdentifier: yourLocaleString)
    
}
```
Open up the Canvas and resume the preview if needed. You should see what your demo looks like. Then, click on <img src="https://github.com/Cay-Zhang/SwiftSpeech/blob/master/Readme%20Assets/Preview_on_Device.png?raw=true" alt="Preview on Device" height=30/> button to run the demo on your device. Hold on the blue circular button to speak and the recognition result will show up! 😉

Here are the "previews" of your `previews`:

![Demos](https://github.com/Cay-Zhang/SwiftSpeech/blob/master/Readme%20Assets/Demos.gif?raw=true)

### 3. Build it yourself

Knowing what this framework can do, you can now start to learn about the concepts in SwiftSpeech.

Inspect the source code of `SwiftSpeech.Demos.Basic`. The only new thing here is this:
```swift
SwiftSpeech.RecordButton()                                        // 1. The View Component
    .swiftSpeechRecordOnHold(locale:animation:distanceToCancel:)  // 2. The Functional Component
    .onRecognize(update: $text)                                   // 3. SwiftSpeech Modifier(s)
```
There are three parts here (and luckily, you can customize every one of them!):
1. **The View Component**: A `View` that is only responsible for UI.
2. **The Functional Component**: A component that handles user interaction and provides the essential functionality of speech recognition. In the built-in one here, the first two arguments let you specify a locale (language) for recognition and an animation used when the user interacts with the **View Component**. The third argument sets the distance the user has to swipe up in order to cancel the recording. The framework also provides another **Functional Component**: `.swiftSpeechToggleRecordingOnTap(locale:animation:)`.
3. **SwiftSpeech Modifier(s)**: One or more components allowing you to receive and manipulate the recognition results. They can be stacked together to create powerful effects.

For now, you can just use the built-in View Component and Functional Component. Let's explore some **SwiftSpeech Modifiers** first since every app handles its data differently:

**Important: Chaining multiple or identical SwiftSpeech Modifiers together doesn't override any behavior. All actions of the modifiers will be executed in the order where the closest to the Functional Component executes first and the farthest executes last.**

```swift
// 1
// `SwiftSpeech.Demos.Basic` & `SwiftSpeech.Demos.Colors` use these modifiers.
// Inspect the source code of them if you want examples!
.onRecognize(textHandler: (String) -> Void)
.onRecognize(update: Binding<String>)
.printRecognizedText()
```
The first kind of modifiers is the most straight forward and convenient. It does something when a new recognition result is yielded.

But frankly, this is more of a shortcut for playing/testing since many apps have to deal with some complicated underlying database and a simple `Binding` or closure is just not enough for it. And that's when the second set comes to rescue.

```swift
// 2
// `SwiftSpeech.Demos.List` uses these modifiers.
// Inspect the source code of it if you want examples!
.onStartRecording(appendAction: (SwiftSpeech.Session) -> Void)
.onStopRecording(appendAction: (SwiftSpeech.Session) -> Void)
.onCancelRecording(appendAction: (SwiftSpeech.Session) -> Void)
```

The second kind gives you utter control over the whole lifespan of a `SwiftSpeech.Session`.  It runs the provided closures after a recording was started/stopped/cancelled. Inside the closures, you will have access to the corresponding `SwiftSpeech.Session`, which is discussed [below](#swiftspeech.session).

```swift
// 3
// `SwiftSpeech.ViewModifiers.OnRecognize` uses these modifiers.
// Inspect the source code of it if you want examples!
.onStartRecording(sendSessionTo: Subject)
.onStopRecording(sendSessionTo: Subject)
.onCancelRecording(sendSessionTo: Subject)
```

The third kind might be useful if you prefer a reactive programming style. The only new argument here is a `Combine.Subject` (e.g. `CurrentValueSubject` and `PassthroughSubject`) and the modifier will send the corresponding `SwiftSpeech.Session` to the `Subject` after a recording is started/stopped/cancelled.

## SwiftSpeech.Session
### Inside SwiftSpeech's Session Handler
If you are filling in a `(Session) -> Void` handler provided by the framework, use the publishers provided by the `Session` to receive updates on recognition results.

Currently, a `Session` has two publishers (you only need to subscribe to one of them): `stringPublisher` and `resultPublisher`.

`stringPublisher` directly emits the speech text recognized (By default, it will emit partial results, which means **you may receive multiple events**). You will receive a `.finished` completion event when the `Session` finishes processing the user's voice (i.e. `sfSpeechRecognitionResult.isFinal == true`), or you explicitly called the `cancelRecording()` method.

You can subscribe to `stringPublisher` in the following way:
```swift
speechRecognizer.stringPublisher
    .sink { text in
        print("[SwiftSpeech]: \(text)")
    }
    .store(in: &someCancelBag)
```
For `resultPublisher`, the subscribing process is similar, except that the type of the element it will emit is `Result<SFSpeechRecognitionResult, Error>` which encapsulates the entire partial result from the underlying `SFSpeechRecognizer` or the error it emits during recognition.
### Independent Use
Here's an exmaple of using `Session` to recognize user's voice and receive updates.
```swift
let session = SwiftSpeech.Session(locale: .current)
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

Inspect the source code of `SwiftSpeech.RecordButton` (again, it's not a `Button` since it doesn't respond to user interaction). You will notice that it doesn't own any state or apply any gestures. It only responds to the two environments below.

```swift
@Environment(\.swiftSpeechState) var state: SwiftSpeech.State
@Environment(\.isSpeechRecognitionAvailable) var isSpeechRecognitionAvailable: Bool
```

Both are pretty self-explanatory: the first one represents its current state of recording, and the second one indicates the availability of speech recognition.

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

Combined with a **Functional Component** and some **SwiftSpeech Modifiers**, hopefully, you can build your own fancy record systems now!
## Customized Functional Components
🚧 Documentation still in making... Give me a star to keep me motivated!
For now, please refer to the source code of the demos provided by the framework for example.

## License
SwiftSpeech is available under the [MIT license](https://choosealicense.com/licenses/mit/).
