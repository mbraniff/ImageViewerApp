//
//  ImageSearchGridViewModel.swift
//  ImageViewingApp
//
//  Created by Matthew Braniff on 5/10/26.
//

import Foundation

@Observable
class ImageSearchGridViewModel {
    @ObservationIgnored var service = ImageRequestService()
    var images: [ImgurImage] = []
    var page = 0
    var window = ImgurWindowType.all
    var sort = ImgurSortType.time
    var lastSearchTerm = ""
    var isFetching = false
    
    func fetchImages(searchTerm: String) {
        guard !self.isFetching else { return }
        self.isFetching = true
        self.images.removeAll()
        self.lastSearchTerm = searchTerm
        self.getImages()
    }
    
    func fetchMore() {
        guard !self.isFetching else { return }
        self.isFetching = true
        self.page += 1
        self.getImages()
    }
    
    private func getImages() {
        Task { @MainActor in
            guard let results = await service.getImages(lastSearchTerm, sort.rawValue, window.rawValue, page) else {
                self.isFetching = false
                return
            }
            
            self.images.append(contentsOf: results.queries
                .filter { !$0.nsfw }
                .compactMap { $0.images }
                .flatMap { $0 }
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

enum ImgurSortType: String, CaseIterable {
    case time
    case viral
    case top
}

enum ImgurWindowType: String, CaseIterable {
    case day
    case week
    case month
    case year
    case all
}
