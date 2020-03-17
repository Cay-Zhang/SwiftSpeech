//
//  Environments.swift
//
//
//  Created by Cay Zhang on 2020/2/16.
//

import SwiftUI
import Combine
import Speech

extension SwiftSpeech.EnvironmentKeys {
    struct IsSpeechRecognitionAvailable: EnvironmentKey {
        static let defaultValue: Bool = false
    }
    
    struct IsRecording: EnvironmentKey {
        static let defaultValue: Bool = false
    }
    
    struct ActionsOnStartRecording: EnvironmentKey {
        static let defaultValue: [(_ session: SwiftSpeech.Session) -> Void] = []
    }
    
    struct ActionsOnStopRecording: EnvironmentKey {
        static let defaultValue: [(_ session: SwiftSpeech.Session) -> Void] = []
    }
    
    struct ActionsOnCancelRecording: EnvironmentKey {
        static let defaultValue: [(_ session: SwiftSpeech.Session) -> Void] = []
    }
}

public extension EnvironmentValues {
    var isSpeechRecognitionAvailable: Bool {
        get {
            return self[SwiftSpeech.EnvironmentKeys.IsSpeechRecognitionAvailable.self]
        }
        set {
            self[SwiftSpeech.EnvironmentKeys.IsSpeechRecognitionAvailable.self] = newValue
        }
    }
    
    var isRecording: Bool {
        get {
            return self[SwiftSpeech.EnvironmentKeys.IsRecording.self]
        }
        set {
            self[SwiftSpeech.EnvironmentKeys.IsRecording.self] = newValue
        }
    }
    
    var actionsOnStartRecording: [(_ session: SwiftSpeech.Session) -> Void] {
        get { self[SwiftSpeech.EnvironmentKeys.ActionsOnStartRecording.self] }
        set { self[SwiftSpeech.EnvironmentKeys.ActionsOnStartRecording.self] = newValue }
    }
    
    var actionsOnStopRecording: [(_ session: SwiftSpeech.Session) -> Void] {
        get { self[SwiftSpeech.EnvironmentKeys.ActionsOnStopRecording.self] }
        set { self[SwiftSpeech.EnvironmentKeys.ActionsOnStopRecording.self] = newValue }
    }
    
    var actionsOnCancelRecording: [(_ session: SwiftSpeech.Session) -> Void] {
        get { self[SwiftSpeech.EnvironmentKeys.ActionsOnCancelRecording.self] }
        set { self[SwiftSpeech.EnvironmentKeys.ActionsOnCancelRecording.self] = newValue }
    }
}

public extension SwiftSpeech.ViewModifiers {
    struct AutomaticEnvironmentForSpeechRecognition : ViewModifier {
        
        @State private var isSpeechRecognitionAvailable: Bool = false
        
        public func body(content: Content) -> some View {
            content
                .environment(\.isSpeechRecognitionAvailable, isSpeechRecognitionAvailable)
                .onAppear(perform: requestSpeechRecognitionAuthorization)
        }
        
        private func requestSpeechRecognitionAuthorization() {
            // Asynchronously make the authorization request.
            SFSpeechRecognizer.requestAuthorization { authStatus in
                // Divert to the app's main thread so that the UI
                // can be updated.
                OperationQueue.main.addOperation {
                    switch authStatus {
                    case .authorized:
                        self.isSpeechRecognitionAvailable = true
                    case .denied, .restricted, .notDetermined:
                        self.isSpeechRecognitionAvailable = false
                    default:
                        self.isSpeechRecognitionAvailable = false
                    }
                }
            }
        }
        
    }

}
