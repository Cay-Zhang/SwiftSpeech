//
//  Authorization.swift
//  
//
//  Created by Cay Zhang on 2020/7/22.
//

import SwiftUI
import Combine
import Speech

extension SwiftSpeech {
    
    public static func requestSpeechRecognitionAuthorization() {
        AuthorizationCenter.shared.requestSpeechRecognitionAuthorization()
    }
    
    class AuthorizationCenter: ObservableObject {
        @Published var speechRecognitionAuthorizationStatus: SFSpeechRecognizerAuthorizationStatus = SFSpeechRecognizer.authorizationStatus()
        
        func requestSpeechRecognitionAuthorization() {
            // Asynchronously make the authorization request.
            SFSpeechRecognizer.requestAuthorization { authStatus in
                if self.speechRecognitionAuthorizationStatus != authStatus {
                    DispatchQueue.main.async {
                        self.speechRecognitionAuthorizationStatus = authStatus
                    }
                }
            }
        }
        
        static let shared = AuthorizationCenter()
    }
}

@propertyWrapper public struct SpeechRecognitionAuthStatus: DynamicProperty {
    @ObservedObject var authCenter = SwiftSpeech.AuthorizationCenter.shared
    
    let trueValues: Set<SFSpeechRecognizerAuthorizationStatus>
    
    public var wrappedValue: SFSpeechRecognizerAuthorizationStatus {
        SwiftSpeech.AuthorizationCenter.shared.speechRecognitionAuthorizationStatus
    }
    
    public init(trueValues: Set<SFSpeechRecognizerAuthorizationStatus> = [.authorized]) {
        self.trueValues = trueValues
    }
    
    public var projectedValue: Bool {
        self.trueValues.contains(SwiftSpeech.AuthorizationCenter.shared.speechRecognitionAuthorizationStatus)
    }
}

extension SFSpeechRecognizerAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        "\(rawValue)"
    }
}
