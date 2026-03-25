//
//  ContentView.swift
//  Filmdatabasen
//
//  Created by Ibrahim Jasim Alsalih on 2026-03-25.
//

import SwiftUI

struct Film {
    let name: String
    let year: String
    let genre: String
}

struct ContentView: View {
    var body: some View {
        let films = [
           Film(name: "The Matrix", year: "1999", genre: "Action, Sci-Fi"),
           Film(name: "The Dark Knight", year: "2008", genre: "Action, Crime, Drama"),
           Film(name: "Inception", year: "2010", genre: "Action, Adventure, Sci-Fi")
            ]
        
        VStack{
            ForEach(films, id: \.name) { film in
                VStack(alignment: .leading){
                    Text(film.name)
                        .font(.largeTitle)
                    Text("\(film.year) | \(film.genre)")
                        .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
    }
}

#Preview {
    ContentView()
}
