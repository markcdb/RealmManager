/*
 * RealmManager
 *
 * Copyright 2017-present Mark Buot.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import Foundation
import Realm
import RealmSwift

/**
 Realm manager class that reduces the boiler plate needed when creating a realm transaction.
 createOrUpdate, and Delete uses background thread
 
 - warning: This class assumes that every existing model being passed has a primaryKey set to it
 */
public class RealmManager<T> {
    
    public typealias Completion = ((_ error: Error?) -> Void)
    
    var realm: Realm?
    
    var background: RealmThread?
    
    private var token: NotificationToken?
    private var configuration: Realm.Configuration?
    private var fileUrl: URL?
    
    init(configuration: Realm.Configuration?,
         fileUrl: URL?) {
        
        self.configuration = configuration
        self.fileUrl = fileUrl
        
        background = RealmThread(start: true,
                                 queue: nil)
        
        background?.enqueue {[weak self] in
            guard let self = self else { return }
            self.realm = self.createRealm(from: configuration, fileUrl: fileUrl)
        }
    }
    
    private func createRealm(from configuration: Realm.Configuration?,
                             fileUrl: URL?) -> Realm {
        do {
            if let config = configuration {
                return try Realm(configuration: config)
            } else if let fileUrl = fileUrl {
                return try Realm(fileURL: fileUrl)
            } else {
                return try Realm()
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}

extension RealmManager {
    
    fileprivate func addOrUpdateWithRealm<Q: Collection>(realm: Realm,
                                                         object: Q,
                                                         completion: @escaping Completion) where Q.Element == Object  {
        do {
            try realm.write {
                realm.add(object,
                          update: .error)
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        } catch (let error) {
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    fileprivate func addOrUpdateWithRealm<T: Object>(realm: Realm,
                                                     object: T,
                                                     completion: @escaping Completion) {
        do {
            try realm.write {
                realm.add(object,
                          update: .modified)
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        } catch (let error) {
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    fileprivate func write(rlmObject: Realm, writeBlock:()-> Void) -> Error? {
        do {
            //try to do a realm transaction
            try rlmObject.write {
                writeBlock()
            }
        } catch let error {
            //catch and return the error if occurs
            return error
        }
        //no error
        return nil
    }
    
    fileprivate func fetch<Q: Object>(condition: String?,
                                      completion: @escaping(_ result: Results<Q>) -> Void) {
        let realm = createRealm(from: configuration, fileUrl: fileUrl)
        debugPrint(realm.refresh())
        
        // All object inside the model passed.
        var objects = realm.objects(Q.self)
                
        if let cond = condition {
            // filters the result if condition exists
            objects = objects.filter(cond)
        }

        completion(objects)
    }
}

extension RealmManager where T: Collection, T.Element == Object {
    
    /// Add or Update an object to existing Model
    ///
    /// Accept any object that conforms to Collection Protocol,
    /// Takes a closure as escaping
    /// parameter.
    ///
    /// - Parameter object: [Object] to be saved.
    /// - Parameter completion: Closure called after
    ///   realm transaction
    /// - Parameter error: an optional value containing error
    public func addOrUpdate(object: T,
                            completion:@escaping Completion) {
        
        background?.enqueue {[weak self] in
            guard let self = self else { return }
            
            guard let realm = self.realm else { return }
            
            self.addOrUpdateWithRealm(realm: realm,
                                      object: object,
                                      completion: completion)
        }
    }
    
    //MARK: - File Private
    fileprivate func delete(condition: String?,
                            objects: T,
                            completion:@escaping(_ error: Error?) -> Void) {
        let group = DispatchGroup()
        var error: Error?

        background?.enqueue {[weak self] in
            group.enter()
            guard let self = self else { return }
            guard let realm = self.realm else { return }
            
            error = self.write(rlmObject: realm, writeBlock: {
                realm.delete(objects)
                group.leave()
            })
        }
        
        group.wait()
        DispatchQueue.main.async {
            completion(error)
        }
    }
}

extension RealmManager where T: Object {
    /// Add or Update an object to existing Model
    ///
    /// Accept any object that is a subclass of Object or RealmObject,
    /// Takes a closure as escaping
    /// parameter.
    ///
    /// - Parameter object: Object to be saved.
    /// - Parameter completion: Closure called after
    ///   realm transaction
    /// - Parameter error: an optional value containing error
    public func addOrUpdate(configuration: Realm.Configuration? = nil,
                            object: T,
                            completion: @escaping Completion) {
        background?.enqueue {[weak self] in
            guard let self = self else { return }
            
            guard let realm = self.realm else { return }
            
            self.addOrUpdateWithRealm(realm: realm,
                                      object: object,
                                      completion: completion)
        }
    }
    
    /// Fetches object from existing model
    ///
    ///
    /// - Parameter type: Type representing the object to be fetch, must be
    /// subclass of Object
    /// - Parameter condition: Predicate to be used when fetching
    ///   data from the Realm database (Optional: String)
    /// - Parameter completion: Closure called after the
    ///   realm transaction
    /// - Parameter result: An Array of Object as result from
    ///   the fetching
    public func fetchWith(condition: String?,
                          completion:@escaping(_ result: Results<T>) -> Void) {
        
        fetch(condition: condition, completion: completion)
    }
    
    /// Deletes an object from the existing model
    ///
    ///
    /// - Parameter configuration: Realm Configuration to be used
    /// - Parameter model: A string of any class NAME that inherits from 'Object' class
    /// - Parameter condition: Predicate to be used when deleting
    ///   data from the Realm database (Optional: String)
    /// - Parameter completion: Closure called after the
    ///   realm transaction
    /// - Parameter error: an optional value containing error
    public func deleteWithObject(_ object: T?,
                                 condition: String,
                                 completion:@escaping(_ error: Error?) -> Void) {
        
        background?.enqueue {[weak self] in
            guard let self = self else { return }
            
            self.delete(object: object,
                        condition: condition,
                        completion: completion)
        }
    }
    
    ///MARK: FilePrivates
    fileprivate func delete(object: T?,
                            condition: String?,
                            completion:@escaping(_ error: Error?) -> Void) {
        guard let realm = realm else { return }
        
        let group = DispatchGroup()
        var error: Error?
        
        background?.enqueue {[weak self] in
            group.enter()
            guard let self = self else { return }
            
            if object == nil {
                var fetched = realm.objects(T.self)
                
                if let cond = condition {
                    // filters the result if condition exists
                    fetched = fetched.filter(cond)
                }
                
                error = self.write(rlmObject: realm, writeBlock: {
                    realm.delete(fetched)
                    group.leave()
                })
            } else {
                if let object = object {
                    error = self.write(rlmObject: realm, writeBlock: {
                        realm.delete(object)
                        group.leave()
                    })
                }
            }
        }
      
        group.wait()
        DispatchQueue.main.async {
            completion(error)
        }
    }
}
