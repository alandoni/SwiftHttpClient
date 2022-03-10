import Foundation

@available(iOS 13.0.0, *)
@available(macOS 10.15.0, *)
extension SwiftHttpClientProtocol {
    func makeRequest<Api: RequestDescriptor>(api: Api) async throws -> Api.Response? {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try self.makeRequest(api: api) { response, error in
                    guard let resp = response else {
                        continuation.resume(throwing: error ?? URLError(.badServerResponse))
                        return
                    }
                    continuation.resume(returning: resp)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
