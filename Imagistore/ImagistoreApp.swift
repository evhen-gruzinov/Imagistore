//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

@main
struct ImagistoreApp: App {
    private var persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AppNavigator()
                .environmentObject(SceneSettings())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
