//
//  RecordButton.swift
//  
//
//  Created by Cay Zhang on 2020/2/16.
//

import SwiftUI
import Combine

public extension SwiftSpeech {
    /**
     An enumeration representing the state of recording. Typically used by a **View Component** and set by a **Functional Component**.
     - Note: The availability of speech recognition cannot be determined using the `State`
             and should be attained using `@Environment(\.isSpeechRecognitionAvailable)`.
     */
    enum State {
        /// Indicating there is no recording in progress.
        /// - Note: It's the default value for `@Environment(\.swiftSpeechState)`.
        case pending
        /// Indicating there is a recording in progress and the user does not intend to cancel it.
        case recording
        /// Indicating there is a recording in progress and the user intends to cancel it.
        case cancelling
    }
}

public extension SwiftSpeech {
    struct RecordButton : View {
        
        @Environment(\.swiftSpeechState) var state: SwiftSpeech.State
        @SpeechRecognitionAuthStatus var authStatus
        
        public init() { }
        
        var backgroundColor: Color {
            switch state {
            case .pending:
                return .accentColor
            case .recording:
                return .red
            case .cancelling:
                return .init(white: 0.1)
            }
        }
        
        var scale: CGFloat {
            switch state {
            case .pending:
                return 1.0
            case .recording:
                return 1.8
            case .cancelling:
                return 1.4
            }
        }
        
        public var body: some View {
            
            ZStack {
                backgroundColor
                    .animation(.easeOut(duration: 0.2))
                    .clipShape(Circle())
                    .environment(\.isEnabled, $authStatus)  // When isEnabled is false, the accent color is gray and all user interactions are disabled inside the view.
                    .zIndex(0)
                
                Image(systemName: state != .cancelling ? "waveform" : "xmark")
                    .font(.system(size: 30, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .opacity(state == .recording ? 0.8 : 1.0)
                    .padding(20)
                    .transition(.opacity)
                    .layoutPriority(2)
                    .zIndex(1)
                
            }
                .scaleEffect(scale)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 5, x: 0, y: 3)
               
        }
        
    }
}

struct RecordButton_Previews: PreviewProvider {
    static var previews: some View {
        SwiftSpeech.Demos.Basic()
    }
}
