//
//  RotatingImagesAroundCircle.swift
//
//
//  Created by harsh vishwakarma on 28/12/23.
//

import SwiftUI

// TODO: Rename
struct RotatingImagesAroundCircle: View {
    private let imageCount = 16
    private let imageSize: CGFloat = 32.0
    private let padding: CGFloat = 42
    
    @State private var rotationAngle: Double = 0.0
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack(alignment: .center) {
                ForEach(0..<imageCount) { index in
                    Image("equipment-\(index+1)", bundle: Bundle.module) // Replace with your image name
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize, height: imageSize)
                        .rotationEffect(.degrees(-rotationAngle))
                        .offset(
                            x: (geometry.size.width - padding) * 0.5 * cos((2 * .pi / CGFloat(imageCount)) * CGFloat(index)),
                            y: (geometry.size.width - padding) * 0.5 * sin((2 * .pi / CGFloat(imageCount)) * CGFloat(index))
                        )
                }
                .frame(width: geometry.size.width, height: geometry.size.width)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(.linear(duration: 30)
                        .repeatForever(autoreverses: false)) {
                            rotationAngle = 360.0
                        }
                }
                
                Color.clear
            }
        })
    }
}
