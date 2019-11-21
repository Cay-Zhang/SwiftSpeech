//
//  SpeechRecognizer+SwiftUI.swift
//  
//
//  Created by Cay Zhang on 2019/11/20.
//

import SwiftUI
import Speech

struct IsSpeechRecognitionAvailableKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isSpeechRecognitionAvailable: Bool {
        get {
            return self[IsSpeechRecognitionAvailableKey.self]
        }
        set {
            self[IsSpeechRecognitionAvailableKey.self] = newValue
        }
    }
}

struct AutomaticEnvironmentForSpeechRecognitionModifier : ViewModifier {
    
    @State var isSpeechRecognitionAvailable: Bool = false
    
    func body(content: Content) -> some View {
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

public extension View {
    /// Returns a view wrapping self that automatically requests speech recognition authorization on appear and sets the corresponding environment value.
    func automaticEnvironmentForSpeechRecognition() -> some View {
        ModifiedContent(content: self, modifier: AutomaticEnvironmentForSpeechRecognitionModifier())
    }
}
