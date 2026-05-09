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
    var page = 0
    var window = "all"
    var sort = "time"
    var lastSearchTerm = ""
    var isFetching = false
    
    func fetchImages(searchTerm: String) {
        guard !self.isFetching else { return }
        self.isFetching = true
        self.images.removeAll()
        self.lastSearchTerm = searchTerm
        Task { @MainActor in
            guard let results = await service.getImages(searchTerm, sort, window, page) else {
                self.isFetching = false
                return
            }
            
            self.images = results.queries
                .filter { !$0.nsfw }
                .flatMap { $0.images }
                .filter { $0.type != "video/mp4" }
            self.isFetching = false
        }
    }
    
    func fetchMore() {
        guard !self.isFetching else { return }
        self.isFetching = true
        self.page += 1
        Task { @MainActor in
            guard let results = await service.getImages(lastSearchTerm, sort, window, page) else {
                self.isFetching = false
                return
            }
            
            self.images.append(contentsOf: results.queries
                .filter { !$0.nsfw }
                .flatMap { $0.images }
                .filter { $0.type != "video/mp4"} )
            self.isFetching = false
        }
    }
    
    func loadedImage(_ image: ImgurImage) {
        if images.firstIndex(where: { $0.id == image.id }) ?? 0 >= images.count * 8/10 {
            fetchMore()
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
                            if let _ = $0.error {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.red)
                                    .onAppear {
                                        print("Failed: \(image)")
                                    }
                            } else if let _image = $0.image {
                                NavigationLink() {
                                    ImageDetailView(image: image.link)
                                } label: {
                                    _image
                                        .resizable()
                                }
                                .onAppear {
                                    viewModel.loadedImage(image)
                                }
                            } else {
                                ZStack {
                                    Color.gray.opacity(0.3)
                                    ProgressView()
                                }
                            }
                        }
                        .frame(height: 150)
                        .cornerRadius(25)
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
