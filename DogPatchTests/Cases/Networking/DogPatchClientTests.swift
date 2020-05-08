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
  
  //*************************************************
  // MARK: - Properties
  //*************************************************
  var sut: DogPatchClient!
  var baseURL: URL!
  var Mocksession: URLSession!
  
  var getDogsURL: URL {
    return URL(string: "dogs", relativeTo: baseURL)!
  }
  
  //*************************************************
  // MARK: - Lifecycle
  //*************************************************
    override func setUp() {
      super.setUp()
      baseURL = URL(string: "https://example.com/api/v1/")!
      Mocksession = MockURLSession()
      
      sut = DogPatchClient(baseURL: baseURL, session: Mocksession, responseQueue: nil)
    }

    override func tearDown() {
      baseURL = nil
      Mocksession = nil
      sut = nil
      super.tearDown()
    }
  
  //*************************************************
  // MARK: - Helper methods
  //*************************************************
  func getDogsHelper(data: Data? = nil, statusCode: Int = 200, error: Error? = nil) -> (calledCompletion: Bool, dogs: [Dog]?, error: Error?) {
    
    let response = HTTPURLResponse(url: getDogsURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    
    var calledCompletion = false
    var receivedDogs: [Dog]? = nil
    var receivedError: Error? = nil
    
    let mockTask = sut.getDogs { (dogs, error) in
      calledCompletion = true
      receivedDogs = dogs
      receivedError = error as NSError?
    } as! MockURLSessionDataTask
    
    mockTask.completionHandler(data, response, error)
    return (calledCompletion, receivedDogs, receivedError)
  }
  
  //*************************************************
  // MARK: - Test cases
  //*************************************************
  func test_init_sets_baseURL() {
    XCTAssertEqual(sut.baseURL, baseURL)
  }
  
  func test_init_sets_session() {
    XCTAssertEqual(sut.session, Mocksession)
  }
  
  func test_getDogs_callsExpectedURL() {
    let mockTask = sut.getDogs { (_, _) in } as! MockURLSessionDataTask
    
    XCTAssertEqual(mockTask.url, getDogsURL)
  }
  
  func test_getDogs_callsResumeOnTask() {
    let mockTask = sut.getDogs { (_, _) in } as! MockURLSessionDataTask
    
    XCTAssertTrue(mockTask.calledResume)
  }
  
  func test_getDogs_givenResponseStatusCode500_callsCompletion() {
    let result = getDogsHelper(statusCode: 500)
    
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.dogs)
    XCTAssertNil(result.error)
  }
  
  func test_getDogs_givenError_callsCompletionWithError() throws {
    let expectedError = NSError(domain: "com.DogPatchTests", code: 42)
    let result = getDogsHelper(error: expectedError)
    
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.dogs)
    
    let actualError = try XCTUnwrap(result.error as NSError?)
    XCTAssertEqual(actualError, expectedError)
  }
  
  func test_getDogs_givenValidJSON_callsCompletionWithDogs() throws {
    let data = try Data.fromJSON(fileName: "GET_Dogs_Response")
    let decoder = JSONDecoder()
    let dogs = try decoder.decode([Dog].self, from: data)
    let result = getDogsHelper(data: data)
    
    XCTAssertTrue(result.calledCompletion)
    XCTAssertEqual(result.dogs, dogs)
    XCTAssertNil(result.error)
  }
  
  func test_getDogs_givenInvalidJSON_callsCompletionWithError() throws {
    let data = try Data.fromJSON(fileName: "GET_Dogs_MissingValuesResponse")
    var expectedError: NSError!
    let decoder = JSONDecoder()
    
    do {
      _ = try decoder.decode([Dog].self, from: data)
    } catch {
      expectedError = error as NSError
    }
    
    let result = getDogsHelper(data: data)
    
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.dogs)
    
    let actualError = try XCTUnwrap(result.error as NSError?)
    XCTAssertEqual(actualError.domain, expectedError.domain)
    XCTAssertEqual(actualError.code, expectedError.code)
  }
  
  func test_init_sets_responseQueue() {
    let responseQueue = DispatchQueue.main
    
    sut = DogPatchClient(baseURL: baseURL, session: Mocksession, responseQueue: responseQueue)
    
    XCTAssertEqual(sut.responseQueue, responseQueue)
  }
}
