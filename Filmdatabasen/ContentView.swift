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

// MARK: - Film Poster Image
// Reusable view that picks the right image source based on priority:
// user-picked photo > built-in asset > fallback icon
struct FilmPosterImage: View {
    let film: Film
    let fallbackIconSize: CGFloat

    var body: some View {
        if let uiImage = film.customImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if !film.image.isEmpty {
            Image(film.image)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "film")
                .resizable()
                .scaledToFit()
                .padding(fallbackIconSize)
                .foregroundStyle(.red)
        }
    }
}

// MARK: - Film Row
// A single row in the film list showing thumbnail, title and genre
struct FilmRow: View {
    let film: Film

    var body: some View {
        HStack(spacing: 14) {
            // MARK: Thumbnail
            FilmPosterImage(film: film, fallbackIconSize: 8)
                .frame(width: 50, height: 70)
                .clipped()
                .cornerRadius(8)

            // MARK: Film Title & Genre
            VStack(alignment: .leading, spacing: 6) {
                Text(film.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(film.genre)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            // MARK: Red Accent Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.red)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Film Detail View
// Shows full details for a selected film
struct FilmDetailView: View {
    let film: Film

    var body: some View {
        ZStack {
            // MARK: Cinema Background
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                // MARK: Poster Image
                FilmPosterImage(film: film, fallbackIconSize: 40)
                    .scaledToFit()
                    .cornerRadius(12)
                    .padding(.horizontal)

                // MARK: Red Divider
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 2)
                    .padding(.horizontal)

                // MARK: Film Info
                Text(film.name)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                Text(film.year)
                    .font(.title3)
                    .foregroundStyle(.gray)
                Text(film.genre)
                    .font(.title3)
                    .foregroundStyle(.gray)

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle(film.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Add Film Sheet
// A form where the user fills in details and optionally picks a photo
struct AddFilmSheet: View {
    @Binding var films: [Film]
    @Binding var isPresented: Bool

    @State private var newName = ""
    @State private var newYear = ""
    @State private var newGenre = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var newImage: UIImage?

    var body: some View {
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
                                    .foregroundStyle(.red)
                                    .frame(width: 60, height: 80)
                            }
                            Text(newImage == nil ? "Välj bild" : "Byt bild")
                                .foregroundStyle(.red)
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
            .tint(.red)
            .toolbar {
                // MARK: Confirm Button
                // Disabled until a title has been entered
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lägg till") {
                        let film = Film(name: newName, year: newYear, genre: newGenre, image: "", customImage: newImage)
                        films.append(film)
                        isPresented = false
                    }
                    .disabled(newName.isEmpty)
                }
                // MARK: Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") {
                        isPresented = false
                    }
                }
            }
        }
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
    @State private var showAddFilm = false

    // MARK: Search State
    // Holds the current search query entered by the user
    @State private var searchText = ""

    // MARK: Filtered Films
    // Returns all films if search is empty, otherwise filters by name or genre
    var filteredFilms: [Film] {
        if searchText.isEmpty { return films }
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
                        FilmRow(film: film)
                    }
                    // MARK: Row Background
                    .listRowBackground(Color(white: 0.1))
                }
                // MARK: Swipe to Delete
                // Maps the filtered index back to the real films array before removing
                .onDelete { indexSet in
                    let toDelete = indexSet.map { filteredFilms[$0] }
                    films.removeAll { film in toDelete.contains { $0.id == film.id } }
                }
            }
            // MARK: Black List Background
            .scrollContentBackground(.hidden)
            .background(Color.black)
            // MARK: Search Bar
            .searchable(text: $searchText, prompt: "Sök efter film eller genre")
            // MARK: Cinema Navigation Bar Styling
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(.red)
            // MARK: Toolbar
            .toolbar {
                // MARK: Bloody Red Title
                // .principal replaces the default navigation title with a custom styled view
                ToolbarItem(placement: .principal) {
                    Text("Filmdatabasen")
                        .font(.custom("Georgia-BoldItalic", size: 24))
                        .foregroundColor(Color(red: 0.6, green: 0.0, blue: 0.0))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddFilm = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // MARK: Add Film Sheet
            .sheet(isPresented: $showAddFilm) {
                AddFilmSheet(films: $films, isPresented: $showAddFilm)
            }
        }
        // MARK: Force Dark Mode
        // Ensures the cinema theme is consistent regardless of system appearance
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
