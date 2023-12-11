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
