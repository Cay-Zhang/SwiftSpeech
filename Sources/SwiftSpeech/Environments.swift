//
//  Environments.swift
//
//
//  Created by Cay Zhang on 2020/2/16.
//

import SwiftUI
import Combine
import Speech

// isSpeechRecognitionAvailable Environment
public struct IsSpeechRecognitionAvailableKey: EnvironmentKey {
    public static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    var isSpeechRecognitionAvailable: Bool {
        get {
            return self[IsSpeechRecognitionAvailableKey.self]
        }
        set {
            self[IsSpeechRecognitionAvailableKey.self] = newValue
        }
    }
}

// isRecording Environment
public struct IsRecordingKey: EnvironmentKey {
    public static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    var isRecording: Bool {
        get {
            return self[IsRecordingKey.self]
        }
        set {
            self[IsRecordingKey.self] = newValue
        }
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
