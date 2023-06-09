//
//  Created by Evhen Gruzinov on 12.04.2023.
//

import Foundation

class DateTimeFunctions {
    static func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY, HH:mm"
        return dateFormatter.string(from: date)
    }

    static var deletionDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!

    static func daysLeft(_ date: Date) -> Double {
        var dateComponent = DateComponents()
        dateComponent.day = 30
        let deletionDate = Calendar.current.date(byAdding: dateComponent, to: date)!

        let referenceDelta = date.distance(to: deletionDate)
        let nowDelta = date.distance(to: Date.now)

        let daysLeft = (referenceDelta - nowDelta) / 60 / 60 / 24
        return daysLeft
    }

    static func daysLeftString(_ date: Date) -> String {
        let daysLeft: Int = Int(daysLeft(date))

        if daysLeft < 1 {
            return "< 1 day"
        } else if daysLeft == 1 {
            return "1 day"
        } else {
            return "\(daysLeft) days"
        }
    }
}
