import SwiftUI

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
        authorInfo = nil
        authorImageURL = nil
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
    
    func fetchQuoteFromNewAPI() {
        guard let url = URL(string: "https://meigen.doodlenote.net/api/json.php?c=1") else {
            print("Invalid URL")
            return
        }
        isLoading = true
        authorInfo = nil
        authorImageURL = nil
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
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]],
                       let firstQuote = jsonResult.first,
                       let body = firstQuote["meigen"],
                       let author = firstQuote["auther"] {
                        self.quote = Quote(id: 0, author: author, body: body)
                        self.fetchAuthorImage()
                        self.fetchAuthorInfo()
                    }
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
