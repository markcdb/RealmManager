# RealmManager
A threaded and easier way of persisting data using Realm Mobile Database

Uses [RealmSwift][0]

## Installation
### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.9.1+ is required to build RealmManager 4.3.0+.

To integrate RealmManager into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'RealmManager', '~> 4.3.0'
end
```

Then, run the following command:

```bash
$ pod install
```
### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate RealmManager into your project manually.

## Usage

### Initializing

You can explicitly state the Object you'll gonna be managing for the session during initialization:

```swift
    //Object must be a subclass of Realm.Object
    let manager = RealmManager<Object> = RealmManager(configuration: nil,
                                                      fileUrl: nil)
```

### Add or Update an object to existing model:

You can simply use this method to add or update an object to an existing model

##### Note: This repo assumes each object as unique, thus the model needs to have a primaryKey
 
```swift
    //object must be a subclass of Realm.Object
    RealmManager.addOrUpdate(object: object, 
                             completion: { (error) in
        //Code goes here
    })
```

or if you need to have a configuration for your Realm instance

```swift
    var config = Realm.Configuration()
    
    let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:  
    "group.com.directurl")!.appendingPathComponent("db.realm")
    
    config.fileURL = directory
       
    //Foo must subclass to Realm.Object
    let foo = Foo(description:"Bar")

    RealmManager.addOrUpdate(configuration: config, 
                             object: foo, 
                             completion: { (error) in
        //Code goes here
    })
```

object can be an instance of ```Object```,```Array```,```Dictionary<AnyHashable,AnyObject>```, or ```AnyObject```.

### Fetching

Fetching an object from the Realm DB:

```swift
    //Foo must subclass to Realm.Object
    let foo = Foo(description:"Bar")
            
    RealmManager.fetch(condition: "description == '\(foo.description)'", 
                       completion: { (result) in
                       
        //Your code can do anything with 'result' >:)
    })
            
```

### Deleting

Map and Delete an object by using predicate:

```swift
    RealmManager.delete(object: nil,
                        condition: "description = \(foo.description)",
                        completion: { (error) in

        //Code goes here
    })     
```

or if you have the object and not need to map it:

```swift
    RealmManager.deleteObject(object: foo, 
                              completion: { (error) in
        //Code goes here
    })
```


## Author

markcdb , mark.buot1394@gmail.com

## License

RealmManager is available under the MIT license. See the LICENSE file for more info.

[0]: https://cocoapods.org/pods/RealmSwift  "Realm Swift"

