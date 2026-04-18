import XCTest
@testable import BottleScout

final class BottleScoutTests: XCTestCase {
    func testBottleEntryDefaultPairingNotesIsNonEmpty() {
        let bottle = BottleEntry(
            name: "Test",
            alcoholType: "wine",
            tastingNotes: "Berry",
            priceRange: "$20-$30"
        )

        XCTAssertFalse(bottle.pairingNotes.isEmpty)
    }

    func testBottleEntryStoresExplicitPairingNotes() {
        let bottle = BottleEntry(
            name: "Test",
            alcoholType: "beer",
            tastingNotes: "Citrus",
            pairingNotes: "Pairs with tacos.",
            priceRange: "$8-$12"
        )

        XCTAssertEqual(bottle.pairingNotes, "Pairs with tacos.")
    }
}
