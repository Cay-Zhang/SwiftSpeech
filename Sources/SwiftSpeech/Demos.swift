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
        
        @State private var text = "Tap to Speak"
        
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
                    .swiftSpeechToggleRecordingOnTap(locale: self.locale, animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0))
                    .onRecognize(update: $text)
                
            }.onAppear {
                SwiftSpeech.requestSpeechRecognitionAuthorization()
            }
        }
        
    }
    
    struct Colors : View {

        @State private var text = "Hold and say a color!"

        static let colorDictionary: [String : Color] = [
            "black": .black,
            "white": .white,
            "blue": .blue,
            "gray": .gray,
            "green": .green,
            "orange": .orange,
            "pink": .pink,
            "purple": .purple,
            "red": .red,
            "yellow": .yellow
        ]

        var color: Color? {
            Colors.colorDictionary
                .first { pair in
                    text.lowercased().contains(pair.key)
                }?
                .value
        }

        public init() { }

        public var body: some View {
            VStack(spacing: 35.0) {
                Text(text)
                    .font(.system(size: 25, weight: .bold, design: .default))
                    .foregroundColor(color)
                SwiftSpeech.RecordButton()
                    .accentColor(color)
                    .swiftSpeechRecordOnHold(locale: Locale(identifier: "en_US"), animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0))
                    .onRecognize(update: $text)
            }.onAppear {
                SwiftSpeech.requestSpeechRecognitionAuthorization()
            }
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
                }.overlay(
                    SwiftSpeech.RecordButton()
                        .swiftSpeechRecordOnHold(
                            locale: self.locale,
                            animation: .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0),
                            distanceToCancel: 100.0
                        ).onStartRecording(appendAction: self.viewModel.recordingDidStart(session:))
                        .onCancelRecording(appendAction: self.viewModel.recordingDidCancel(session:))
                        .padding(20),
                    alignment: .bottom
                ).navigationBarTitle(Text("SwiftSpeech"))

            }.onAppear {
                SwiftSpeech.requestSpeechRecognitionAuthorization()
            }
        }
    }
}
