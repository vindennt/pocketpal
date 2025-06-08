//
//  ContentView.swift
//  pocketpal
//
//  Created by Dennis Truong on 2025-06-08.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedNumber: Int = 1
    @State private var inputText: String = ""
    @State private var errorMessage: String?

    private var gifData: Data? {
        let name = String(format: "%03d", selectedNumber)
        if let url = Bundle.main.url(
            forResource: name,
            withExtension: "gif",
        ) {
            return try? Data(contentsOf: url)
        }
        return nil
    }

    var body: some View {
        VStack {
            if let data = gifData {
                GIFView(data: data)
                    .frame(width: 300, height: 300)
            } else {
                Text("Failed to load GIF!")
                    .frame(width: 300, height: 300)
            }

            Picker("Select Number", selection: $selectedNumber) {
                ForEach(1..<152, id: \.self) { number in
                    Text("\(number)").tag(number)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 100)
            .onChange(of: selectedNumber) { newValue, _ in
                inputText = ""
                errorMessage = nil
            }

            HStack {
                TextField("Enter number (1-151)", text: $inputText, onCommit: commitInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                Button("Go", action: commitInput)
            }
            .padding(.horizontal)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
    }

    private func commitInput() {
        guard let value = Int(inputText), (1...151).contains(value) else {
            errorMessage = "Please enter a number between 1 and 151"
            return
        }
        selectedNumber = value
        errorMessage = nil
        inputText = ""
    }
}

#Preview {
    ContentView()
}
