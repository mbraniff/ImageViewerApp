//
//  ImageSearchGrid.swift
//  ImageViewingApp
//
//  Created by Matthew Braniff on 5/8/26.
//

import SwiftUI
import SDWebImageSwiftUI

@Observable
class ImageSearchGridViewModel {
    @ObservationIgnored var service = ImageRequestService()
    var images: [ImgurImage] = []
    
    func fetchImages(searchTerm: String) {
        self.images.removeAll()
        Task { @MainActor in
            guard let results = await service.getImages(searchTerm) else { return }
            
            self.images = results.queries
                .filter { !$0.nsfw }
                .flatMap { $0.images }
                .filter { $0.type != "video/mp4" }
        }
    }
}

struct ImageSearchGrid: View {
    @State var viewModel = ImageSearchGridViewModel()
    @State var search: String = ""
    var body: some View {
        ScrollView {
            if viewModel.images.isEmpty {
                Text("No Images To View")
            } else {
                LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150))]) {
                    ForEach(viewModel.images) { image in
                        WebImage(url: image.link) {
                            if let error = $0.error {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.red)
                                    .onAppear {
                                        print("Failed: \(image)")
                                    }
                            } else if let image = $0.image {
                                image
                                    .resizable()
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(height: 150)
                    }
                }
            }
        }
        .searchable(text: $search, prompt: Text("Search for an image"))
        .onSubmit(of: .search) {
            guard search != "" else { return }
            viewModel.fetchImages(searchTerm: search)
        }
    }
}

#Preview {
    NavigationStack {
        ImageSearchGrid()
    }
}
