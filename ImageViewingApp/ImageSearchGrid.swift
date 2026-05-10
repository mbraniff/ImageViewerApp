//
//  ImageSearchGrid.swift
//  ImageViewingApp
//
//  Created by Matthew Braniff on 5/8/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageSearchGrid: View {
    @State var viewModel = ImageSearchGridViewModel()
    @State var search: String = ""
    var body: some View {
        ScrollView {
            if viewModel.images.isEmpty {
                Spacer()
                    .frame(height: 150)
                Text(viewModel.isFetching ? "Loading..." : "No Images To View")
                    .font(.title)
                    .bold()
                if viewModel.isFetching {
                    ProgressView()
                }
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(ImgurSortType.allCases, id: \.self) { sort in
                        Button(sort.rawValue.capitalized) {
                            viewModel.sort = sort
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
            }
            if viewModel.sort == .top {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(ImgurWindowType.allCases, id: \.self) { window in
                            Button(window.rawValue.capitalized) {
                                viewModel.window = window
                            }
                        }
                    } label: {
                        Image(systemName: "calendar")
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
