//
//  RecordButton.swift
//  
//
//  Created by Cay Zhang on 2020/2/16.
//

import SwiftUI
import Combine

public extension SwiftSpeech {
    struct RecordButton : View {
        
        @Environment(\.isRecording) var isRecording: Bool
        @Environment(\.isSpeechRecognitionAvailable) var isSpeechRecognitionAvailable: Bool
        
        public init() { }
        
        public var body: some View {
            Image(systemName: "waveform")
                .font(.system(size: 30, weight: .medium, design: .default))
                .foregroundColor(.white)
                .opacity(isRecording ? 0.7 : 1.0)
                .padding(20)
                .background(isRecording ? Color.red : Color.accentColor)  // Accent color is gray when isEnabled is set to false.
                .clipShape(Circle())
                .scaleEffect(isRecording ? 1.8 : 1.0)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 5, x: 0, y: 3)
                .environment(\.isEnabled, isSpeechRecognitionAvailable)  // When isEnabled is false, the accent color is gray and all user interactions are disabled inside the view.
        }
        
    }
}

struct RecordButton_Previews: PreviewProvider {
    static var previews: some View {
        SwiftSpeech.RecordButton()
    }
}
