//
//  MainView.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 6.03.2024.
//

import SwiftUI
import SwiftData
import AVKit

struct MainView: View {
    @Environment(\.modelContext) private var context
    
    @Query private var items: [PlayerTestModel]
    private let url = URL(string: "https://devstreaming-cdn.apple.com/videos/tech-talks/111386/2/7E5193EB-C506-450C-9475-0A311E73EAC4/cmaf.m3u8")!
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    NavigationLink {
                        PlayerView(AVPlayer(url: url))
                            .modelContainer(for: PlayerTestModel.self)
                    } label: {
                        innovativePlayer
                    }
                    
                    NavigationLink {
                        PlayerView(AVPlayer(url: url), type: .classic)
                    } label: {
                        classicPlayer
                    }
                    
                    NavigationLink {
                        TestHistoryView()
                            .navigationTitle("Geçmiş Testler")
                    } label: {
                        testHistory
                    }
                }
            }
        }
    }
    
    var innovativePlayer: some View {
        Text("Yenilikçi Tasarım")
            .font(.title3.bold())
            .frame(width: 200)
            .padding(.vertical, 20.0)
            .foregroundStyle(.white)
            .background(.gray.opacity(0.25), in: .capsule)
    }
    
    var classicPlayer: some View {
        Text("Klasik Tasarım")
            .font(.title3.bold())
            .frame(width: 200)
            .padding(.vertical, 20.0)
            .foregroundStyle(.white)
            .background(.gray.opacity(0.25), in: .capsule)
    }
    
    var testHistory: some View {
        Text("Geçmiş Testler")
            .font(.title3.bold())
            .frame(width: 200)
            .padding(.vertical, 20.0)
            .foregroundStyle(.white)
            .background(.gray.opacity(0.25), in: .capsule)
    }
}

#Preview {
    MainView()
        .modelContainer(for: PlayerTestModel.self)
}
