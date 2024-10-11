//
//  HomeView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 10/3/24.
//

import SwiftUI
import ARKit

struct HomeView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: DrumBeatView()) {
                    Text("Drum Beat")
                }
                NavigationLink(destination: BasicArDrumBeatView()) {
                    Text("Drum Beat with AR")
                }
                NavigationLink(destination: EspressoArConfigView()) {
                    Text("Espresso in AR")
                }
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
