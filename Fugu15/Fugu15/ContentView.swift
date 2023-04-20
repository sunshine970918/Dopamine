//
//  ContentView.swift
//  Fugu15
//
//  Created by Linus Henze.
//

import SwiftUI

#if os(iOS)
import UIKit
#else
import AppKit
#endif

import Fugu15KernelExploit

struct ContentView: View {
    @State var logText = ""
    @State private var showingRemoveFrame = RemoveFuguInstall.shouldShow()

    var body: some View {
        NavigationView {
            VStack {
                Divider()

                TabView {
                    JailbreakView(logText: $logText)
                        .tabItem {
                            Label("越狱", systemImage: "wand.and.stars")
                        }

                    LogView(logText: $logText)
                        .tabItem {
                            Label("日志", systemImage: "doc.text.magnifyingglass")
                        }

                    AboutView()
                        .tabItem {
                            Label("关于", systemImage: "info.circle")
                        }
                }
                    .sheet(isPresented: $showingRemoveFrame) {
                        RemoveFuguInstall(isPresented: $showingRemoveFrame)
                    }
                    .navigationTitle("Fugu15")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }.navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
