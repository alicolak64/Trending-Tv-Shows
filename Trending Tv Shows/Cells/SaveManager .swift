//
//  SaveManager .swift
//  Trending Tv Shows
//
//  Created by Alex Paul on 1/21/21.
//

import Foundation

enum SaveActionType {
    case add
    case remove
}

enum SaveManger{
    static private let defaults = UserDefaults.standard
   
    enum Keys{
        static let favorites = "favorites"
    }
    
    static func collectFavorties(completed:@escaping(Result<[Show], ErroMessage>)->Void){
        guard let favoriteData = defaults.object(forKey: Keys.favorites) as? Data else {
            completed(.success([]))
            return
        }
        do {
            let decoder = JSONDecoder()
            let favorites = try decoder.decode([Show].self, from: favoriteData)
            completed(.success(favorites))
        } catch{
            completed(.failure(.unableToComplete))
        }
        
    }
    
    static func save (favorites: [Show])->ErroMessage?{
        do {
            let encoder = JSONEncoder()
            let encodedFavorite = try encoder.encode(favorites)
            defaults.setValue(encodedFavorite, forKey: Keys.favorites)
            return nil
        }
        catch {
            return.unableToComplete
        }
    }
    
    
    
    
    
    
    
    
    
}
