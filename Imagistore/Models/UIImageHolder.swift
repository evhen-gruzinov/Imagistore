//
//  Created by Evhen Gruzinov on 17.04.2023.
//

import SwiftUI

class UIImageHolder {
    var data: [UUID: UIImage]
    private var fullsizeArr: [UUID]

    init() {
        data = [:]
        fullsizeArr = []
    }

    func getUiImage(photo: Photo) -> UIImage? {
        if let uiImage = data[photo.id] {
            return uiImage
        } else {
            let uiImage = readImageFromFile(id: photo.id)
            guard let uiImage else {
                print("err")
                return nil
            }
            data[photo.id] = uiImage
            return uiImage
        }
    }

    func getFullUiImage(photo: Photo) -> UIImage? {
        if fullsizeArr.contains(where: { $0 == photo.id }), let uiImage = data[photo.id] {
            return uiImage
        } else {
            let uiImage = readFullImageFromFile(id: photo.id)
            guard let uiImage else {
                print("err")
                return nil
            }
            data.updateValue(uiImage, forKey: photo.id)
            fullsizeArr.append(photo.id)
            return uiImage
        }
    }
}