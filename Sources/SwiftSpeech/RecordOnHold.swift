//
//  RecordOnHold.swift
//  
//
//  Created by Cay Zhang on 2020/2/16.
//

import SwiftUI
import Combine

public extension SwiftSpeech.ViewModifiers.RecordOnHold {
    
    /// Change this when the app starts to configure the default animation used for all record on hold functional components.
    static var defaultAnimation: Animation = .interactiveSpring()
    
    struct Base : ViewModifier {
        
        var locale: Locale = .autoupdatingCurrent
        var animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation
        
        @Environment(\.isSpeechRecognitionAvailable) var isSpeechRecognitionAvailable: Bool
        @State var recordingSession: SwiftSpeech.Session? = nil
        @State var isRecording: Bool = false
        
        @Environment(\.actionsOnStartRecording) var actionsOnStartRecording
        @Environment(\.actionsOnStopRecording) var actionsOnStopRecording
        @Environment(\.actionsOnCancelRecording) var actionsOnCancelRecording
        
        var gesture: some Gesture {
            let longPress = LongPressGesture(minimumDuration: 60)
                .onChanged { _ in
                    withAnimation(self.animation) { self.startRecording() }
                }
            
            let drag = DragGesture(minimumDistance: 0)
                .onEnded { value in
                    if value.translation.height < -20.0 {
                        withAnimation(self.animation) { self.cancelRecording() }
                    } else {
                        withAnimation(self.animation) { self.endRecording() }
                    }
                }
            
            return longPress.simultaneously(with: drag)
        }
        
        public func body(content: Content) -> some View {
            content
                .gesture(gesture)
                .environment(\.isEnabled, isSpeechRecognitionAvailable)
                .environment(\.isRecording, isRecording)
        }
        
        fileprivate func startRecording() {
            let id = SpeechRecognizer.ID()
            let session = SwiftSpeech.Session(id: id, locale: self.locale)
            // View update
            self.isRecording = true
            self.recordingSession = session
            try! session.startRecording()
//            self.recordingDidStart?(session)
            for action in actionsOnStartRecording {
                action(session)
            }
        }
        
        fileprivate func cancelRecording() {
            guard let session = recordingSession else { preconditionFailure("recordingSession is nil in \(#function)") }
            session.cancel()
//            self.recordingDidCancel?(session)
            for action in actionsOnCancelRecording {
                action(session)
            }
            self.isRecording = false
            self.recordingSession = nil
        }
        
        fileprivate func endRecording() {
            guard let session = recordingSession else { preconditionFailure("recordingSession is nil in \(#function)") }
            recordingSession?.stopRecording()
//            self.recordingDidStop?(session)
            for action in actionsOnStopRecording {
                action(session)
            }
            self.isRecording = false
            self.recordingSession = nil
        }
        
    }
    
    struct SessionSubject<S: Subject> : ViewModifier where S.Output == SwiftSpeech.Session?, S.Failure == Never {
        
        @State var sessionSubject: S
        
        public func body(content: Content) -> some View {
            content.onStartRecording { session in
                self.sessionSubject.send(session)
            }
        }
        
    }
    
    struct StringBinding : ViewModifier {
        
        @Binding var recognizedText: String
        
        @State private var sessionSubject = CurrentValueSubject<SwiftSpeech.Session?, Never>(nil)
        
        var publisher: AnyPublisher<String, Never> {
            sessionSubject
                .compactMap { $0?.stringPublisher }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
        
        public func body(content: Content) -> some View {
            ModifiedContent(content: content, modifier: SessionSubject(sessionSubject: sessionSubject))
                .onReceive(self.publisher) { string in
                    self.recognizedText = string
                }
        }
        
    }
    
}

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
