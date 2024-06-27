import Foundation

class ReviewsNotifyTask {

    private init() { }
    
    static let reviewsServices: [Platform: ReviewsServiceProtocol.Type] = [
        .appStore: AppStoreReviewsService.self,
        .googlePlay: GooglePlayReviewsService.self
    ]

    static func run() {
        Logger.log("Starting reviews notify task")
                
        for app in Config.app.apps {
            Logger.log("Collecting reviews for \(app.name)/\(app.platform)")
            
            guard let reviewsService = reviewsServices[app.platform] else {
                Logger.log("No reviews service for \(app.platform), skipping...")
                continue
            }
            
            do {
                let reviews = try reviewsService.fetchReviews(app: app).filter {
                    return UniqueStorage.shared.isExist(uniqueId: $0.uniqueId(for: app)) == false
                }
                
                Logger.log("Found \(reviews.count) new reviews for \(app.name)/\(app.platform)")
                guard reviews.count > 0 else { continue }
                
                Logger.log("Sending telegram messages for \(app.name)/\(app.platform)")
                for (index, review) in reviews.enumerated() {
                    Logger.log("\(app.name)/\(app.platform) - Reviews \(index + 1)/\(reviews.count)")
                    sendMessages(app: app, review: review)
                }
            } catch {
                Logger.log("Error collecting reviews for \(app.name)/\(app.platform):\n\(error)")
            }
        }
    }
    
    private static func sendMessages(app: App, review: Review, retryCounter: UInt = 0) {
        Logger.verbose { Logger.log("Sending telegram message for reviewID: \(review.id)") }
        do {
            if retryCounter == 0 {
                Thread.sleep(forTimeInterval: Config.app.telegram.messageSendDelay)
            }
            
            let text = review.htmlDescription(for: app)
            
            try TelegramService.sendMessage(chatID: Config.app.telegram.chatID, threadID: app.telegramThreadID, text: text)
            Logger.verbose { Logger.log("Sent telegram message for reviewID: \(review.id)") }
            UniqueStorage.shared.add(uniqueId: review.uniqueId(for: app))
        } catch {
            guard retryCounter < Config.app.telegram.messageSendMaxRetries else {
                Logger.verbose { Logger.log("Error sending telegram message for reviewID: \(review.id):\n\(error)", type: .error) }
                return
            }
            
            Logger.verbose { Logger.log("Error sending telegram message for reviewID: \(review.id):\n\(error)\nRetrying \(retryCounter + 1)/\(Config.app.telegram.messageSendMaxRetries)...", type: .error) }
            Thread.sleep(forTimeInterval: Config.app.telegram.messageSendRetryDelay)
            sendMessages(app: app, review: review, retryCounter: retryCounter + 1)
        }
    }
}