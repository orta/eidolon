import UIKit

enum ReserveStatus {
    case NoReserve
    case ReserveNotMet(Int)
    case ReserveMet
}

struct SaleNumberFormatter {
    static let dollarFormatter = createDollarFormatter()
}

class SaleArtwork: JSONAble {

    let id: String
    let artwork: Artwork

    var auction: Sale?

    // The bidder is given from JSON if user is registered
    let bidder: Bidder?

    var saleHighestBid: Bid?
    var bidCount: Int?

    var userBidderPosition: BidderPosition?
    var positions: [String]?

    dynamic var openingBidCents: NSNumber?
    var minimumNextBidCents: Int?
    
    var highestBidCents: Int?
    var lowEstimateCents: Int?
    var highEstimateCents: Int?

    init(id: String, artwork: Artwork) {
        self.id = id
        self.artwork = artwork
    }

    override class func fromJSON(json: [String: AnyObject]) -> JSONAble {
        let json = JSON(object: json)

        let id = json["id"].stringValue
        let artworkDict = json["artwork"].object as [String: AnyObject]
        let artwork = Artwork.fromJSON(artworkDict) as Artwork

        let sale = SaleArtwork(id: id, artwork: artwork) as SaleArtwork

        if let highestBidDict = json["highest_bid"].object as? [String: AnyObject] {
            sale.saleHighestBid = Bid.fromJSON(highestBidDict) as? Bid
        }
        
        sale.openingBidCents = json["opening_bid_cents"].integer
        sale.minimumNextBidCents = json["minimum_next_bid_cents"].integer

        sale.highestBidCents = json["highest_bid_amount_cents"].integer
        sale.lowEstimateCents = json["low_estimate_cents"].integer
        sale.highEstimateCents = json["high_estimate_cents"].integer
        sale.bidCount = json["bidder_positions_count"].integer
//        let reserveStatus = json["reserve_status"].integer

        return sale;
    }
    
    var estimateString: String {
        switch (lowEstimateCents, highEstimateCents) {
        case let (.Some(lowCents), .Some(highCents)):
            let lowDollars = NSNumberFormatter.currencyStringForCents(lowCents)
            let highDollars = NSNumberFormatter.currencyStringForCents(highCents)
            return "Estimate: \(lowDollars)–\(highDollars)"
        case let (.Some(lowCents), nil):
            let lowDollars = NSNumberFormatter.currencyStringForCents(lowCents)
            return "Estimate: \(lowDollars)"
        case let (nil, .Some(highCents)):
            let highDollars = NSNumberFormatter.currencyStringForCents(highCents)
            return "Estimate: \(highDollars)"
        default:
            return "No Estimate"
        }
    }
}

func createDollarFormatter() -> NSNumberFormatter {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle

    // This is always dollars, so let's make sure that's how it shows up
    // regardless of locale.

    formatter.currencyGroupingSeparator = ","
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 0
    return formatter
}