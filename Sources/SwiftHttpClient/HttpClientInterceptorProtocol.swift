import Foundation

public protocol HttpClientInterceptorProtocol {
    func onRequest(_ request: URLRequest) -> URLRequest
    func onResponse(_ response: HTTPURLResponse, _ data: Data) -> HTTPURLResponse
}
