//
//  RecordOnHold.swift
//  
//
//  Created by Cay Zhang on 2020/2/16.
//

import SwiftUI
import Combine

public extension SwiftSpeech.ViewModifiers.RecordOnHold {
    
    static var defaultAnimation: Animation = .interactiveSpring()
    
    struct Base : ViewModifier {
        
        var locale: Locale = .autoupdatingCurrent
        var animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation
        var recordingDidStart: ((_ session: SwiftSpeech.Session) -> Void)?
        var recordingDidStop: ((_ session: SwiftSpeech.Session) -> Void)?
        var recordingDidCancel: ((_ session: SwiftSpeech.Session) -> Void)?
        
        @Environment(\.isSpeechRecognitionAvailable) var isSpeechRecognitionAvailable: Bool
        @State var recordingSession: SwiftSpeech.Session? = nil
        @State var isRecording: Bool = false
        
        
        
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
            self.recordingDidStart?(session)
        }
        
        fileprivate func cancelRecording() {
            guard let session = recordingSession else { preconditionFailure("recordingSession is nil in \(#function)") }
            session.cancel()
            self.recordingDidCancel?(session)
            self.isRecording = false
            self.recordingSession = nil
        }
        
        fileprivate func endRecording() {
            guard let session = recordingSession else { preconditionFailure("recordingSession is nil in \(#function)") }
            recordingSession?.stopRecording()
            self.recordingDidStop?(session)
            self.isRecording = false
            self.recordingSession = nil
        }
        
    }
    
    struct SessionSubject<S: Subject> : ViewModifier where S.Output == SwiftSpeech.Session?, S.Failure == Never {
        
        @State var sessionSubject: S
        var locale: Locale = .autoupdatingCurrent
        var animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation
        
        public func body(content: Content) -> some View {
            ModifiedContent(content: content, modifier: Base(
                locale: locale,
                animation: animation,
                recordingDidStart: recordingDidStart(_:),
                recordingDidStop: recordingDidStop(_:),
                recordingDidCancel: recordingDidCancel(_:))
            )
        }
        
        private func recordingDidStart(_ session: SwiftSpeech.Session) -> Void {
            self.sessionSubject.send(session)
        }
        
        private func recordingDidStop(_ session: SwiftSpeech.Session) -> Void { }
        
        private func recordingDidCancel(_ session: SwiftSpeech.Session) -> Void { }
        
    }
    
    struct StringBinding : ViewModifier {
        
        @Binding var recognizedText: String
        var locale: Locale = .autoupdatingCurrent
        var animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation
        
        @State private var sessionSubject = CurrentValueSubject<SwiftSpeech.Session?, Never>(nil)
        
        var publisher: AnyPublisher<String, Never> {
            sessionSubject
                .compactMap { $0?.stringPublisher }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
        
        public func body(content: Content) -> some View {
            ModifiedContent(content: content, modifier: SessionSubject(sessionSubject: sessionSubject, locale: locale, animation: animation))
                .onReceive(self.publisher) { string in
                    self.recognizedText = string
                }
        }
        
    }
    
}
