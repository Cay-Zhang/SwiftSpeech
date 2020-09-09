//
//  Session.swift
//  
//
//  Created by Cay Zhang on 2020/7/31.
//

import Foundation
import Speech

extension SwiftSpeech {
    
    /**
     A `Session` is a light-weight struct that essentially holds a weak reference to its underlying class whose lifespan is managed by the framework.
     If you are filling in a `(Session) -> Void` handler provided by the framework, you may want to check its `stringPublisher` and `resultPublisher` properties.
     - Note: You can only call `startRecording()` once on a `Session` and after it completes the recognition task, all of its properties will be `nil` and actions will take no effect.
     */
    @dynamicMemberLookup public struct Session : Identifiable {
        public let id: UUID
        
        public subscript<T>(dynamicMember keyPath: KeyPath<SpeechRecognizer, T>) -> T? {
            return SpeechRecognizer.recognizer(withID: id)?[keyPath: keyPath]
        }
        
        public init(id: UUID = UUID(), configuration: Configuration) {
            self.id = id
            _ = SpeechRecognizer.new(id: id, sessionConfiguration: configuration)
        }
        
        public init(id: UUID = UUID(), locale: Locale = .current) {
            self.init(id: id, configuration: Configuration(locale: locale))
        }
        
        /**
         Sets up the audio stuff automatically for you and start recording the user's voice.
         
         - Note: Avoid using this method twice.
                 Start receiving the recognition results by subscribing to one of the publishers.
         - Throws: Errors can occur when:
                   1. There is problem in the structure of the graph. Input can't be routed to output or to a recording tap through converter type nodes.
                   2. An AVAudioSession error occurred
                   3. The driver failed to start the hardware
         */
        public func startRecording() {
            guard let recognizer = SpeechRecognizer.recognizer(withID: id) else { return }
            recognizer.startRecording()
        }
        
        public func stopRecording() {
            guard let recognizer = SpeechRecognizer.recognizer(withID: id) else { return }
            recognizer.stopRecording()
        }
        
        /**
         Immediately halts the recognition process and invalidate the `Session`.
         */
        public func cancel() {
            guard let recognizer = SpeechRecognizer.recognizer(withID: id) else { return }
            recognizer.cancel()
        }
        
    }
}

public extension SwiftSpeech.Session {
    struct Configuration {
        /**
         The locale representing the language you want to use for speech recognition.
         The default value is `.current`.
         
         To get a list of locales supported by SwiftSpeech, use `SwiftSpeech.supportedLocales()`.
         */
        public var locale: Locale = .current
        
        /**
         A value that indicates the type of speech recognition being performed.
         The default value is `.unspecified`.
         
         `.unspecified` - An unspecified type of task.
         
         `.dictation` - A task that uses captured speech for text entry.
         
         `.search` - A task that uses captured speech to specify search terms.
         
         `.confirmation` - A task that uses captured speech for short, confirmation-style requests.
         */
        public var taskHint: SFSpeechRecognitionTaskHint = .unspecified
        
        /// A Boolean value that indicates whether you want intermediate results returned for each utterance.
        /// The default value is `true`.
        public var shouldReportPartialResults: Bool = true
        
        /// A Boolean value that determines whether a request must keep its audio data on the device.
        public var requiresOnDeviceRecognition: Bool = false
        
        /**
         An array of phrases that should be recognized, even if they are not in the system vocabulary.
         The default value is `[]`.
         
         Use this property to specify short custom phrases that are unique to your app. You might include phrases with the names of characters, products, or places that are specific to your app. You might also include domain-specific terminology or unusual or made-up words. Assigning custom phrases to this property improves the likelihood of those phrases being recognized.
         
         Keep phrases relatively brief, limiting them to one or two words whenever possible. Lengthy phrases are less likely to be recognized. In addition, try to limit each phrase to something the user can say without pausing.
         
         Limit the total number of phrases to no more than 100.
         */
        public var contextualStrings: [String] = []
        
        /**
         A string that you use to identify sessions representing different types of interactions/speech recognition needs.
         The default value is `nil`.
         
         If one part of your app lets users speak phone numbers and another part lets users speak street addresses, consistently identifying the part of the app that makes a recognition request may help improve the accuracy of the results.
         */
        public var interactionIdentifier: String? = nil
        
        /**
         A configuration for configuring/activating/deactivating your app's `AVAudioSession` at the appropriate time.
         The default value is `.recordOnly`, which activate/deactivate a **record only** audio session when a recording session starts/stops.
         
         See `SwiftSpeech.Session.AudioSessionConfiguration` for more options.
         */
        public var audioSessionConfiguration: AudioSessionConfiguration = .recordOnly
        
        public init(
            locale: Locale = .current,
            taskHint: SFSpeechRecognitionTaskHint = .unspecified,
            shouldReportPartialResults: Bool = true,
            requiresOnDeviceRecognition: Bool = false,
            contextualStrings: [String] = [],
            interactionIdentifier: String? = nil,
            audioSessionConfiguration: AudioSessionConfiguration = .recordOnly
        ) {
            self.locale = locale
            self.taskHint = taskHint
            self.shouldReportPartialResults = shouldReportPartialResults
            self.requiresOnDeviceRecognition = requiresOnDeviceRecognition
            self.contextualStrings = contextualStrings
            self.interactionIdentifier = interactionIdentifier
            self.audioSessionConfiguration = audioSessionConfiguration
        }
    }
}

public extension SwiftSpeech.Session {
    struct AudioSessionConfiguration {
        
        public var onStartRecording: (AVAudioSession) throws -> Void
        public var onStopRecording: (AVAudioSession) throws -> Void
        
        /**
         Create a configuration using two closures.
         */
        public init(onStartRecording: @escaping (AVAudioSession) throws -> Void, onStopRecording: @escaping (AVAudioSession) throws -> Void) {
            self.onStartRecording = onStartRecording
            self.onStopRecording = onStopRecording
        }
        
        /**
         A record only configuration that is activated/deactivated when a recording session starts/stops.
         
         During the recording session, virtually all output on the system is silenced. Audio from other apps can resume after the recording session stops.
         */
        public static let recordOnly = AudioSessionConfiguration { audioSession in
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true, options: [])
        } onStopRecording: { audioSession in
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
        
        /**
         A configuration that allows both play and record and is **NOT** deactivated when a recording session stops. You should manually deactivate your session.
         
         This configuration is non-mixable, meaning it will interrupt any ongoing audio session when it is activated.
         */
        public static let playAndRecord = AudioSessionConfiguration { audioSession in
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try audioSession.setActive(true, options: [])
        } onStopRecording: { _ in }
        
        /**
         A configuration that does nothing. Use this configuration when you want to configure, activate, and deactivate your app's audio session manually.
         */
        public static let none = AudioSessionConfiguration { _ in } onStopRecording: { _ in }
        
    }
}
