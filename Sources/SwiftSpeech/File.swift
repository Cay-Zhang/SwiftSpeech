//
//  File.swift
//  
//
//  Created by Cay Zhang on 2020/8/4.
//

import SwiftUI
import Speech

public struct SwiftSpeechView<Content: View>: View {
    public var body: Content
    init(_ body: Content) { self.body = body }
    
    func swiftSpeechModifier<Modifier: ViewModifier>(_ modifier: Modifier) -> SwiftSpeechView<ModifiedContent<Content, Modifier>> {
        SwiftSpeechView<ModifiedContent<Content, Modifier>>(ModifiedContent<Content, Modifier>(content: body, modifier: modifier))
    }
}

public extension View {
    func swiftSpeech() -> SwiftSpeechView<Self> {
        SwiftSpeechView(self)
    }
}

public extension SwiftSpeechView {
    func onStartRecording(appendAction actionToAppend: @escaping (_ session: SwiftSpeech.Session) -> Void) -> SwiftSpeechView<ModifiedContent<Content, _EnvironmentKeyTransformModifier<[(SwiftSpeech.Session) -> Void]>>> {
        swiftSpeechModifier(
            _EnvironmentKeyTransformModifier(keyPath: \.actionsOnStartRecording) { actions in
                actions.insert(actionToAppend, at: 0)
            }
        )
    }
    
    func toggleRecordingOnTap(
        locale: Locale = .autoupdatingCurrent,
        animation: Animation = SwiftSpeech.defaultAnimation
    ) -> SwiftSpeechView<ModifiedContent<Content, SwiftSpeech.ViewModifiers.ToggleRecordingOnTap>> {
        swiftSpeechModifier(
            SwiftSpeech.ViewModifiers.ToggleRecordingOnTap(
                locale: locale,
                animation: animation
            )
        )
    }
    
    func onRecognizeLatest(
        includePartialResults isPartialResultIncluded: Bool = true,
        handleResult resultHandler: @escaping (SwiftSpeech.Session, SFSpeechRecognitionResult) -> Void,
        handleError errorHandler: @escaping (SwiftSpeech.Session, Error) -> Void
    ) -> SwiftSpeechView<ModifiedContent<Content, SwiftSpeech.ViewModifiers.OnRecognize>> {
        swiftSpeechModifier(
            SwiftSpeech.ViewModifiers.OnRecognize(
                isPartialResultIncluded: isPartialResultIncluded,
                switchToLatest: true,
                resultHandler: resultHandler,
                errorHandler: errorHandler
            )
        )
    }
}
