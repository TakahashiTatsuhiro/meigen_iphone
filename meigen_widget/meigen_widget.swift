import WidgetKit
import SwiftUI

struct Quote: Decodable {
    var id: Int
    var author: String
    var body: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: "名言", author: "著者")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), quote: "名言", author: "著者")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        fetchQuote { quote in
            let entry = SimpleEntry(date: currentDate, quote: quote.body, author: quote.author)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
    func fetchQuote(completion: @escaping (Quote) -> Void) {
        let url = URL(string: "https://meigen-backend.onrender.com/meigen")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let quote = try? JSONDecoder().decode(Quote.self, from: data) {
                completion(quote)
            } else {
                // エラーハンドリング: デフォルトの名言を返すか、エラーを示す
                completion(Quote(id: 0, author: "不明", body: "名言が取得できませんでした"))
            }
        }.resume()
    }
    
    
}

struct meigen_widgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.author)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(entry.quote)
                .font(.headline)
                .bold()
                .foregroundColor(.primary)
        }
        .padding()
        .cornerRadius(10) // 角を丸める
        .containerBackground(.fill.tertiary, for: .widget) // ここに修飾子を追加
    }
}

struct meigen_widget: Widget {
    let kind: String = "meigen_widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            meigen_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("名言ウィジェット")
        .description("定期的に新しい名言を表示します。")
        .supportedFamilies([.systemMedium]) // ミドルサイズのみをサポート
    }
}

#Preview(as: .systemMedium) {
    meigen_widget()
} timeline: {
    SimpleEntry(date: .now, quote: "名言", author: "著者")
}
