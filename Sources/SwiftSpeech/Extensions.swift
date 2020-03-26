//
//  Extensions.swift
//  
//
//  Created by Cay Zhang on 2020/2/16.
//

import SwiftUI
import Combine
import Speech

public extension View {
    func onStartRecording(appendAction actionToAppend: @escaping (_ session: SwiftSpeech.Session) -> Void) -> some View {
        self.transformEnvironment(\.actionsOnStartRecording) { actions in
            actions.insert(actionToAppend, at: 0)
        }
    }
    
    func onStopRecording(appendAction actionToAppend: @escaping (_ session: SwiftSpeech.Session) -> Void) -> some View {
        self.transformEnvironment(\.actionsOnStopRecording) { actions in
            actions.insert(actionToAppend, at: 0)
        }
    }
    
    func onCancelRecording(appendAction actionToAppend: @escaping (_ session: SwiftSpeech.Session) -> Void) -> some View {
        self.transformEnvironment(\.actionsOnCancelRecording) { actions in
            actions.insert(actionToAppend, at: 0)
        }
    }
}

public extension View {
    func onStartRecording<S: Subject>(sendSessionTo subject: S) -> some View where S.Output == SwiftSpeech.Session {
        self.onStartRecording { session in
            subject.send(session)
        }
    }
    
    func onStartRecording<S: Subject>(sendSessionTo subject: S) -> some View where S.Output == SwiftSpeech.Session? {
        self.onStartRecording { session in
            subject.send(session)
        }
    }
    
    func onStopRecording<S: Subject>(sendSessionTo subject: S) -> some View where S.Output == SwiftSpeech.Session {
        self.onStopRecording { session in
            subject.send(session)
        }
    }
    
    func onStopRecording<S: Subject>(sendSessionTo subject: S) -> some View where S.Output == SwiftSpeech.Session? {
        self.onStopRecording { session in
            subject.send(session)
        }
    }
    
    func onCancelRecording<S: Subject>(sendSessionTo subject: S) -> some View where S.Output == SwiftSpeech.Session {
        self.onCancelRecording { session in
            subject.send(session)
        }
    }
    
    func onCancelRecording<S: Subject>(sendSessionTo subject: S) -> some View where S.Output == SwiftSpeech.Session? {
        self.onCancelRecording { session in
            subject.send(session)
        }
    }
}

public extension View {
    
    func swiftSpeechRecordOnHold(
        locale: Locale = .autoupdatingCurrent,
        animation: Animation = SwiftSpeech.defaultAnimation
    ) -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.RecordOnHold> {
        self.modifier(
            SwiftSpeech.ViewModifiers.RecordOnHold(
                locale: locale,
                animation: animation
            )
        )
        
    }
    
    func onRecognize(_ textHandler: @escaping (String) -> Void) -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.OnRecognize> {
        self.modifier(SwiftSpeech.ViewModifiers.OnRecognize(textHandler: textHandler))
    }
    
    func onRecognize(update textBinding: Binding<String>) -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.OnRecognize> {
        self.onRecognize { text in
            textBinding.wrappedValue = text
        }
    }
    
    func printRecognizedText() -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.OnRecognize> {
        self.onRecognize { text in
            print("[SwiftSpeech] Recognized Text: \(text)")
        }
    }
}

public extension View {
    /// Returns a view wrapping self that automatically requests speech recognition authorization on appear and sets the corresponding environment value.
    /// Add this after your root view or the view you want to use speech recognition in.
    /// Currently, it only sets up the `isSpeechRecognitionAvailable` environment for the view.
    func automaticEnvironmentForSpeechRecognition() -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.AutomaticEnvironmentForSpeechRecognition> {
        ModifiedContent(content: self, modifier: SwiftSpeech.ViewModifiers.AutomaticEnvironmentForSpeechRecognition())
    }
}

public extension Subject where Output == SpeechRecognizer.ID?, Failure == Never {
    
    func mapResolved<T>(_ transform: @escaping (SpeechRecognizer) -> T) -> Publishers.CompactMap<Self, T> {
        return self
            .compactMap { (id) -> T? in
                if let recognizer = SpeechRecognizer.recognizer(withID: id) {
                    return transform(recognizer)
                } else {
                    return nil
                }
            }
    }
    
    func mapResolved<T>(_ keyPath: KeyPath<SpeechRecognizer, T>) -> Publishers.CompactMap<Self, T> {
        return self
            .compactMap { (id) -> T? in
                if let recognizer = SpeechRecognizer.recognizer(withID: id) {
                    return recognizer[keyPath: keyPath]
                } else {
                    return nil
                }
            }
    }
    
}

public extension SwiftSpeech {
    static func supportedLocales() -> Set<Locale> {
        SFSpeechRecognizer.supportedLocales()
    }
}
