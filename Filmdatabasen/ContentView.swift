//
//  ContentView.swift
//  Filmdatabasen
//
//  Created by Ibrahim Jasim Alsalih on 2026-03-25.
//

import SwiftUI

struct Film:  Identifiable{
    let id = UUID()
    let name: String
    let year: String
    let genre: String
    let image: String
}
 
struct FilmDetailView: View {
    let film: Film
    
    var body: some View {
    
        VStack(spacing:20){
            
           
            Image(film.image)
                .resizable()
                .scaledToFit()
            
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

struct ContentView: View {
        let films = [
            
            Film(name: "The Matrix", year: "1999", genre: "Action, Sci-Fi", image: "TheMatrix"),
           Film(name: "The Dark Knight", year: "2008", genre: "Action, Crime, Drama",image: "DarkKnight"),
            Film(name: "Inception", year: "2010", genre:
                "Action, Adventurae, Sci-Fi", image: "inception"),
            Film(name: "The Lord of the Rings", year: "2001", genre: "Dark Fantasy, Adventure", image: "Rings")
            ]

    
    
    var body: some View {
        NavigationStack{
            List(films){ film in
                NavigationLink {
                    FilmDetailView(film: film)
                } label : {
                    HStack{
                        Image(film.image)
                            .frame(width:50, height:70)
                            .cornerRadius(8)
                        
                   
                    
                    VStack(alignment: .leading, spacing: 6){
                        Text(film.name)
                            .font(.headline)
                        
                        Text(film.genre)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
                        
                    }
                }
          
    
            .navigationTitle("Filmdatabasen")
            
            }
        }
}
    


#Preview {
    ContentView()
}
