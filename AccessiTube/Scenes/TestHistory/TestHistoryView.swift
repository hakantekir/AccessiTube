//
//  TestHistoryView.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 26.05.2024.
//

import SwiftUI
import SwiftData

struct TestHistoryView: View {
    @State private var fileURL: URL? = nil
    @Query private var items: [PlayerTestModel]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                List {
                    if let fileURL {
                        Section {
                            ShareLink(item: fileURL) {
                                Text("Dışarı aktar")
                                    .foregroundStyle(.white)
                            }
                            .listRowBackground(Color.gray.opacity(0.2))
                        }
                    }
                    ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                        Text(index.description)
                            .foregroundStyle(.white)
                            .listRowBackground(Color.gray.opacity(0.2))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .onAppear {
                var testItems = [PlayerTestStruct]()
                for i in items {
                    testItems.append(i.toStructModel())
                }
                guard let jsonData = try? JSONEncoder().encode(testItems) else {
                    return
                }
                if let fileURL = saveJSONToFile(data: jsonData, fileName: "array.json") {
                    self.fileURL = fileURL
                }
            }
        }
    }
    
    func saveJSONToFile(data: Data, fileName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsURL.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to write JSON data to file: \(error)")
            return nil
        }
    }
}

#Preview {
    TestHistoryView()
}
