//
// ******************************************************
// Copyright © 2023 Eclypses Inc. All rights reserved.
// ******************************************************


import SwiftUI

struct ContentView: View {
    
    @State private var closeApp: Bool = false
    @ObservedObject var manager = Manager()
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: .constant(manager.message))
                    .padding()
                    .foregroundColor(Color.accentColor)
                    .navigationBarTitle(Text(Settings.appName), displayMode: .inline)
                    .toolbar {
                        Button {
                            closeApp = true
                        } label: {
                            Label("Quit", systemImage: "power")
                        }
                    }
                HStack {
                    Spacer()
                    Button {
                        manager.runWithoutJailbreakDetection()
                    } label: {
                        Text("Run Without Jailbreak Detection")
                            .bold()
                            .font(.system(size: 30))
                            .padding(.all)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        manager.runWithJailbreakDetection()
                    } label: {
                        Text("Run With Jailbreak Detection")
                            .bold()
                            .font(.system(size: 30))
                            .padding(.all)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                    Spacer()
                }
            }
        }
        .alert("Tap 'Close App' to quit" , isPresented: $closeApp) {
            Button("Close App", role: .destructive) {
                exit(EXIT_SUCCESS)
            }
            Button("Cancel", role: .cancel) { }
        }
               .navigationViewStyle(.stack)
    }
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ContentView()
            }
        }
    }
}
