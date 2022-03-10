import Foundation

public class HttpError: LocalizedError {
    public let request: URLRequest
    public let response: HTTPURLResponse?
    public let responseData: Data?

    init(request: URLRequest,
         response: HTTPURLResponse? = nil,
         responseData: Data? = nil) {
        self.request = request
        self.response = response
        self.responseData = responseData
    }
    
    public var errorDescription: String? {
        get {
            guard let response = responseData,
                  let errorMessage = String(data: response, encoding: .utf8) else {
                return nil
            }
            return errorMessage
        }
    }
    
    public var errorCode: Int? {
        return response?.statusCode
    }
}
