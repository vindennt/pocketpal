//
//  ContentView.swift
//  pocketpal
//
//  Created by Dennis Truong on 2025-06-08.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedNumber: Int = 25
    @State private var currentGifID: Int = 25
    @State private var gifData: Data?

    private func loadGIF(for number: Int) {
            let name = String(format: "%03d", number)
            if let url = Bundle.main.url(forResource: name, withExtension: "gif"),
               let newData = try? Data(contentsOf: url) {
                gifData = newData
                currentGifID = number
            } else {
                gifData = nil
            }
        }
    
    var body: some View {
        Spacer()
        
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 30) {
                Group {
                    if let data = gifData {
                        GIFView(data: data, scale: 0.5)
                            .frame(width: 300, height: 300)
                    } else {
                        Text("Failed to load GIF")
                            .frame(width: 300, height: 300)
                    }
                }
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                .shadow(color: Color.gray.opacity(0.4), radius: 10, x: 0, y: 5)

                Picker("Select Number", selection: $selectedNumber) {
                    ForEach(1..<152, id: \.self) { number in
                        Text("\(number)")
                        .tag(number)
                    }
                }
//                .pickerStyle(WheelPickerStyle())
                .frame(height: 120)
                .clipped()
                .onChange(of: selectedNumber) { newValue, oldValue in
                    if newValue != oldValue {
                        loadGIF(for: selectedNumber)
                    }
                }

            }
            .padding(.horizontal)
        }
    
        
        .accentColor(.blue)
        .onAppear {
            loadGIF(for: selectedNumber)
        }
    }
}

#Preview {
    ContentView()
}
