//
//  File.swift
//  
//
//  Created by Cay Zhang on 2020/7/22.
//

import SwiftUI

@available(iOS 14.0, *)
struct LibraryContent: LibraryContentProvider {
    @LibraryContentBuilder
    var views: [LibraryItem] {
        LibraryItem(
            SwiftSpeech.RecordButton(),
            title: "Record Button"
        )
        
        LibraryItem(
            SwiftSpeech.Demos.Basic(locale: .current),
            title: "Demo - Basic"
        )
        
        LibraryItem(
            SwiftSpeech.Demos.Colors(),
            title: "Demo - Colors"
        )
        
        LibraryItem(
            SwiftSpeech.Demos.List(locale: .current),
            title: "Demos - List"
        )
    }
    
    @LibraryContentBuilder
    func modifiers(base: AnyView) -> [LibraryItem] {
        LibraryItem(
            base.onAppear {
                SwiftSpeech.requestSpeechRecognitionAuthorization()
            },
            title: "Request Speech Recognition Authorization on Appear"
        )
    }
}
