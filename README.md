### CacheFactory [![Build Status](https://img.shields.io/travis/snowyu/cache-factory.js/master.svg)](http://travis-ci.org/snowyu/cache-factory.js) [![npm](https://img.shields.io/npm/v/cache-factory.svg)](https://npmjs.org/package/cache-factory) [![downloads](https://img.shields.io/npm/dm/cache-factory.svg)](https://npmjs.org/package/cache-factory) [![license](https://img.shields.io/npm/l/cache-factory.svg)](https://npmjs.org/package/cache-factory)


add the cacheable items ability to CustomFactory.

* CacheFactory
  * `_cache` *(secondary-cache)*: the cache object to hold the instance.
  * `constructor(aName, aOptions)`: get a singleton instance or create a new instance item.
    * aName: the item name. first search the aName in registeredObjects.
      then search in the cache. the cached item name should be a full path or a related path.
  * `constructor(aOptions)`: get a singleton instance or create a new instance item.
    * aOptions *(object)*:
      * name: the factory item name. defaults to the constructor name
      * the cache settings:
        * fixedCapacity: the first fixed cache max capacity size, defaults to unlimit.
        * capacity: the second LRU cache max capacity size, defaults to unlimit.
          deletes the least-recently-used items if reached the capacity.
          capacity > 0 to enable the secondary LRU cache. defaults to 8192.
        * expires: the default expires time (milliscond), defaults to no expires time(<=0).
          it will be put into LRU Cache if has expires time
        * cleanInterval: clean up expired item with a specified interval(seconds) in the
          background. Disable clean in the background if it's value is less than or equal 0.
      * cached:
        * *(string)*: used as the cached name
        * *(boolean)*: create a new instance always if it's false.
        * *(object)*:
          * name *(string)*: used as cached name if exists.
          * popped *(boolean)*: whether popup from cache. default to false.
          * the cache settings(only available if the item is not exists on cache):
            * fixed *(bool)*: set to first level fixed cache if true, defaults to false.
            * expires *(int)*: expires time millisecond. defaults to never expired.
  * `get(aName, aOptions)`: get the singleton object instance(could be from cache)
    * aOptions: *(object)*
      * cached:
        * *(string)*: used as the cached name
        * *(boolean)*: create a new instance always if it's false.
        * *(object)*:
          * name *(string)*: used as cached name if exists.
          * the cache settings(only available if the item is not exists on cache):
            * fixed *(bool)*: set to first level fixed cache if true, defaults to false.
            * expires *(int)*: expires time millisecond. defaults to never expired.

# Usage


### developer:


Class usage:

```coffee
cachedFactory = require 'cache-factory'

class Codec
  cachedFactory Codec

  constructor: (aName, aOptions)->return super
  initialize: (aOptions)->
    @bufferSize = aOptions.bufSize if aOptions
  encode:->
  ...
```

Ability usage:

```coffee
factory   = require 'custom-factory'
cacheable = require 'cache-factory'

class Codec
  factory Codec

# add the cacheable ability to Codec factory.
cacheable Codec

```

### user

```coffee
# get the JsonCodec Class
# note: name is case-sensitive!
TextCodec = Codec['Text']
JsonCodec = Codec['Json']
# or
JsonCodec = TextCodec['Json']

# get the global JsonCodec instance from the Codec
json = Codec('Json', bufSize: 12)
# or:
json = JsonCodec()
text = Codec('Text') # or Codec('utf8')

JsonCodec().should.be.equal Codec('Json')

# create a new JsonCodec instance.
json2 = new JsonCodec(bufSize: 123)

json2.should.not.be.equal json


## get the instance from cache:
json3 = JsonCodec(bufSize:123, cached: "MyJson")
json4 = JsonCodec(bufSize:123, cached: {name: "MyJson"})
json3.should.be.equal json4

json5 = JsonCodec(bufSize:123, cached: true)
json5.should.be.equal json2


json6 = Codec('/Codec/Json/MyJson')
json6.should.be.equal json3

json7 = JsonCodec 'MyJson'
json7.should.be.equal json3

```
