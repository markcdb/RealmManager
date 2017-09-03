# RealmManager
A threaded and easier way of persisting data using Realm Mobile Database

## Installation

## Usage

### Add or Update an object to existing model:

You can simply use this method to add or update an object to an existing model

##### Note: I'm treating each object is unique, thus the model needs to have a primaryKey
 
```swift
    RealmManager.addOrUpdate(model: "MODEL_NAME", 
                                object: ["foo":"bar"], 
                                completionHandler: { (error) in
        //Code goes here
    })
```

or if you need to have a configuration for your Realm instance

```swift
    var config = Realm.Configuration()
    
    let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:  
    "group.com.directurl")!.appendingPathComponent("db.realm")
    
    config.fileURL = directory
    
    let foo = Foo(description:"Bar")

    RealmManager.addOrUpdate(configuration: config, 
                                model: "MODEL_NAME", 
                                object: foo, 
                                completionHandler: { (error) in
        //Code goes here
    })
```

object can be an instance of ```Object```,```Array```,```Dictionary<AnyHashable,AnyObject>```, or ```AnyObject```.

### Fetching

Fetching an object from the Realm DB:

```swift
    let foo = Foo(description:"Bar")
            
    RealmManager.fetch(model: "MODEL_NAME", 
                       condition: "description == '\(foo.description)'", 
                       completionHandler: { (result) in
                       
        //Your code can do anything with 'result' >:)
    })
            
```

### Deleting

Map and Delete an object by using predicate:

```swift
    RealmManager.delete(model: "MODEL_NAME",
                        condition: "description = \(foo.description)",
                        completionHandler: { (error) in

        //Code goes here
    })     
```

or if you have the object and not need to map it:

```swift
    RealmManager.deleteObject(object: foo, 
                              completionHandler: { (error) in
        //Code goes here
    })
```




