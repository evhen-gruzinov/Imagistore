//
//  Created by Evhen Gruzinov on 20.04.2023.
//

import SwiftUI

struct LibrariesSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var sceneSettings: SceneSettings

    @FetchRequest(sortDescriptors: []) var librariesCollection: FetchedResults<PhotosLibrary>
    @Binding var applicationSettings: ApplicationSettings
    @Binding var selectedLibrary: PhotosLibrary?

    @State private var isShowingAddLibSheet: Bool = false

    @State var newLibraryName: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                Divider()
                if librariesCollection.count > 0 {
                    ForEach(librariesCollection) { library in
                        Button(action: {
                            withAnimation {
                                librarySelected(library)
                            }
                        }, label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 5) {
                                        Text(library.name ?? "*No name*").font(.title2).bold().multilineTextAlignment(.leading)
                                    }
                                    Text("Photos: \(library.photos.count)").font(.caption)

                                    #if DEBUG
                                    Text("ID: \(library.uuid.uuidString)").font(.caption)
                                    #endif

                                    Text("Last change: \(DateTimeFunctions.dateToString(library.lastChange))")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(Color.primary)
                        })
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        Divider()
                    }
                }
            }
            .navigationTitle("Libraries")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddLibSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }

            .sheet(isPresented: $isShowingAddLibSheet, content: {
                Form {
                    Section("New Library") {
                        TextField("Library name", text: $newLibraryName)
                        Button {
                            withAnimation {
                                let newLib = PhotosLibrary(context: viewContext)
                                newLib.uuid = UUID()
                                newLib.name = newLibraryName
                                newLib.photos = []
                                newLib.lastChange = Date()
                                newLib.version = Int16(PhotosLibrary.actualLibraryVersion)

                                print(newLib.uuid)

                                do {
                                    try viewContext.save()
                                } catch {
                                    let nsError = error as NSError
                                    debugPrint("Unable to save context: \(nsError), \(nsError.userInfo)")
                                }
                            }
                            isShowingAddLibSheet = false
                        } label: {
                            Text("Create")
                        }.disabled(newLibraryName.count == 0)
                    }
                    Button(role: .destructive) {
                        isShowingAddLibSheet = false
                    } label: {
                        Text("Cancel")
                    }
                }
            })
        }
    }

    private func librarySelected(_ library: PhotosLibrary) {
        selectedLibrary = library
    }
}
