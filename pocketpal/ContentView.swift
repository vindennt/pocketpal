//
//  ContentView.swift
//  pocketpal
//
//  Created by Dennis Truong on 2025-06-08.
//

import SwiftUI
import WidgetKit

struct TypeStyle {
    let background: Color
    let foreground: Color
}

let typeColors: [String: TypeStyle] = [
    "Normal":   TypeStyle(background: .gray.opacity(0.5), foreground: .black),
    "Fire":     TypeStyle(background: .red.opacity(0.8), foreground: .white),
    "Water":    TypeStyle(background: .blue, foreground: .white),
    "Electric": TypeStyle(background: Color.yellow.opacity(0.9), foreground: .black),
    "Ice":      TypeStyle(background: Color.cyan.opacity(0.8), foreground: .black),
    "Fighting": TypeStyle(background: Color(red: 0.8, green: 0.2, blue: 0.2), foreground: .white),
    "Poison":   TypeStyle(background: Color.purple.opacity(0.7), foreground: .white),
    "Ground":   TypeStyle(background: Color.brown.opacity(0.8), foreground: .white),
    "Flying":   TypeStyle(background: Color.indigo.opacity(0.8), foreground: .white),
    "Psychic":  TypeStyle(background: Color.pink.opacity(0.8), foreground: .black),
    "Bug":      TypeStyle(background: Color.green.opacity(0.6), foreground: .black),
    "Rock":     TypeStyle(background: Color(red: 0.6, green: 0.5, blue: 0.4), foreground: .white),
    "Ghost":    TypeStyle(background: Color(red: 0.4, green: 0.3, blue: 0.6), foreground: .white),
    "Dark":     TypeStyle(background: .black, foreground: .white),
    "Dragon":   TypeStyle(background: Color.teal, foreground: .white),
    "Steel":    TypeStyle(background: Color.gray.opacity(0.7), foreground: .black),
    "Fairy":    TypeStyle(background: Color.pink.opacity(0.6), foreground: .black)
]

struct Pokemon: Codable, Identifiable {
    struct Name: Codable {
        let english: String
    }
    
    let id: Int
    let name: Name
    let type: [String]
}

func loadPokemonList() -> [Pokemon] {
    guard let url = Bundle.main.url(forResource: "pokedex", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let pokemons = try? JSONDecoder().decode([Pokemon].self, from: data) else {
        return []
    }
    return pokemons.filter { $0.id <= 251 }
}

struct ContentView: View {
//    @State private var selectedNumber: Int = 25
    @State private var currentGifID: Int = 25
    @State private var gifData: Data?
    @State private var pokemonList: [Pokemon] = []
    @State private var showingSearch = false
    
    @AppStorage("selectedId", store: UserDefaults(
        suiteName: "group.com.vindennt.pocketpal")) var selectedId = 25

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
    
    var selectedPokemon: Pokemon? {
           pokemonList.first(where: { $0.id == selectedId })
       }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 30) {
            Group {
                if let data = gifData {
                    GIFView(data: data, scale: 0.5)
                        .frame(width: 300, height: 300)
                        .compositingGroup()
                        .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 5, y: 10)
                } else {
                    Text("Failed to load GIF")
                        .frame(width: 300, height: 300)
                }
            }
            .background(RoundedRectangle(cornerRadius: 999).fill(Color.white))
            .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 5)

                if let types = selectedPokemon?.type {
                    HStack(spacing: 10) {
                        ForEach(types, id: \.self) { type in
                            let style = typeColors[type] ?? TypeStyle(background: .gray, foreground: .white)
                            Text(type)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(style.background)
                                .foregroundColor(style.foreground)
                                .cornerRadius(10)
                        }
                    }
                }

              
                
                
                Picker("Select Number", selection: $selectedId) {
                    ForEach(pokemonList) { pokemon in
                        Text("\(pokemon.id) - \(pokemon.name.english)")
                            .tag(pokemon.id)
                    }
                }
//                .pickerStyle(WheelPickerStyle())
                .frame(height: 120)
                .clipped()
                .onChange(of: selectedId) { newValue, oldValue in
                    if newValue != oldValue {
                        loadGIF(for: selectedId)
                        WidgetCenter.shared.reloadTimelines(ofKind: "pocketpalwidget")
                    }
                }
                
                Button(action: {
                    showingSearch = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search Pokédex")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .foregroundColor(.blue) // Text and icon color
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)  // Outline color and thickness
                    )
                }
                .sheet(isPresented: $showingSearch) {
                    SearchView(pokemonList: pokemonList, selectedId: $selectedId)
                }


            }
            .padding(.horizontal)
        }
    
        .accentColor(.blue)
        .onAppear {
            pokemonList = loadPokemonList()
            if let bundleURL = Bundle.main.resourceURL {
                           do {
                               let files = try FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil)
                               print("Files in widget bundle:")
                               files.forEach { print($0.lastPathComponent) }
                           } catch {
                               print("Failed to read bundle directory: \(error)")
                           }
                       } else {
                           print("Failed to locate bundle resource URL")
                       }
            loadGIF(for: selectedId)
        }
        
        .accentColor(.blue)
    }
}

struct SearchView: View {
    let pokemonList: [Pokemon]
    @Binding var selectedId: Int
    @Environment(\.dismiss) var dismiss

    @State private var searchText: String = ""
    @State private var debouncedSearchText: String = "" // add delay

    var filteredList: [Pokemon] {
        guard !debouncedSearchText.isEmpty else {
            return pokemonList
        }

        let lowercasedSearch = debouncedSearchText.lowercased()

        let startsWithMatches = pokemonList.filter {
            $0.name.english.lowercased().hasPrefix(lowercasedSearch)
        }

        let containsMatches = pokemonList.filter {
            $0.name.english.lowercased().contains(lowercasedSearch) &&
            !$0.name.english.lowercased().hasPrefix(lowercasedSearch)
        }

        return startsWithMatches + containsMatches
    }

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                List(filteredList) { pokemon in
                    Button {
                        selectedId = pokemon.id
                        dismiss()
                    } label: {
                        Text("\(pokemon.id) - \(pokemon.name.english)")
                    }
                    .id(pokemon.id)
                }
                // Auto scroll to currently selected Id
                .onAppear {
                    DispatchQueue.main.async {
                        proxy.scrollTo(selectedId, anchor: .top)
                    }
                }
                .navigationTitle("Search Pokédex")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            }
        }
        .presentationDragIndicator(.visible)
        .task(id: searchText) {
            try? await Task.sleep(nanoseconds: 300_000_000)  // 300ms debounce delay
            debouncedSearchText = searchText
        }
    }
}


#Preview {
    ContentView()
}
