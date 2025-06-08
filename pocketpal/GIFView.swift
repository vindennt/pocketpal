//
//  GIFView.swift
//
//
//  Created by Raphaël Wach on 03/01/2024.
//  Remixed by vindennt on 08/06/2025.
//

import SwiftUI

public struct GIFView: View {
    
    @ObservedObject private var gif: GIF
    private var scale: CGFloat
    
    public var body: some View {
        if let image = gif.image {
            Image(image, scale: scale, label: Text(""))
//                .resizable()
                .scaledToFit()
        }
    }
    
    public init(data: Data, scale: CGFloat = 1.0) {
        self.gif = GIF(data)
        self.scale = scale
    }
}
