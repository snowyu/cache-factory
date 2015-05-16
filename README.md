### CacheFactory [![Build Status](https://img.shields.io/travis/snowyu/cache-factory.js/master.svg)](http://travis-ci.org/snowyu/cache-factory.js) [![npm](https://img.shields.io/npm/v/cache-factory.svg)](https://npmjs.org/package/cache-factory) [![downloads](https://img.shields.io/npm/dm/cache-factory.svg)](https://npmjs.org/package/cache-factory) [![license](https://img.shields.io/npm/l/cache-factory.svg)](https://npmjs.org/package/cache-factory)


add the cacheable items ability to CustomFactory.

* CacheFactory
  * `constructor(aName, aOptions)`: get a singleton instance or create a new instance item.
  * `constructor(aOptions)`: get a singleton instance or create a new instance item.
    * aOptions: *(object)*
      * name: the factory item name. defaults to the constructor name
      * instance:
        * *(string)*: used as the cached name
        * *(boolean)*: used as the cached.
        * *(object)*:
          * name:  used as cached name if exists.
          * cached: *(boolean)* whether retrieve from cache. defaults to true.
            create a new instance always if it's false.

# Usage


### developer:

```coffee

factory   = require 'custom-factory'
cacheable = require 'cache-factory'

class Codec
  factory Codec
  cacheable Codec


  constructor: (aName, aOptions)->return super
  initialize: (aOptions)->
    @bufferSize = aOptions.bufSize if aOptions
  encode:->

register = Codec.register
aliases  = Codec.aliases

class TextCodec
  register TextCodec
  aliases TextCodec, 'utf8', 'utf-8'
  constructor: Codec
  encode:->

class JsonCodec
  register JsonCodec, TextCodec
  constructor: -> return super
  encode:->
```

Enable a flat factory:

```coffee

class Codec
  factory Codec, flatOnly: true

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
json3 = JsonCodec(bufSize:123, instance: "MyJson")
json3 = JsonCodec(bufSize:123, instance: {name: "MyJson", cached: true})

```
