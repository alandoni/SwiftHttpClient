import Foundation
import Combine

@available(macOS 10.15, *)
@available(iOS 13.0, *)
public extension SwiftHttpClientProtocol {
    public func makeRequest<Api: RequestDescriptor>(api: Api) -> AnyPublisher<Api.Response?, Error> {
        return Future { promise in
            do {
                try self.makeRequest(api: api) { response, error in
                    guard let resp = response else {
                        promise(.failure(error ?? URLError(.badServerResponse)))
                        return
                    }
                    promise(.success(resp))
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
