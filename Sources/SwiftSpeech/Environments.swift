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
    struct SwiftSpeechState: EnvironmentKey {
        static let defaultValue: SwiftSpeech.State = .pending
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
    
    var swiftSpeechState: SwiftSpeech.State {
        get { self[SwiftSpeech.EnvironmentKeys.SwiftSpeechState.self] }
        set { self[SwiftSpeech.EnvironmentKeys.SwiftSpeechState.self] = newValue }
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
