//
//  ContentView.swift
//  meigen_iphone
//
//  Created by 1460969 on 2023/12/07.
//

import SwiftUI

struct Quote: Decodable {
    var id: Int
    var author: String
    var body: String
}

class QuoteViewModel: ObservableObject {
    @Published var quote: Quote?
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
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}


struct ContentView: View {
    @StateObject var viewModel = QuoteViewModel()

    var body: some View {
        VStack {
            Button("Get Quote") {
                viewModel.fetchQuote()
            }
            .padding()
            if viewModel.isLoading {
                ProgressView()
            } else if let quote = viewModel.quote {
                Text(quote.author)
                    .padding()
                Text(quote.body)
                    .padding()
            }
        }
    }
}


#Preview {
    ContentView()
}
