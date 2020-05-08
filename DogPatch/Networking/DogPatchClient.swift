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

import Foundation

class DogPatchClient {
  typealias dataTaskSessionHandler = (([Dog]?, Error?) -> Void)
  
  let baseURL: URL
  let session: URLSession
  
  var responseQueue: DispatchQueue? = nil
  
  init(baseURL: URL, session: URLSession, responseQueue: DispatchQueue?) {
    self.baseURL = baseURL
    self.session = session
    self.responseQueue = responseQueue
  }
  
  func getDogs(completion: @escaping dataTaskSessionHandler) -> URLSessionDataTask {
    let url = URL(string: "dogs", relativeTo: baseURL)!
    let task = session.dataTask(with: url) { (data, response, error) in
      guard let response = response as? HTTPURLResponse, response.statusCode == 200, error == nil, let data = data  else {
        completion(nil, error)
        return
      }
      let decoder = JSONDecoder()
      do {
        let dogs = try decoder.decode([Dog].self, from: data)
        completion(dogs, nil)
      } catch {
        completion(nil, error)
      }
    }
    task.resume()
    return task
  }
}
