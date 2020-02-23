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
    func swiftSpeechRecordOnHold(recognizedText: Binding<String>, locale: Locale = .autoupdatingCurrent, animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation) -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.RecordOnHold.StringBinding> {
        self.modifier(SwiftSpeech.ViewModifiers.RecordOnHold.StringBinding(recognizedText: recognizedText, locale: locale, animation: animation))
    }
    
    func swiftSpeechRecordOnHold<S: Subject>(sessionSubject: S, locale: Locale = .autoupdatingCurrent, animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation) -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.RecordOnHold.SessionSubject<S>>
    where S.Output == SwiftSpeech.Session?, S.Failure == Never {
        self.modifier(SwiftSpeech.ViewModifiers.RecordOnHold.SessionSubject(sessionSubject: sessionSubject, locale: locale, animation: animation))
    }
    
    func swiftSpeechRecordOnHold(
        recordingDidStart: ((_ session: SwiftSpeech.Session) -> Void)?,
        recordingDidStop: ((_ session: SwiftSpeech.Session) -> Void)? = nil,
        recordingDidCancel: ((_ session: SwiftSpeech.Session) -> Void)? = nil,
        locale: Locale = .autoupdatingCurrent,
        animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation
    ) -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.RecordOnHold.Base> {
        self.modifier(
            SwiftSpeech.ViewModifiers.RecordOnHold.Base(
                locale: locale,
                animation: animation,
                recordingDidStart: recordingDidStart,
                recordingDidStop: recordingDidStop,
                recordingDidCancel: recordingDidCancel
            )
        )
        
    }
    
}

public extension View {
    /// Returns a view wrapping self that automatically requests speech recognition authorization on appear and sets the corresponding environment value.
    func automaticEnvironmentForSpeechRecognition() -> some View {
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
