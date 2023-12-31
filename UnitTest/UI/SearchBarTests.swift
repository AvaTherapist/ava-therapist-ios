//
//  SearchBarTests.swift
//  UnitTests
//
//  Created by Cyrus Refahi on 9/2/23.
//  Copyright © 2020 Cyrus Refahi. All rights reserved.
//

import XCTest
import SwiftUI
import ViewInspector
//@testable import CountriesSwiftUI
//
//final class SearchBarTests: XCTestCase {
//    
//    func test_searchBarCoordinator_beginEditing() {
//        let text = Binding(wrappedValue: "abc")
//        let sut = SearchBar.Coordinator(text: text)
//        let searchBar = UISearchBar(frame: .zero)
//        searchBar.delegate = sut
//        XCTAssertTrue(sut.searchBarShouldBeginEditing(searchBar))
//        XCTAssertTrue(searchBar.showsCancelButton)
//        XCTAssertEqual(text.wrappedValue, "abc")
//    }
//    
//    func test_searchBarCoordinator_endEditing() {
//        let text = Binding(wrappedValue: "abc")
//        let sut = SearchBar.Coordinator(text: text)
//        let searchBar = UISearchBar(frame: .zero)
//        searchBar.delegate = sut
//        XCTAssertTrue(sut.searchBarShouldEndEditing(searchBar))
//        XCTAssertFalse(searchBar.showsCancelButton)
//        XCTAssertEqual(text.wrappedValue, "abc")
//    }
//    
//    func test_searchBarCoordinator_textDidChange() {
//        let text = Binding(wrappedValue: "abc")
//        let sut = SearchBar.Coordinator(text: text)
//        let searchBar = UISearchBar(frame: .zero)
//        searchBar.delegate = sut
//        sut.searchBar(searchBar, textDidChange: "test")
//        XCTAssertEqual(text.wrappedValue, "test")
//    }
//    
//    func test_searchBarCoordinator_cancelButtonClicked() {
//        let text = Binding(wrappedValue: "abc")
//        let sut = SearchBar.Coordinator(text: text)
//        let searchBar = UISearchBar(frame: .zero)
//        searchBar.text = text.wrappedValue
//        searchBar.delegate = sut
//        sut.searchBarCancelButtonClicked(searchBar)
//        XCTAssertEqual(searchBar.text, "")
//        XCTAssertEqual(text.wrappedValue, "")
//    }
//}
