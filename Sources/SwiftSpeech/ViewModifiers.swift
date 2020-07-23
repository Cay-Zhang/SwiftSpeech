//
//  ViewModifiers.swift
//  
//
//  Created by Cay Zhang on 2020/2/16.
//

import SwiftUI
import Combine
import Speech

public extension SwiftSpeech {
    struct FunctionalComponentDelegate: DynamicProperty {
        
        @Environment(\.actionsOnStartRecording) var actionsOnStartRecording
        @Environment(\.actionsOnStopRecording) var actionsOnStopRecording
        @Environment(\.actionsOnCancelRecording) var actionsOnCancelRecording
        
        public init() { }
        
        mutating public func update() {
            _actionsOnStartRecording.update()
            _actionsOnStopRecording.update()
            _actionsOnCancelRecording.update()
        }
        
        public func onStartRecording(session: SwiftSpeech.Session) {
            for action in actionsOnStartRecording {
                action(session)
            }
        }
        
        public func onStopRecording(session: SwiftSpeech.Session) {
            for action in actionsOnStopRecording {
                action(session)
            }
        }
        
        public func onCancelRecording(session: SwiftSpeech.Session) {
            for action in actionsOnCancelRecording {
                action(session)
            }
        }
        
    }
}

// MARK: - Functional Components
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
        
        var delegate = SwiftSpeech.FunctionalComponentDelegate()
        
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
            delegate.onStartRecording(session: session)
        }
        
        fileprivate func cancelRecording() {
            guard let session = recordingSession else { preconditionFailure("recordingSession is nil in \(#function)") }
            session.cancel()
            delegate.onCancelRecording(session: session)
            self.viewComponentState = .pending
            self.recordingSession = nil
        }
        
        fileprivate func endRecording() {
            guard let session = recordingSession else { preconditionFailure("recordingSession is nil in \(#function)") }
            recordingSession?.stopRecording()
            delegate.onStopRecording(session: session)
            self.viewComponentState = .pending
            self.recordingSession = nil
        }
        
    }
    
    /**
     `viewComponentState` will never be `.cancelling` here.
     */
    struct ToggleRecordingOnTap : ViewModifier {
        
        public init(locale: Locale = .autoupdatingCurrent, animation: Animation = SwiftSpeech.defaultAnimation) {
            self.locale = locale
            self.animation = animation
        }
        
        var locale: Locale
        var animation: Animation
        
        @Environment(\.isSpeechRecognitionAvailable) var isSpeechRecognitionAvailable: Bool
        @State var recordingSession: SwiftSpeech.Session? = nil
        @State var viewComponentState: SwiftSpeech.State = .pending
        
        var delegate = SwiftSpeech.FunctionalComponentDelegate()
        
        var gesture: some Gesture {
            TapGesture()
                .onEnded {
                    withAnimation(self.animation) {
                        if self.viewComponentState == .pending {  // if not recording
                            self.startRecording()
                        } else {  // if recording
                            self.endRecording()
                        }
                    }
                }
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
            delegate.onStartRecording(session: session)
        }
        
        fileprivate func endRecording() {
            guard let session = recordingSession else { preconditionFailure("recordingSession is nil in \(#function)") }
            recordingSession?.stopRecording()
            delegate.onStopRecording(session: session)
            self.viewComponentState = .pending
            self.recordingSession = nil
        }
        
    }
    
}

// MARK: - SwiftSpeech Modifiers
public extension SwiftSpeech.ViewModifiers {
    
    struct OnRecognize : ViewModifier {
        
        @State var model: Model
        
        init(isPartialResultIncluded: Bool, textHandler: @escaping (String) -> Void) {
            self._model = State(initialValue: Model(isPartialResultIncluded: isPartialResultIncluded, textHandler: textHandler))
        }
        
        init(isPartialResultIncluded: Bool, resultHandler: @escaping (Result<SFSpeechRecognitionResult, Error>) -> Void) {
            self._model = State(initialValue: Model(isPartialResultIncluded: isPartialResultIncluded, resultHandler: resultHandler))
        }
        
        public func body(content: Content) -> some View {
            content
                .onStartRecording(sendSessionTo: model.sessionSubject)
                .onCancelRecording(sendSessionTo: model.cancelSubject)
        }
        
        class Model {
            let sessionSubject = PassthroughSubject<SwiftSpeech.Session, Never>()
            let cancelSubject = PassthroughSubject<SwiftSpeech.Session, Never>()
            let resultHandler: (Result<SFSpeechRecognitionResult, Error>) -> Void
            var cancelBag = Set<AnyCancellable>()
            
            init(isPartialResultIncluded: Bool, resultHandler: @escaping (Result<SFSpeechRecognitionResult, Error>) -> Void) {
                self.resultHandler = resultHandler
                self.subscribe(isPartialResultIncluded: isPartialResultIncluded, resultHandler: resultHandler)
            }

            init(isPartialResultIncluded: Bool, textHandler: @escaping (String) -> Void) {
                self.resultHandler = { result in
                    if let result = try? result.get() {
                        textHandler(result.bestTranscription.formattedString)
                    }
                }
                self.subscribe(isPartialResultIncluded: isPartialResultIncluded, resultHandler: resultHandler)
            }
            
            func subscribe(isPartialResultIncluded: Bool, resultHandler: @escaping (Result<SFSpeechRecognitionResult, Error>) -> Void) {
                sessionSubject
                    .compactMap { (session: SwiftSpeech.Session) -> AnyPublisher<Result<SFSpeechRecognitionResult, Error>, Never>? in
                        session.resultPublisher?
                            .filter { result in
                                if isPartialResultIncluded {
                                    return true
                                } else if let recognitionResult = try? result.get() {
                                    return recognitionResult.isFinal
                                } else {
                                    return false
                                }
                            }
                            .eraseToAnyPublisher()
                    }
                    .merge(with:
                        cancelSubject
                            .map { _ in Empty<Result<SFSpeechRecognitionResult, Error>, Never>(completeImmediately: true).eraseToAnyPublisher() }
                    )
                    .switchToLatest()
                    .sink(receiveValue: resultHandler)
                    .store(in: &cancelBag)
            }
            
        }
        
    }
    
}

