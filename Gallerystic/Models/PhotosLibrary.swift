//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

class PhotosLibrary: Codable, ObservableObject {
    var libraryVersion: Int
    var photos: [Photo]
    
    init(libraryVersion: Int, photos: [Photo]) {
        self.libraryVersion = libraryVersion
        self.photos = photos
    }
    
    
    func addImages(_ imgs: [Photo], competition: @escaping (Int, Error?) -> Void) {
        var count = 0
        for item in imgs {
            photos.append(item)
            count += 1
        }
        let e = saveLibrary(lib: self)
        competition(count, e)
    }
    
    func toBin(_ imgs: [Photo], competition: @escaping (Error?) -> Void) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                photos[photoIndex].status = .deleted
                photos[photoIndex].deletionDate = Date()
            }
        }
        self.objectWillChange.send()
        let e = saveLibrary(lib: self)
        competition(e)
    }
    func recoverImages(_ imgs: [Photo], competition: @escaping (Error?) -> Void) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                photos[photoIndex].status = .normal
                photos[photoIndex].deletionDate = nil
            }
        }
        self.objectWillChange.send()
        let e = saveLibrary(lib: self)
        competition(e)
    }
    func permanentRemove(_ imgs: [Photo], competition: @escaping (Error?) -> Void) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                let (completed, error) = removeImageFile(id: item.id, fileExtention: item.fileExtention)
                if completed {
                    photos.remove(at: photoIndex)
                } else {
                    competition(error)
                }
            }
        }
        self.objectWillChange.send()
        let e = saveLibrary(lib: self)
        competition(e)
    }
    func clearBin(competition: @escaping (Error?) -> Void) {
        var forDeletion = [Photo]()
        for item in photos {
            if item.status == .deleted, let deletionDate = item.deletionDate, TimeFunctions.daysLeft(deletionDate) < 0 {
                forDeletion.append(item)
            }
        }
        permanentRemove(forDeletion) { error in
            competition(error)
        }
    }
}

enum PhotosSortArgument {
    case importDate, creationDate
}

enum RemovingDirection {
    case bin
    case recover
    case permanent
}
