import Foundation

class HttpError: LocalizedError {
    let request: URLRequest
    let response: HTTPURLResponse?
    let responseData: Data?

    init(request: URLRequest,
         response: HTTPURLResponse? = nil,
         responseData: Data? = nil) {
        self.request = request
        self.response = response
        self.responseData = responseData
    }
    
    var errorDescription: String? {
        get {
            guard let response = responseData,
                  let errorMessage = String(data: response, encoding: .utf8) else {
                return nil
            }
            return errorMessage
        }
    }
    
    var errorCode: Int? {
        return response?.statusCode
    }
}
