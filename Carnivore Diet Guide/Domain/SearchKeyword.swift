//
//  SearchKeyword.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/30/24.
//

import Foundation

struct SearchKeyword: Identifiable, Hashable {

    var id: String { text }
    let text: String
    let score: UInt
    
    static func keywordsFrom(string: String) -> Set<SearchKeyword> {
        var keywords = Set<SearchKeyword>()
        
        string.lemmatized()
            .forEach { lemma in
                if let keyword = SearchKeyword(lemma) {
                    keywords.insert(keyword)
                }
            }
        
        return keywords
    }
    
    init?(_ text: String, score: UInt = 1) {
        // Trim whitespace
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for minimum and maximum length
        guard trimmedText.count >= 3, trimmedText.count <= 30 else {
            return nil
        }
        
        // Check for allowed characters (alphanumeric and hyphens)
        let allowedCharacters = CharacterSet.alphanumerics.subtracting(.decimalDigits)
        guard trimmedText.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
            return nil
        }
        
        // Check for minimum score value
        guard score > 0 else {
            return nil
        }
        
        // Convert to lowercase
        self.text = trimmedText.lowercased()
        self.score = score
    }
    
    static let samples: Set<SearchKeyword> = {
        let text = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse eleifend urna sit amet tincidunt suscipit. In felis nunc, ornare sit amet leo eu, tristique lacinia purus. Vivamus feugiat nec odio vel bibendum. Nulla a vulputate sem. Curabitur a viverra massa, nec aliquet urna. Integer scelerisque massa a laoreet egestas. Morbi semper et libero eu dapibus. Vivamus mattis tortor id gravida commodo. Aliquam varius leo et porttitor malesuada. Proin ac nisi vel nulla malesuada elementum in varius libero. Aenean nec fringilla arcu, vitae volutpat neque. Phasellus rutrum massa non diam laoreet, sit amet rhoncus justo hendrerit.
        
Aliquam nec sapien lacus. Morbi sagittis, arcu id posuere rhoncus, sapien odio laoreet eros, et placerat est massa a purus. Vivamus id orci neque. Praesent hendrerit velit non eros bibendum, nec vulputate mauris mollis. Nulla vel tortor feugiat, venenatis nulla sed, pellentesque lorem. Suspendisse sagittis congue felis eget pharetra. Curabitur venenatis ex id eros vulputate, quis porta diam facilisis. Aenean aliquet ipsum urna, id fermentum mi rhoncus posuere. Sed luctus mollis quam, nec feugiat libero dictum nec. Donec commodo fringilla nisl, ac placerat risus fermentum a. Donec euismod dui non tellus facilisis venenatis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nullam massa purus, ornare id est vitae, porta iaculis lectus. Curabitur eget nisi maximus, volutpat nibh sed, tincidunt est. Pellentesque augue velit, porttitor id vestibulum nec, rutrum vitae neque.

Suspendisse id tincidunt diam. Vivamus id nunc id mi tempor hendrerit. Integer dignissim eros ut placerat lacinia. Etiam libero elit, convallis at sem eget, pharetra malesuada turpis. Etiam egestas est a odio lobortis, sit amet pellentesque lorem dignissim. Nam aliquam diam quis dolor egestas, ut aliquam dui viverra. Fusce pretium laoreet lobortis. Mauris in enim sed ligula pretium porttitor. Vestibulum egestas ultricies auctor. Integer porttitor augue sed magna placerat, at accumsan purus luctus. Ut suscipit est eget odio condimentum, quis dapibus mi auctor. Maecenas ac cursus quam, vel convallis leo.

Aenean ac dui pretium, rutrum tellus non, cursus nulla. Aliquam pharetra orci eget purus ultricies, in faucibus neque gravida. Nullam placerat tempus tellus eget commodo. Nullam at placerat leo. Sed massa velit, malesuada a pharetra id, iaculis eget diam. Aliquam eget laoreet nisl. Sed at massa justo. Duis eu justo in diam hendrerit ultrices. Interdum et malesuada fames ac ante ipsum primis in faucibus. Morbi nec lacinia turpis. Pellentesque convallis consequat imperdiet. Aliquam et maximus odio. Interdum et malesuada fames ac ante ipsum primis in faucibus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae;

Vestibulum pharetra dolor eget sapien tincidunt, ut commodo mi tincidunt. Suspendisse hendrerit eros non tortor congue tempus. Quisque bibendum aliquam interdum. Duis quis augue facilisis, ullamcorper nulla ut, lacinia nisi. Suspendisse quis sagittis velit. Donec egestas non tellus sed condimentum. Nam commodo ante a tortor accumsan, vel porta magna porttitor. Cras condimentum feugiat libero, non pharetra sapien sodales at. Phasellus et urna dolor. In hac habitasse platea dictumst. Nam mollis convallis purus eget tempor.
"""
        
        var dict = Dictionary<String, Int>()
        
        text
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .split(separator: " ")
            .forEach {
                let key = String($0)
                dict[key] = (dict[key] ?? 0) + 1
            }
        
        var set = Set<SearchKeyword>()
        for (key, value) in dict {
            if let keyword = SearchKeyword(key, score: UInt(value)) {
                set.insert(keyword)
            }
        }
        return set
    }()
}
