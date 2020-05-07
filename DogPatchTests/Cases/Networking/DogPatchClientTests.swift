/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
@testable import DogPatch

class DogPatchClientTests: XCTestCase {
  
  var sut: DogPatchClient!
  var baseURL: URL!
  var Mocksession: URLSession!
  
    override func setUp() {
      super.setUp()
      baseURL = URL(string: "https://example.com/api/v1/")!
      Mocksession = MockURLSession()
      sut = DogPatchClient(baseURL: baseURL, session: Mocksession)
    }

    override func tearDown() {
      baseURL = nil
      Mocksession = nil
      sut = nil
      super.tearDown()
    }
  
  func test_init_sets_baseURL() {
    XCTAssertEqual(sut.baseURL, baseURL)
  }
  
  func test_init_sets_session() {
    XCTAssertEqual(sut.session, Mocksession)
  }
  
  func test_getDogs_callsExpectedURL() {
    let getDogsURL = URL(string: "dogs", relativeTo: baseURL)!
    let mockTask = sut.getDogs { (_, _) in } as! MockURLSessionDataTask
    
    XCTAssertEqual(mockTask.url, getDogsURL)
  }
  
  func test_getDogs_callsResumeOnTask() {
    let mockTask = sut.getDogs { (_, _) in } as! MockURLSessionDataTask
    
    XCTAssertTrue(mockTask.calledResume)
  }
}
