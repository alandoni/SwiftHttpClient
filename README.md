# SwiftHttpClient

A simple, light-weight library to make requests using URLSession and Encoder/Decoder.
Only available via Swift Package Manager

## Instantiating the library
```swift
let client = HttpClient.Builder()
    .setBaseUrl(url: "http://localhost")
    .setEncoder(encoder: JSONEncoder())
    .setDecoder(decoder: JSONDecoder())
    .build()
```

## Using the client

### Defining the input and output models:

```swift
import Foundation

struct Login: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let userId: String
    let displayName: String
    let username: String
}
```

### Defining the request:

```swift
struct LoginRequest: RequestDescriptor {
    var responseType = LoginResponse.self
    var method: Method = .post
    var body: Login?
    var url = "login"
    var headers: [String: String]? = ["Content-Type": "application/json"]
    
    init(login: Login) {
        body = login
    }
}
```

### Calling the client:

#### Using callback:
```swift
client.makeRequest(api: LoginRequest(login: login)) { response, error in
    // handle the response as LoginResponse object
    print(response.displayName)
}
```

#### Using Combine:
```swift
client.makeRequest(api: LoginRequest(login: login))
    .subscribe(on: DispatchQueue.global())
    .receive(on: DispatchQueue.main)
    .sink { [unowned self] response in
        // handle the response as LoginResponse object
        print(response.displayName)
    }
```

#### Using Async/Await:
```swift
let response = try await client.makeRequest(api: LoginRequest(login: login))
// handle the response as LoginResponse object
print(response.displayName)
```
