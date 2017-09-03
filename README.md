# RealmManager
An threaded and easier way of persisting data using Realm Mobile Database

## Installation

## Usage

Creating or Updating existing model:


```swift
    RealmManager.createOrUpdate(model: "MODEL_NAME", 
                                object: ["foo":"bar"], 
                                completionHandler: { (error) in
        //code goes here
    })
```

or if you need to have a configuration for your realm instance

```swift
    var config = Realm.Configuration()
    
    let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:  
    "group.com.directurl")!.appendingPathComponent("db.realm")
    
    config.fileURL = directory
    
    let foo = Foo(description:"Bar")

    RealmManager.createOrUpdate(configuration: config, 
                                model: "MODEL_NAME", 
                                object: foo, 
                                completionHandler: { (error) in
        //code goes here
    })
```

object can be an instance of ```Object```,```Array```,```Dictionary<AnyHashable,AnyObject>```, or ```AnyObject```.

