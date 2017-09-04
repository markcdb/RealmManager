Pod::Spec.new do |s|
  s.name             = 'RealmManager'
  s.version          = '1.0.6'
  s.summary          = 'An easier way of persisting data using Realm Mobile Database'
  s.dependency         'RealmSwift', '~> 2.6.2'
  s.homepage         = 'https://github.com/markcdb/RealmManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'markcdb' => 'mark.buot1394@gmail.com' }
  s.source           = { :git => 'https://github.com/markcdb/RealmManager.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '8.0'
  s.source_files = 'RealmManager/*.swift'
 
end