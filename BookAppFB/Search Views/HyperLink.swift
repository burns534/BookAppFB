//
//  HyperLink.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/5/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI

struct HyperLink : UIViewRepresentable {

    var link : String
    var cover : String
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent : HyperLink
        
        init(_ parent: HyperLink) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            UIApplication.shared.open(URL)
            return false
        }
    }
    
    func makeCoordinator() -> Coordinator {
           return Coordinator(self)
       }
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView(frame: .zero)
        view.textColor = UIColor.systemPurple
        view.backgroundColor = UIColor.white
        view.delegate = context.coordinator
        view.isEditable = false
        view.isUserInteractionEnabled = true
        guard let p = URL(string: link) else {
            fatalError("Invalid URL")
        }
        let attributes : [NSAttributedString.Key: Any] = [
            .link: p,
            .foregroundColor: UIColor.olive,
            .underlineStyle: 0]
        let attributedText = NSMutableAttributedString(string: cover, attributes: attributes)
        view.attributedText = attributedText
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        //
    }
}
