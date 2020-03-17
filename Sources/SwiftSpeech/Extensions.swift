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
//    func swiftSpeechRecordOnHold(recognizedText: Binding<String>, locale: Locale = .autoupdatingCurrent, animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation) -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.RecordOnHold.StringBinding> {
//        self.modifier(SwiftSpeech.ViewModifiers.RecordOnHold.StringBinding(recognizedText: recognizedText, locale: locale, animation: animation))
//    }
//
//    func swiftSpeechRecordOnHold<S: Subject>(sessionSubject: S, locale: Locale = .autoupdatingCurrent, animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation) -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.RecordOnHold.SessionSubject<S>>
//    where S.Output == SwiftSpeech.Session?, S.Failure == Never {
//        self.modifier(SwiftSpeech.ViewModifiers.RecordOnHold.SessionSubject(sessionSubject: sessionSubject, locale: locale, animation: animation))
//    }
    
    func swiftSpeechRecordOnHold(
        locale: Locale = .autoupdatingCurrent,
        animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation
    ) -> ModifiedContent<Self, SwiftSpeech.ViewModifiers.RecordOnHold.Base> {
        self.modifier(
            SwiftSpeech.ViewModifiers.RecordOnHold.Base(
                locale: locale,
                animation: animation
            )
        )
        
    }
    
}

public extension View {
    func updating(_ textBinding: Binding<String>) -> some View {
        self.modifier(SwiftSpeech.ViewModifiers.RecordOnHold.StringBinding(recognizedText: textBinding))
    }
    
    func printRecognizedText(_ prefix: String = "") -> some View {
        let binding = Binding<String>(
            get: { "" },
            set: { print($0) }
        )
        return self.updating(binding)
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
