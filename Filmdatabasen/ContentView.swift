//
//  ContentView.swift
//  Filmdatabasen
//
//  Created by Ibrahim Jasim Alsalih on 2026-03-25.
//

import SwiftUI

// MARK: - Film Model
// Represents a single film with an auto-generated unique ID
struct Film: Identifiable {
    let id = UUID()
    let name: String
    let year: String
    let genre: String
    let image: String
}

// MARK: - Film Detail View
// Shows full details for a selected film
struct FilmDetailView: View {
    let film: Film

    var body: some View {
        VStack(spacing: 20) {

            // MARK: Poster Image
            // Shows the film's image asset, or a placeholder icon if none exists
            if !film.image.isEmpty {
                Image(film.image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "film")
                    .resizable()
                    .scaledToFit()
                    .padding(40)
                    .foregroundStyle(.secondary)
            }

            // MARK: Film Info
            Text(film.name)
                .font(.title)
                .bold()
            Text(film.year)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(film.genre)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .navigationTitle(film.name)
    }
}

// MARK: - Content View
// Main view showing the list of all films
struct ContentView: View {

    // MARK: Film List State
    // @State makes the array mutable so the list updates when films are added
    @State private var films = [
        Film(name: "The Matrix", year: "1999", genre: "Action, Sci-Fi", image: "TheMatrix"),
        Film(name: "The Dark Knight", year: "2008", genre: "Action, Crime, Drama", image: "DarkKnight"),
        Film(name: "Inception", year: "2010", genre: "Action, Adventurae, Sci-Fi", image: "inception"),
        Film(name: "The Lord of the Rings", year: "2001", genre: "Dark Fantasy, Adventure", image: "Rings")
    ]

    // MARK: Add Film State
    // Controls sheet visibility and holds the text field values
    @State private var showAddFilm = false
    @State private var newName = ""
    @State private var newYear = ""
    @State private var newGenre = ""

    var body: some View {
        NavigationStack {

            // MARK: Film List
            // Each row navigates to the detail view for that film
            List {
                ForEach(films) { film in
                    NavigationLink {
                        FilmDetailView(film: film)
                    } label: {
                        HStack {
                            // MARK: Thumbnail
                            // Shows asset image or a fallback icon for manually added films
                            Group {
                                if !film.image.isEmpty {
                                    Image(film.image)
                                } else {
                                    Image(systemName: "film")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(8)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(width: 50, height: 70)
                            .cornerRadius(8)

                            // MARK: Film Title & Genre
                            VStack(alignment: .leading, spacing: 6) {
                                Text(film.name)
                                    .font(.headline)
                                Text(film.genre)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                // MARK: Swipe to Delete
                // Removes the film at the swiped index from the array
                .onDelete { indexSet in
                    films.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Filmdatabasen")

            // MARK: Toolbar
            // "+" button in the top-right corner opens the add film sheet
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddFilm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }

            // MARK: Add Film Sheet
            // A form where the user fills in details for a new film
            .sheet(isPresented: $showAddFilm) {
                NavigationStack {
                    Form {
                        TextField("Filmtitel", text: $newName)
                        TextField("År", text: $newYear)
                        TextField("Genre", text: $newGenre)
                    }
                    .navigationTitle("Lägg till film")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        // MARK: Confirm Button
                        // Disabled until a title has been entered
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Lägg till") {
                                let film = Film(name: newName, year: newYear, genre: newGenre, image: "")
                                films.append(film)
                                newName = ""
                                newYear = ""
                                newGenre = ""
                                showAddFilm = false
                            }
                            .disabled(newName.isEmpty)
                        }
                        // MARK: Cancel Button
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Avbryt") {
                                showAddFilm = false
                            }
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
