struct AccessTokenRequest: Encodable {
    let assertion: String
    let grant_type: String = "urn:ietf:params:oauth:grant-type:jwt-bearer"
}