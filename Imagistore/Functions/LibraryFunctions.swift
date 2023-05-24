//
//  Created by Evhen Gruzinov on 08.05.2023.
//

import SwiftUI
import CoreData
import CloudKit

func generateMiniatureData(_ uiImage: UIImage) -> Data? {
    let miniatureMaxSize: CGFloat = 320

    let size: CGSize
    if uiImage.size.width > uiImage.size.height {
        let coefficient = uiImage.size.width / miniatureMaxSize
        size = CGSize(width: miniatureMaxSize, height: uiImage.size.height / coefficient)
    } else {
        let coefficient = uiImage.size.height / miniatureMaxSize
        size = CGSize(width: uiImage.size.width / coefficient, height: miniatureMaxSize)
    }
    let renderer = UIGraphicsImageRenderer(size: size)
    let uiImageMini = renderer.image { (_) in
        uiImage.draw(in: CGRect(origin: .zero, size: size))
    }
    let data = uiImageMini.heic(compressionQuality: 0.1)
    return data
}

extension PhotosLibrary {
    func toBin(_ images: [Photo], in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        do {
            for item in images {
                item.status = PhotoStatus.deleted.rawValue
                item.deletionDate = Date()
            }
            try context.save()
        } catch {
            competition(error)
        }
        competition(nil)
    }
    func recoverImages(_ images: [Photo], in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        do {
            for item in images {
                item.status = PhotoStatus.normal.rawValue
                item.deletionDate = nil
            }
            try context.save()
        } catch {
            competition(error)
        }
        competition(nil)
    }
    func permanentRemove(_ images: [Photo], library: PhotosLibrary,
                         in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        do {
            var cloudIDArr = [CKRecord.ID]()
            images.forEach { photo in
                context.delete(photo)
                removeImageFile(photo) { _, error in
                    if let error { competition(error) }
                }
                library.removeFromPhotos(photo)
                if let cloudID = photo.fullsizeCloudID {
                    cloudIDArr.append(CKRecord.ID(recordName: cloudID))
                }
            }
            cloudDatabase.modifyRecords(saving: [], deleting: cloudIDArr) { result in
                switch result {
                case .success((_, let deletedRecords)):
                    debugPrint(deletedRecords)
                case .failure(let error):
                    competition(error)
                }
            }
            try context.save()
        } catch {
            competition(error)
        }
        competition(nil)
    }
    func clearBin(_ lib: PhotosLibrary, in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        let request = Photo.fetchRequest()
        let libPredicate = NSPredicate(format: "library = %@", lib as CVarArg)
        let deletedPredicate = NSPredicate(format: "deletionDate < %@", DateTimeFunctions.deletionDate as CVarArg)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [libPredicate, deletedPredicate])

        do {
            let forDeletion = try context.fetch(request)
            if forDeletion.count > 0 {
                permanentRemove(forDeletion, library: lib, in: context) { error in
                    competition(error)
                }
            } else {
               competition(nil)
            }
        } catch {
            competition(error)
        }
        competition(nil)
    }
}