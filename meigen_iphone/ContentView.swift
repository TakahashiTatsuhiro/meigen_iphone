import SwiftUI

struct Quote: Decodable {
    var id: Int
    var author: String
    var body: String
}

struct WikipediaResponse: Decodable {
    var query: Query
}

struct Query: Decodable {
    var pages: [String: Page]
}

struct Page: Decodable {
    var pageid: Int
    var ns: Int
    var title: String
    var extract: String
}

struct WikipediaImageResponse: Decodable {
    var thumbnail: Thumbnail?
}

struct Thumbnail: Decodable {
    var source: String
}


class QuoteViewModel: ObservableObject {
    @Published var quote: Quote?
    @Published var authorInfo: String?
    @Published var authorImageURL: URL?
    @Published var isLoading = false
    
    func fetchQuote() {
        guard let url = URL(string: "https://meigen-backend.onrender.com/meigen") else {
            print("Invalid URL")
            return
        }
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }
                guard let data = data else {
                    print("No data received")
                    return
                }
                do {
                    self.quote = try JSONDecoder().decode(Quote.self, from: data)
                    self.fetchAuthorImage()
                    self.fetchAuthorInfo()
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func fetchAuthorInfo() {
        if let author = self.quote?.author {
            guard let url = URL(string: "https://ja.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=\(author)") else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching author info: \(error.localizedDescription)")
                        return
                    }
                    guard let data = data else {
                        print("No data received")
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(WikipediaResponse.self, from: data)
                        if let page = result.query.pages.values.first {
                            self.authorInfo = page.extract
                        } else {
                            self.authorInfo = "著者情報が見つかりませんでした。"
                        }
                    } catch {
                        print("Error decoding author info: \(error.localizedDescription)")
                    }
                }
            }.resume()
        } else {
            print("Quote not available")
        }
        
    }
    
    func fetchAuthorImage() {
        if let author = self.quote?.author {
            guard let url = URL(string: "https://ja.wikipedia.org/api/rest_v1/page/summary/\(encodeURIComponent(author))") else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching author image info: \(error.localizedDescription)")
                        self.authorImageURL = nil
                        return
                    }
                    guard let data = data,
                          let response = try? JSONDecoder().decode(WikipediaImageResponse.self, from: data),
                          let imageUrlString = response.thumbnail?.source,
                          let imageUrl = URL(string: imageUrlString) else {
                        print("Error decoding author image info or no image found")
                        self.authorImageURL = nil
                        return
                    }
                    self.authorImageURL = imageUrl
                }
            }.resume()
        } else {
            print("Author name not available for image fetch")
            self.authorImageURL = nil
        }
    }
    
    private func encodeURIComponent(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
    
}


struct ContentView: View {
    @StateObject var viewModel = QuoteViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                Button("Get Quote") {
                    viewModel.fetchQuote()
                }
                .padding()
                Spacer() // これによりボタンを上部に固定
            }
            
            VStack {
                Spacer()
                    .frame(height: 50) // ボタンとのスペースを確保
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        if let quote = viewModel.quote {
                            VStack {
                                HStack {
                                    Spacer()
                                    VStack {
                                        Text(quote.author)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .padding()
                                        if let authorImageURL = viewModel.authorImageURL {
                                            AsyncImage(url: authorImageURL) { image in
                                                image.resizable()
                                                    .scaledToFit()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 150, height: 150)
                                            .padding()
                                        }
                                    }
                                    Spacer()
                                }
                                
                                Text(quote.body)
                                    .fontWeight(.bold)
                                    .padding()
                                
                                if let authorInfo = viewModel.authorInfo {
                                    Text(authorInfo)
                                        .padding()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    ContentView()
}
