//
//  CCCategories.swift
//  Goojess
//
//  Created by Simon Blomqvist on 2017-04-15.
//  Copyright © 2017 Carman. All rights reserved.
//

class CCCategories {
    
    fileprivate let entertainmentCategories: [(Float, String)] = [
        
        (1.1, "Book, films & music"),
        (1.2, "Video games")
    ]
    
    fileprivate let homeCategories: [(Float, String)] = [
        
        (2.1, "Garden"),
        (2.2, "Household"),
        (2.3, "Tools")
    ]
    
    fileprivate let retailCategories: [(Float, String)] = [
        
        (3.1, "Clothing - Women"),
        (3.2, "Clothing - Men"),
        (3.3, "Clothing - Kids"),
        (3.4, "Food"),
        (3.5, "Entertainment"),
        (3.6, "Kids"),
        (3.7, "Jewellery & accessories"),
        (3.8, "Bags & luggage"),
        (3.9, "Electronics")
    ]
    
    fileprivate let hobbyCategories: [(Float, String)] = [
        
        (4.1, "Sports"),
        (4.2, "Art & craft"),
        (4.3, "Antique & collectibles")
    ]
    
    func fetchCategoryNameForIndex (_ index: Int) -> String? {
        
        if index == 0 {
            
            return "Entertainment"
        }
            
        else if index == 1 {
            
            return "Home"
        }
            
        else if index == 2 {
            
            return "Retail"
        }
            
        else if index == 3 {
            
            return "Hobbies"
        }
            
        else {
            
            return nil
        }
    }
    
    func fetchCategoryFromFloat (_ float: Float) -> String {
        
        let allCategories = mergeCategories()
        
        let index = allCategories.index(where: {$0.0 == float})
        
        return allCategories[index!].1
    }
    
    func fetchCategoryFromString (_ string: String) -> Float {
        
        let allCategories = mergeCategories()
        
        let index = allCategories.index(where: {$0.1 == string})
        
        return allCategories[index!].0
    }
    
    func fetchCategories () -> [[(Float, String)]] {
        
        return [entertainmentCategories, homeCategories, retailCategories, hobbyCategories]
    }
    
    fileprivate func mergeCategories () -> [(Float, String)] {
        
        var allCategories = [(Float, String)]()
        
        allCategories.append(contentsOf: entertainmentCategories)
        allCategories.append(contentsOf: homeCategories)
        allCategories.append(contentsOf: retailCategories)
        allCategories.append(contentsOf: hobbyCategories)
        
        return allCategories
    }
}
