import Foundation
import AsyncHTTPClient

struct TempError: Error {

}

class AppStoreReviewsService: ReviewsServiceProtocol {

    private init() { }

    static func fetchReviews(app: App) throws -> [Review] {
        guard app.platform == .appStore else { return [] }
        
        let authKey = """
        -----BEGIN PRIVATE KEY-----
        MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgWxy18xIucfXGUDmh
        hwHswF2tCWzLksyRj5gg1cVi9tqgCgYIKoZIzj0DAQehRANCAAQu5IbOeIsJikPt
        iCNHZ+mE79jwCZvdZ1QbDHBgr6KRU28l/XHgTcjygwpnhgEDsYUmHTqiP+YMUIsz
        Ep8Pu4qd
        -----END PRIVATE KEY-----
        """

        guard let token: String = generateJWT(authKey: authKey, keyId: "MR9G8ULX3M", teamId: "69a6de97-7f46-47e3-e053-5b8c7c11a4d1") else {
            throw TempError()
        }
        
        print("DBG::Token", token)

        var request = try! HTTPClient.Request(url: "https://api.appstoreconnect.apple.com/v1/apps/\(app.id)/customerReviews?sort=-createdDate")
        request.headers.replaceOrAdd(name: "Authorization", value: "Bearer \(token)")

        let result = try HTTPClient.shared.execute(request: request).wait()

        guard result.status == .ok  else {
            throw TempError()
        }

        guard let body = result.body else {
            throw TempError()
        }

        let data = Data.from(buffer: body)
        let appStoreReviewsResponse = try JSONDecoder().decode(AppStoreReviewsResponse.self, from: data)

        return appStoreReviewsResponse.reviews.reversed().map {
            return Review(
                id: $0.id,
                rating: UInt8($0.attributes.rating),
                content: $0.attributes.body,
                reviewerNickname: $0.attributes.reviewerNickname,
                title: $0.attributes.title,
                createdDate: DateFormatters.iso.date(from: $0.attributes.createdDate),
                country: $0.attributes.territory
            )
        }
    }
}
