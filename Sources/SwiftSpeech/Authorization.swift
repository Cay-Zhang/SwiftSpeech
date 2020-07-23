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
        @Published var speechRecognitionAuthorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
        
        func requestSpeechRecognitionAuthorization() {
            // Asynchronously make the authorization request.
            SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
                DispatchQueue.main.async {
                    self?.speechRecognitionAuthorizationStatus = authStatus
                }
            }
        }
        
        static let shared = AuthorizationCenter()
    }
}

@propertyWrapper public struct SpeechRecognitionAvailability: DynamicProperty {
    @ObservedObject var authCenter = SwiftSpeech.AuthorizationCenter.shared
    
    public var wrappedValue: SFSpeechRecognizerAuthorizationStatus {
        SwiftSpeech.AuthorizationCenter.shared.speechRecognitionAuthorizationStatus
    }
    
    public init() { }
}

extension SFSpeechRecognizerAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        "\(rawValue)"
    }
}
