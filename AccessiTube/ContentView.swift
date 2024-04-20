//
//  ContentView.swift
//  AccessiTube
//
//  Created by Hakan Tekir on 6.03.2024.
//

import SwiftUI
import AVKit

struct ContentView: View {
    private let url = URL(string: "https://devstreaming-cdn.apple.com/videos/tech-talks/111386/2/7E5193EB-C506-450C-9475-0A311E73EAC4/cmaf.m3u8")!
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    PlayerView(url)
                } label: {
                    Text("Player")
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
