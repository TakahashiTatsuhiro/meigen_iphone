import SwiftUI


struct ContentView: View {
    @StateObject var viewModel = QuoteViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button("自前API") {
                        viewModel.fetchQuote()
                    }
                    .padding()
                    .foregroundColor(Color.white) // テキストの色
                    .background(Color.blue) // 背景色
                    .cornerRadius(8) // 角の丸み
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 2) // 枠線
                    )

                    Button("外部API") {
                        viewModel.fetchQuoteFromNewAPI()
                    }
                    .padding()
                    .foregroundColor(Color.white)
                    .background(Color.green)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green, lineWidth: 2)
                    )
                }

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
