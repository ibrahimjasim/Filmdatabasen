//
//  ContentView.swift
//  Filmdatabasen
//
//  Created by Ibrahim Jasim Alsalih on 2026-03-25.
//

import SwiftUI
import PhotosUI

// MARK: - Film Model
// Represents a single film with an auto-generated unique ID
// customImage holds a user-picked photo; image holds a built-in asset name
struct Film: Identifiable {
    let id = UUID()
    let name: String
    let year: String
    let genre: String
    let image: String
    var customImage: UIImage? = nil
}

// MARK: - Film Detail View
// Shows full details for a selected film
struct FilmDetailView: View {
    let film: Film

    var body: some View {
        VStack(spacing: 20) {

            // MARK: Poster Image
            // Priority: user-picked photo > built-in asset > fallback icon
            if let uiImage = film.customImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else if !film.image.isEmpty {
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

    // MARK: Photo Picker State
    // selectedPhoto is the raw picker item; newImage is the loaded UIImage
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var newImage: UIImage?

    // MARK: Search State
    // Holds the current search query entered by the user
    @State private var searchText = ""

    // MARK: Filtered Films
    // Returns all films if search is empty, otherwise filters by name or genre
    var filteredFilms: [Film] {
        if searchText.isEmpty {
            return films
        }
        return films.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.genre.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {

            // MARK: Film List
            // Each row navigates to the detail view for that film
            List {
                ForEach(filteredFilms) { film in
                    NavigationLink {
                        FilmDetailView(film: film)
                    } label: {
                        HStack {
                            // MARK: Thumbnail
                            // Priority: user-picked photo > built-in asset > fallback icon
                            Group {
                                if let uiImage = film.customImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else if !film.image.isEmpty {
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
                            .clipped()
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
                // Maps the filtered index back to the real films array before removing
                .onDelete { indexSet in
                    let toDelete = indexSet.map { filteredFilms[$0] }
                    films.removeAll { film in toDelete.contains { $0.id == film.id } }
                }
            }
            .navigationTitle("Filmdatabasen")

            // MARK: Search Bar
            // Appears below the navigation title, filters by film name or genre
            .searchable(text: $searchText, prompt: "Sök efter film eller genre")

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
            // A form where the user fills in details and optionally picks a photo
            .sheet(isPresented: $showAddFilm) {
                NavigationStack {
                    Form {
                        // MARK: Photo Picker Row
                        // Shows the picked image as a preview, or a placeholder if none chosen
                        Section("Omslagsbild") {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                HStack {
                                    if let uiImage = newImage {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 80)
                                            .clipped()
                                            .cornerRadius(8)
                                    } else {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.secondary)
                                            .frame(width: 60, height: 80)
                                    }
                                    Text(newImage == nil ? "Välj bild" : "Byt bild")
                                        .foregroundStyle(.blue)
                                }
                            }
                            // Load the UIImage as soon as the user picks a photo
                            .onChange(of: selectedPhoto) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        newImage = uiImage
                                    }
                                }
                            }
                        }

                        // MARK: Film Info Fields
                        Section("Filminformation") {
                            TextField("Filmtitel", text: $newName)
                            TextField("År", text: $newYear)
                            TextField("Genre", text: $newGenre)
                        }
                    }
                    .navigationTitle("Lägg till film")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        // MARK: Confirm Button
                        // Disabled until a title has been entered
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Lägg till") {
                                let film = Film(name: newName, year: newYear, genre: newGenre, image: "", customImage: newImage)
                                films.append(film)
                                newName = ""
                                newYear = ""
                                newGenre = ""
                                newImage = nil
                                selectedPhoto = nil
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

// MARK: - Preview
#Preview {
    ContentView()
}
