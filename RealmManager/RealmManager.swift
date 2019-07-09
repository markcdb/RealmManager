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
public class RealmManager {
    
    public typealias Completion = ((_ error: Error?) -> Void)
    
    /// Add or Update an object to existing Model
    ///
    /// Can pass a Realm object, Dictionary, Array,
    /// or Array of objects, takes a closure as escaping
    /// parameter.
    ///
    /// - Parameter configuration: Realm Configuration to be used
    /// - Parameter model: A string of any class NAME that inherits from 'Object' class
    /// - Parameter object: Object to be saved. 'object'
    ///   can be of type [Object], and Object
    /// - Parameter completion: Closure called after
    ///   realm transaction
    /// - Parameter error: an optional value containing error
    public class func addOrUpdate<T: Collection>(configuration: Realm.Configuration? = nil,
                                                 object: T,
                                                 completion:@escaping Completion) where T.Element == Object {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var realm: Realm
                
                if let config = configuration {
                    realm = try Realm(configuration: config)
                } else {
                    realm = try Realm()
                }
                
                addOrUpdateWithRealm(realm: realm,
                                     object: object,
                                     completion: completion)
            } catch let error {
                completion(error)
            }
        }
    }
    
    public class func addOrUpdate<T: Object>(configuration: Realm.Configuration? = nil,
                                             object: T,
                                             completion: @escaping Completion) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            do {
                var realm: Realm
                
                if let config = configuration {
                    realm = try Realm(configuration: config)
                } else {
                    realm = try Realm()
                }
                
                addOrUpdateWithRealm(realm: realm,
                                     object: object,
                                     completion: completion)
            } catch let error {
                completion(error)
            }
        }
    }

    /// Fetches object from existing model
    ///
    ///
    /// - Parameter configuration: Realm Configuration to be used
    /// - Parameter model: A string of any class NAME that inherits from 'Object' class
    /// - Parameter condition: Predicate to be used when fetching
    ///   data from the Realm database (Optional: String)
    /// - Parameter completion: Closure called after the
    ///   realm transaction
    /// - Parameter result: An Array of Object as result from 
    ///   the fetching
    ///
    /// - warning: threading for this function shall be user's preference because
    /// completion handler returns a Realm Object, which requires to be on the
    /// same thread where the realm instance is called
    public class func fetch(configuration: Realm.Configuration, model: String, condition: String?, completion:@escaping(_ result: Results<Object>) -> Void) {
        let realm = try! Realm(configuration: configuration)
        
        fetchWithRealm(model: model, realm: realm, condition: condition, completion: completion)
    }
    
    /// Fetches object from existing model
    ///
    ///
    /// - Parameter model: A string of any class NAME that inherits from 'Object' class
    /// - Parameter condition: Predicate to be used when fetching
    ///   data from the Realm database (Optional: String)
    /// - Parameter completion: Closure called after the
    ///   realm transaction
    /// - Parameter result: An Array of Object as result from
    ///   the fetching
    ///
    /// - warning: threading for this function shall be user's preference because
    /// completion handler returns a Realm Object, which requires to be on the
    /// same thread where the realm instance is called
    public class func fetch(model: String, condition: String?, completion:@escaping(_ result: Results<Object>) -> Void) {
        let realm = try! Realm()
        
        fetchWithRealm(model: model, realm: realm, condition: condition, completion: completion)
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
    public class func delete(configuration: Realm.Configuration, model: String, condition: String, completion:@escaping(_ error: Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let realm = try! Realm(configuration: configuration)
            
            deleteWithRealm(realm: realm,
                            object: nil,
                            condition: condition,
                            completion: completion)
        }
    }

    /// Deletes an object from the existing model
    ///
    ///
    /// - Parameter model: A string of any class NAME that inherits from 'Object' class
    /// - Parameter condition: Predicate to be used when deleting
    ///   data from the Realm database (Optional: String)
    /// - Parameter completion: Closure called after the
    ///   realm transaction
    /// - Parameter error: an optional value containing error
    public class func delete(condition: String,
                             completion:@escaping(_ error: Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let realm = try! Realm()
            
            deleteWithRealm(realm: realm,
                            object: nil,
                            condition: condition,
                            completion: completion)
        }
    }
    
    /// Deletes an object
    ///
    ///
    /// - Parameter configuration: Realm Configuration to be used
    /// - Parameter object: Object to be deleted
    /// - Parameter completion: Closure called after the
    ///   realm transaction
    /// - Parameter error: an optional value containing error
    public class func deleteObject(configuration: Realm.Configuration, object: Object, completion:@escaping(_ error: Error?) -> Void ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let realm = try! Realm(configuration: configuration)
            
            deleteWithRealm(realm: realm,
                            object: object,
                            condition: nil,
                            completion: completion)
        }
    }
    
    /// Deletes an object
    ///
    ///
    /// - Parameter object: Object to be deleted
    /// - Parameter completion: Closure called after the
    ///   realm transaction
    /// - Parameter error: an optional value containing error
    public class func deleteObject(object: Object, completion:@escaping(_ error: Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let realm = try! Realm()
            
            deleteWithRealm(realm: realm,
                            object: object,
                            condition: nil,
                            completion: completion)
        }
    }
}

extension RealmManager {
    ///MARK: FilePrivates
    fileprivate class func fetchWithRealm(model: String, realm: Realm, condition: String?, completion:@escaping(_ result: Results<Object>) -> Void) {
        //NOTE: threading for this function shall be user's preference because
        //completion handler returns a Realm Object, which requires to be on the
        //same thread where the realm instance is called
        
        // All object inside the model passed.
        var fetchedObjects = realm.objects(swiftClassFromString(className: model) as! Object.Type)
        
        if let cond = condition {
            // filters the result if condition exists
            fetchedObjects = fetchedObjects.filter(cond)
        }
        
        completion(fetchedObjects)
    }
    
    fileprivate class func addOrUpdateWithRealm<T: Collection>(realm: Realm,
                                                   object: T,
                                                   completion: @escaping Completion) where T.Element == Object  {
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
    
    fileprivate class func addOrUpdateWithRealm<T: Object>(realm: Realm,
                                                               object: T,
                                                               completion: @escaping Completion) {
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
    
    fileprivate class func deleteWithRealm(realm: Realm, object: AnyObject?, condition: String?, completion:@escaping(_ error: Error?) -> Void) {
        let group = DispatchGroup()
        var error: Error?
        
        if let objE = object as? Object {
            // if object is an instance of Object
            group.enter()
            //no need to do anything, proceed with
            //write func
            error = write(rlmObject: realm, writeBlock: {
                realm.delete(objE)
                group.leave()
            })
            
            
        } else if let arrE = object as? [Object] {
            // if object is an instance of Array of Objects
            group.enter()
            
            error = write(rlmObject: realm, writeBlock: {
                realm.delete(arrE)
                group.leave()
            })
        } else {
            // if object is an instance of Anything other that
            // previously stated types
            group.enter()
            /*
            var fetchedObjects = realm.objects(swiftClassFromString(className: model!) as! Object.Type)
            
            if let cond = condition {
                //if condition exists, filter it
                fetchedObjects = fetchedObjects.filter(cond)
            }
            
            error = write(rlmObject: realm, writeBlock: {
                realm.delete(fetchedObjects)
                group.leave()
            })
            */
        }
        
        group.wait()
        DispatchQueue.main.async {
            completion(error)
        }
    }
    
    fileprivate class func write(rlmObject: Realm, writeBlock:()-> Void) -> Error? {
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
    
    fileprivate class func swiftClassFromString(className: String) -> AnyClass? {
        // Swift equivalent of NSStringFromClass
        // note that accessing swift class is different compared to how
        // objective-c does it,
        //
        // a swift class can be accessed using 'AppName.ClassName' format
        if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String? {
            let fAppName = appName.replacingOccurrences(of: " ", with: "_", options: NSString.CompareOptions.literal, range: nil)
            
            return NSClassFromString("\(fAppName).\(className)")
        }
        return nil;
    }
}

