//
//  ImageDetailView.swift
//  ImageViewingApp
//
//  Created by Matthew Braniff on 5/8/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageDetailView: View {
    @State private var magnification: CGFloat = 1
    @GestureState private var magnificationState: CGFloat = 1
    @State private var offset = CGSize.zero
    private let minMagnification: CGFloat = 0.5
    var image: URL?

    var visibleMagnification: CGFloat {
        magnification * magnificationState
    }

    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .updating($magnificationState) { value, state, _ in
                state = value.magnification
            }
            .onEnded { value in
                magnification = max(magnification * value.magnification, minMagnification)
            }
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged({ value in
                offset = CGSize(width: offset.width + value.translation.width, height: offset.height + value.translation.height)
            })
            .onEnded { value in
                offset = CGSize(width: offset.width + value.translation.width, height: offset.height + value.translation.height)
            }
    }
    
    var body: some View {
        WebImage(url: image) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(dragGesture.simultaneously(with: magnifyGesture))
        .offset(offset)
        .scaleEffect(visibleMagnification)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    reset()
                } label: {
                    Image(systemName: "square.arrowtriangle.4.outward")
                }
            }
        }
    }
    
    private func reset() {
        magnification = 1.0
        offset = .zero
    }
}
