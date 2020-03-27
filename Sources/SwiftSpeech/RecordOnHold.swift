//
//  RecordOnHold.swift
//  
//
//  Created by Cay Zhang on 2020/2/16.
//

import SwiftUI
import Combine

public extension SwiftSpeech.ViewModifiers {
    
    struct RecordOnHold : ViewModifier {
        
        public init(locale: Locale = .autoupdatingCurrent, animation: Animation = SwiftSpeech.defaultAnimation, distanceToCancel: CGFloat = 50.0) {
            self.locale = locale
            self.animation = animation
            self.distanceToCancel = distanceToCancel
        }
        
        var locale: Locale
        var animation: Animation
        var distanceToCancel: CGFloat
        
        @Environment(\.isSpeechRecognitionAvailable) var isSpeechRecognitionAvailable: Bool
        @State var recordingSession: SwiftSpeech.Session? = nil
        @State var viewComponentState: SwiftSpeech.State = .pending
        
        @Environment(\.actionsOnStartRecording) var actionsOnStartRecording
        @Environment(\.actionsOnStopRecording) var actionsOnStopRecording
        @Environment(\.actionsOnCancelRecording) var actionsOnCancelRecording
        
        var gesture: some Gesture {
            let longPress = LongPressGesture(minimumDuration: 60)
                .onChanged { _ in
                    withAnimation(self.animation, self.startRecording)
                }
            
            let drag = DragGesture(minimumDistance: 0)
                .onChanged { value in
                    withAnimation(self.animation) {
                        if value.translation.height < -self.distanceToCancel {
                            self.viewComponentState = .cancelling
                        } else {
                            self.viewComponentState = .recording
                        }
                    }
                }
                .onEnded { value in
                    if value.translation.height < -self.distanceToCancel {
                        withAnimation(self.animation, self.cancelRecording)
                    } else {
                        withAnimation(self.animation, self.endRecording)
                    }
                }
            
            return longPress.simultaneously(with: drag)
        }
        
        public func body(content: Content) -> some View {
            content
                .gesture(gesture, including: isSpeechRecognitionAvailable ? .gesture : .none)
                .environment(\.swiftSpeechState, viewComponentState)
        }
        
        fileprivate func startRecording() {
            let id = SpeechRecognizer.ID()
            let session = SwiftSpeech.Session(id: id, locale: self.locale)
            // View update
            self.viewComponentState = .recording
            self.recordingSession = session
            try! session.startRecording()
            for action in actionsOnStartRecording {
                action(session)
            }
        }
        
        fileprivate func cancelRecording() {
            guard let session = recordingSession else { preconditionFailure("recordingSession is nil in \(#function)") }
            session.cancel()
            for action in actionsOnCancelRecording {
                action(session)
            }
            self.viewComponentState = .pending
            self.recordingSession = nil
        }
        
        fileprivate func endRecording() {
            guard let session = recordingSession else { preconditionFailure("recordingSession is nil in \(#function)") }
            recordingSession?.stopRecording()
            for action in actionsOnStopRecording {
                action(session)
            }
            self.viewComponentState = .pending
            self.recordingSession = nil
        }
        
    }
    

    
}

public extension SwiftSpeech.ViewModifiers {
    
    struct OnRecognize : ViewModifier {
        
        let textHandler: (String) -> Void
        
        @State private var sessionSubject = CurrentValueSubject<SwiftSpeech.Session?, Never>(nil)
        
        var publisher: AnyPublisher<String, Never> {
            sessionSubject
                .compactMap { $0?.stringPublisher }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
        
        public func body(content: Content) -> some View {
            content
                .onStartRecording(sendSessionTo: sessionSubject)
                .onReceive(self.publisher) { string in
                    self.textHandler(string)
                }
        }
        
    }
    
}

