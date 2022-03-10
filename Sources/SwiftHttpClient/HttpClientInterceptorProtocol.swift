import Foundation

protocol HttpClientInterceptorProtocol {
    func onRequest(_ request: URLRequest) -> URLRequest
    func onResponse(_ response: HTTPURLResponse, _ data: Data) -> HTTPURLResponse
}
