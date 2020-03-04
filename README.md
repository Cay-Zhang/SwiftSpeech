# SwiftSpeech

**Speech Recognition, as simple and elegant as SwiftUI.**

<p>
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift-5.2-fe562e"></a>
<a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/iOS-13%2B-blue"></a>
<a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat"></a>
<a href="https://codebeat.co/projects/github-com-cay-zhang-swiftspeech-master"><img alt="codebeat badge" src="https://codebeat.co/badges/7151eef2-438b-4428-99cd-776961dcf8ab" /></a>
<a href="https://github.com/Cay-Zhang/SwiftSpeech/blob/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat"></a>
</p>

![A few lines of code to do this!](https://i.loli.net/2020/02/25/kfBvALEDYspRqtP.gif)

**Recognize your user's voice elegantly without having to figure out authorization and audio engines, with built-in SwiftUI, Combine, and multi-language support.**

SwiftSpeech is a wrapper framework for the Speech / SFSpeechRecognizer APIs for iOS and macOS with built-in SwiftUI, Combine publisher, and multi-language support.

- [Features](#features)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [License](#license)

## Features

- [x] UI control + Speech recognition in just one line of code.
- [x] SwiftUI style APIs.
- [x] Combine support.
- [x] Build your own controls!
- [x] Fully open low level APIs.

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
Open up the Canvas and resume the preview if needed. You should see what your demo looks like. Then, click on the `Preview on Device` button to the bottom right edge of the preview device to run the demo. Hold on the blue circular button to speak and the recognition result will show up! 😉

Here are some previews of the demos:

🚧 Gifs still in making... Give me a star to keep me motivated!

### 3. Build it yourself

Knowing what this framework can do, you can now start to learn about the concepts in SwiftSpeech.

Inspect the source code of `SwiftSpeech.Demos.Basic`. The only new thing here is this:
```swift
SwiftSpeech.RecordButton()  // The "View Component", this here is just an example bundled in the framework, you can easily build your own.
.swiftSpeechRecordOnHold(  // The "Functional Component" (Actually they are view modifiers).
        recognizedText: $text,
        locale: self.locale,
        animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)
    )
```
As you can see, the "Record Button" is composed of two components: a `View` that is only responsible of UI (The "**View Component**"), wrapped in a `ViewModifier` provided by the framework to handle all the stuff about speech recognition (The "**Functional Component**").

For now, you can just use the sample view component provided by the framework: `SwiftSpeech.RecordButton`. Let's first familiarize ourselves with the functional component.
Currently, there are three functional components available, all of them providing "Record On Hold" speech recognition capability, with different levels of abstraction:

```swift
// 1
// `SwiftSpeech.Demos.Basic` & `SwiftSpeech.Demos.Colors` use this component.
// Inspect the source code of them if you want examples!
func swiftSpeechRecordOnHold(
    recognizedText: Binding<String>,
    locale: Locale = .autoupdatingCurrent,
    animation: Animation = defaultAnimation
) -> some View
```
The first one is the most straight forward and convenient. It takes a `Binding<String>` and updates the latest recognition result to it. You can pass in the other two arguments which let you specify a locale (language) for recognition and an animation used when user interacts with the view component. You can use these two arguments in other functional components as well.

But frankly, this is more of a shortcut for playing/testing since many apps have to deal with some complicated underlying database and a simple `Binding` is just not enough for them. And that's when the second one comes to rescue.

```swift
// 2
// `SwiftSpeech.Demos.List` uses this component.
// Inspect the source code of it if you want examples!
func swiftSpeechRecordOnHold(
    recordingDidStart: ((_ session: SwiftSpeech.Session) -> Void)?,
    recordingDidStop: ((_ session: SwiftSpeech.Session) -> Void)? = nil,
    recordingDidCancel: ((_ session: SwiftSpeech.Session) -> Void)? = nil,
    locale...animation...
) -> some View
```
The second one gives you utter control over the whole lifespan of a `SwiftSpeech.Session`. As the argument names and types suggest, this component runs the provided closures after a recording was started/stopped/canceled. Inside the closures, you will have aceess to the corresponding `SwiftSpeech.Session`, which will be discussed below.

```swift
// 3
// The first functional component introduced above is based on this.
// Inspect `SwiftSpeech.ViewModifiers.RecordOnHold.StringBinding` to have an intuition about how to utilize the `sessionSubject`.
func swiftSpeechRecordOnHold<S: Subject>(sessionSubject: S, locale...animation...) -> some View
```
The last one is less intuitive but might be useful in some cases where it's easier to use a reactive programming style. The only new argument here is the `sessionSubject` which conforms to the `Combine.Subject` protocol (e.g. `CurrentValueSubject` and `PassthroughSubject`) and the view will send a `SwiftSpeech.Session` to the `sessionSubject` **after a new recording was started**.

🚧 Documentation still in making... Give me a star to keep me motivated!

## Legacy
### SpeechRecognizer Class
#### Initializing
```swift
let speechRecognizer = SpeechRecognizer.new(id: id, locale: locale)
```
This adds a SpeechRecognizer instance to the shared instance pool that's managed by the framework.

⚠️ Warning: You should **never keep** a strong reference to a SpeechRecognizer instance. Instead, use its `id` property to keep track of it.
#### Start Recording
```swift
try speechRecognizer.startRecording()
```
This method will set up the audio stuff automatically for you and start recording the user's voice. You can now start receiving the recognition results by subscribing to one of the publishers the recognizer exposes.
#### Subscribing
Currently, a SpeechRecognizer instance has two publishers (you only need to subscribe to one of them): `stringPublisher` and `resultPublisher`.
`stringPublisher` directly emits the speech text recognized (By default, it will emit partial results, which means **you may receive multiple events**). You will receive a `.finished` completion event whenever the recognizer finishes processing the user's voice (i.e. `sfSpeechRecognitionResult.isFinal == true`), or you explicitly called the `cancel()` method on the recognizer. Afterward, the recognizer instance will be immediately disposed of.
You can subscribe to `stringPublisher` in the following way:
```swift
speechRecognizer.stringPublisher
    .sink { text in
        print("Speech Recognizer: \(text)")
    }
    .store(in: &speechRecognizer.cancelBag)
```
For `resultPublisher`, the subscribing process is similar, except that the type of the element it will emit is `Result<SFSpeechRecognitionResult, Error>` which encapsulates the entire partial result from the underlying `SFSpeechRecognizer` or the error it emits during recognition.
#### Retrieving
```swift
SpeechRecognizer.recognizer(withID: recordingRecognizerID)
```
This returns an optional SpeechRecognizer that you can then use to stop/cancel recording.
#### Stop Recording
```swift
SpeechRecognizer.recognizer(withID: recordingRecognizerID)?.stopRecording()
```
This stops recording the user's voice. Please keep in mind that unless you have explicitly call `stopRecording()`, the recognition process will not stop (i.e. you will never receive a completion event from the publishers) because the recognizer will keep recording & recognizing the user's voice.
#### Cancel
```swift
SpeechRecognizer.recognizer(withID: recordingChoiceID)?.cancel()
```
If you are not interested in the recognition result any more and want to stop recording now, you may immediately halt the recognition process and dipose of the recognizer by calling this method.

## License
SwiftSpeech is available under the [MIT license](https://choosealicense.com/licenses/mit/).



Then, use the following code whenever you want to know if speech recognition is available in your view (e.g. when writing a button for recording, you may want to disable it whenever speech recognition is unavailable).
```swift
@Environment(\.isSpeechRecognitionAvailable) var isSpeechRecognitionAvailable: Bool
```
