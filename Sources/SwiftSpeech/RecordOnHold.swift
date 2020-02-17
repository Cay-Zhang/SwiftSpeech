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
        var recordingDidStart: ((_ speechRecognizerID: SpeechRecognizer.ID?) -> Void)?
        var recordingDidStop: ((_ speechRecognizerID: SpeechRecognizer.ID?) -> Void)?
        var recordingDidCancel: ((_ speechRecognizerID: SpeechRecognizer.ID?) -> Void)?
        
        @Environment(\.isSpeechRecognitionAvailable) var isSpeechRecognitionAvailable: Bool
        @State var recordingSpeechRecognizerID: SpeechRecognizer.ID? = nil
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
            
            // View update
            self.isRecording = true
            self.recordingSpeechRecognizerID = id
            
            let speechRecognizer = SpeechRecognizer.new(id: id, locale: self.locale)
            try! speechRecognizer.startRecording()
            self.recordingDidStart?(id)
        }
        
        fileprivate func cancelRecording() {
            SpeechRecognizer.recognizer(withID: recordingSpeechRecognizerID)?.cancel()
            self.recordingDidCancel?(recordingSpeechRecognizerID)
            self.isRecording = false
            self.recordingSpeechRecognizerID = nil
        }
        
        fileprivate func endRecording() {
            SpeechRecognizer.recognizer(withID: recordingSpeechRecognizerID)?.stopRecording()
            self.recordingDidStop?(recordingSpeechRecognizerID)
            self.isRecording = false
            self.recordingSpeechRecognizerID = nil
        }
        
    }
    
    struct SpeechSubject<S: Subject> : ViewModifier where S.Output == SpeechRecognizer.ID?, S.Failure == Never {
        
        @State var speechSubject: S
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
        
        private func recordingDidStart(_ speechRecognizerID: SpeechRecognizer.ID?) -> Void {
            self.speechSubject.send(speechRecognizerID)
        }
        
        private func recordingDidStop(_ speechRecognizerID: SpeechRecognizer.ID?) -> Void { }
        
        private func recordingDidCancel(_ speechRecognizerID: SpeechRecognizer.ID?) -> Void { }
        
    }
    
    struct StringBinding : ViewModifier {
        
        @Binding var recognizedText: String
        var locale: Locale = .autoupdatingCurrent
        var animation: Animation = SwiftSpeech.ViewModifiers.RecordOnHold.defaultAnimation
        
        @State private var speechSubject = CurrentValueSubject<SpeechRecognizer.ID?, Never>(nil)
        
        var publisher: AnyPublisher<String, Never> {
            speechSubject
                .mapResolved(\.stringPublisher)
                .switchToLatest()
                .eraseToAnyPublisher()
        }
        
        public func body(content: Content) -> some View {
            ModifiedContent(content: content, modifier: SpeechSubject(speechSubject: speechSubject, locale: locale, animation: animation))
                .onReceive(self.publisher) { string in
                    self.recognizedText = string
                }
        }
        
    }
    
}
