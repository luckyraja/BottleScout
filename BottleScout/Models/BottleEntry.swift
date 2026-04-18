import Foundation
import SwiftData

@Model
final class BottleEntry {
    var id: UUID
    var name: String
    var alcoholType: String // wine, spirits, beer, etc.
    var tastingNotes: String
    var pairingNotes: String
    var priceRange: String
    var imageData: Data? // Compressed JPEG
    var inCollection: Bool
    var dateAdded: Date

    init(
        id: UUID = UUID(),
        name: String,
        alcoholType: String,
        tastingNotes: String,
        pairingNotes: String = "No pairing notes available.",
        priceRange: String,
        imageData: Data? = nil,
        inCollection: Bool = true,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.alcoholType = alcoholType
        self.tastingNotes = tastingNotes
        self.pairingNotes = pairingNotes
        self.priceRange = priceRange
        self.imageData = imageData
        self.inCollection = inCollection
        self.dateAdded = dateAdded
    }
}
