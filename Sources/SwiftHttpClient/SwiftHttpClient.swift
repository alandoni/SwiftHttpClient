import Foundation

public protocol SwiftHttpClientProtocol {
    func makeRequest<Api: RequestDescriptor>(api: Api, callback: @escaping (Api.Response?, Error?) -> Void) throws
}

public class SwiftHttpClient: NSObject, SwiftHttpClientProtocol {
    private let url: URL
    private let headers: [String: String]?
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let interceptors: [HttpClientInterceptorProtocol]
    private var session: URLSession!

    init(url: URL, headers: [String: String]?, encoder: JSONEncoder, decoder: JSONDecoder, interceptors: [HttpClientInterceptorProtocol]) {
        self.url = url
        self.headers = headers
        self.interceptors = interceptors
        self.encoder = encoder
        self.decoder = decoder
        self.session = URLSession.shared
        super.init()
    }

    private func prepareRequest<Api: RequestDescriptor>(api: Api) throws -> URLRequest {
        let percentUrl = api.url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        guard let url = percentUrl else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: self.url.appendingPathComponent(url))
        request.httpMethod = api.method.toString()

        if let data = (api.body as? String)?.data(using: .utf8, allowLossyConversion: true) {
            request.httpBody = data
        } else {
            do {
                if api.body != nil {
                    request.httpBody = try self.encoder.encode(api.body)
                }
            } catch {
                throw URLError(.dataNotAllowed)
            }
        }
        request.allHTTPHeaderFields = self.headers
        self.interceptors.forEach { interceptor in
            request = interceptor.onRequest(request)
        }
        api.headers?.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }

    private func processResponse<Response: Codable>(_ response: HTTPURLResponse,
                                                    forRequest request: URLRequest,
                                                    withData data: Data) throws -> Response? {
        var response = response
        self.interceptors.forEach { interceptor in
            response = interceptor.onResponse(response, data)
        }
        guard response.statusCode == 200 else {
            throw HttpError(request: request, response: response, responseData: data)
        }
        let responseObj = try self.decoder.decode(Response.self, from: data)
        return responseObj
    }
    
    private func processRequest(request: URLRequest, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.session.dataTask(with: request, completionHandler: callback).resume()
    }

    public func makeRequest<Api: RequestDescriptor>(api: Api, callback: @escaping (Api.Response?, Error?) -> Void) throws {
        let request = try self.prepareRequest(api: api)
        self.processRequest(request: request) { (data, response, error) in
            if error != nil {
                callback(nil, error)
                return
            }
            guard let dat = data, let resp = response as? HTTPURLResponse else {
                callback(nil, error ?? URLError(.badServerResponse))
                return
            }
            do {
                let object: Api.Response? = try self.processResponse(resp, forRequest: request, withData: dat)
                callback(object, nil)
            } catch {
                callback(nil, error)
            }
        }
    }

    public class Builder {
        private var url: URL!
        private var headers = [String: String]()
        private var interceptors = [HttpClientInterceptorProtocol]()
        private var encoder: JSONEncoder!
        private var decoder: JSONDecoder!

        public init() { }

        public func setBaseUrl(url: String) -> Builder {
            self.url = URL(string: url)
            return self
        }

        public func addHeader(key: String, value: String) -> Builder {
            self.headers[key] = value
            return self
        }

        public func addInterceptor(interceptor: HttpClientInterceptorProtocol) -> Builder {
            self.interceptors.append(interceptor)
            return self
        }
        
        public func setEncoder(encoder: JSONEncoder) -> Builder {
            self.encoder = encoder
            return self
        }
        
        public func setDecoder(decoder: JSONDecoder) -> Builder {
            self.decoder = decoder
            return self
        }

        public func build() -> SwiftHttpClient {
            return SwiftHttpClient(
                url: self.url,
                headers: self.headers,
                encoder: self.encoder,
                decoder: self.decoder,
                interceptors: self.interceptors
            )
        }
    }
}
