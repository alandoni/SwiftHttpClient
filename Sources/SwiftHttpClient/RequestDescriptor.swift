public protocol RequestDescriptor {
    associatedtype Request: Codable
    associatedtype Response: Codable
    
    var method: Method { get }
    var url: String { get }
    var body: Request? { get }
    var responseType: Response.Type { get }
    var headers: [String : String]? { get }
}

extension RequestDescriptor {
    var method: Method { .get }
    var body: Request? { nil }
    var headers: [String: String]? { nil }
}

public enum Method {
    case post
    case get
    case put
    case delete
    case head
    case patch
    case options
    
    func toString() -> String {
        switch self {
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        case .head:
            return "HEAD"
        case .patch:
            return "PATCH"
        case .options:
            return "OPTIONS"
        default:
            return "GET"
        }
    }
}
