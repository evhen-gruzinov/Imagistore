//
//  Created by Evhen Gruzinov on 07.05.2023.
//

import SwiftUI
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
}

enum PhotoStatus: String, Codable {
    case normal, deleted
}

func sortedPhotos(_ photos: FetchedResults<Photo>, by byArgument: PhotosSortArgument, filter: PhotoStatus) -> [Photo] {
    photos
        .filter({ photo in
            photo.uuid != nil
        })
        .sorted(by: { ph1, ph2 in
            if filter == .deleted, let delDate1 = ph1.deletionDate, let delDate2 = ph2.deletionDate {
                return delDate1 < delDate2
            } else {
                switch byArgument {
                case .importDate:
                    return ph1.importDate < ph2.importDate
                case .creationDate:
                    return ph1.creationDate < ph2.creationDate
                }
            }
        })
        .filter({ item in
            item.status == filter.rawValue
        })
    }