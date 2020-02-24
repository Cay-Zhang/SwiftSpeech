//
//  Demos.swift
//  
//
//  Created by Cay Zhang on 2020/2/23.
//

import SwiftUI
import Combine
import Speech

public extension SwiftSpeech.Demos {
    
    struct Basic : View {
        
        var locale: Locale
        
        @State private var text = "Hold to Speak"
        
        public init(locale: Locale = .autoupdatingCurrent) {
            self.locale = locale
        }
        
        public init(localeIdentifier: String) {
            self.locale = Locale(identifier: localeIdentifier)
        }
        
        public var body: some View {
            VStack(spacing: 35.0) {
                Text(text)
                    .font(.system(size: 25, weight: .bold, design: .default))
                SwiftSpeech.RecordButton()
                    .swiftSpeechRecordOnHold(
                        recognizedText: $text,
                        locale: self.locale,
                        animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)
                    )
            }.automaticEnvironmentForSpeechRecognition()
        }
        
    }
    
    struct List : View {
        
        var locale: Locale
        
        @ObservedObject var viewModel = ViewModel()
        
        class ViewModel: ObservableObject {
            @Published var list: [(id: SpeechRecognizer.ID, text: String)] = []
            var cancelBag = Set<AnyCancellable>()
            
            func recordingDidStart(session: SwiftSpeech.Session) {
                guard let publisher = session.resultPublisher else { return }
                let id = session.id
                self.list.append((id: id, text: ""))
                publisher
                    .map { (result) -> String? in
                        let newResult = result.map { (recognitionResult) -> String in
                            let string: String = recognitionResult.bestTranscription.formattedString
                            return recognitionResult.isFinal ? string : "\(string) ..."
                        }
                        return try? newResult.get()
                    }
                    .sink { [unowned self, id] string in
                        // find the index of the session
                        if let index = self.list.firstIndex(where: { pair in pair.id == id }) {
                            if let recognizedText = string {
                                self.list[index].text = recognizedText
                            } else {
                                // if error occurs, remove this session from the list
                                self.list.remove(at: index)
                            }
                        }
                    }
                    .store(in: &self.cancelBag)
            }
            
            func recordingDidCancel(session: SwiftSpeech.Session) {
                guard let index = self.list.firstIndex(where: { pair in pair.id == session.id }) else { return }
                self.list.remove(at: index)
            }
            
        }
        
        public init(locale: Locale = .autoupdatingCurrent) {
            self.locale = locale
        }
        
        public init(localeIdentifier: String) {
            self.locale = Locale(identifier: localeIdentifier)
        }
        
        public var body: some View {
            NavigationView {
                SwiftUI.List {
                    ForEach(viewModel.list, id: \.text) { pair in
                        Text(pair.text)
                    }
                }
                .overlay(
                    SwiftSpeech.RecordButton()
                        .swiftSpeechRecordOnHold(
                            recordingDidStart: self.viewModel.recordingDidStart,
                            recordingDidCancel: self.viewModel.recordingDidCancel,
                            locale: self.locale,
                            animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)
                        )
                        .padding(20),
                    alignment: .bottom
                )
                .navigationBarTitle(Text("SwiftSpeech"))
                
            }.automaticEnvironmentForSpeechRecognition()
        }
    }
}
