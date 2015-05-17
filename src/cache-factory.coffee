# Copyright (c) 2014-2015 Riceball LEE, MIT License
path                  = require('path')
customFactory         = require('custom-factory')
injectMethods         = require('util-ex/lib/injectMethods')
inherits              = require('inherits-ex/lib/inherits')
isInheritedFrom       = require('inherits-ex/lib/isInheritedFrom')
createObject          = require('inherits-ex/lib/createObject')
extend                = require('inherits-ex/lib/_extend')
extendFilter          = require('util-ex/lib/extend')
isFunction            = require('util-ex/lib/is/type/function')
isString              = require('util-ex/lib/is/type/string')
isObject              = require('util-ex/lib/is/type/object')
isNumber              = require('util-ex/lib/is/type/number')
Cache                 = require('secondary-cache')
Codec                 = require('buffer-codec-bytewise')
bytewise              = Codec('bytewise')

module.exports = (Factory, aOptions)->
  return Factory if Factory._cache?

  cacheSettings =
    capacity: 8192
    fixedCapacity: 8192
  extendFilter cacheSettings, aOptions, (k, v)->
    k in ['capacity', 'fixedCapacity', 'expires', 'cleanInterval'] and
     isNumber(v)
  # the Static(Class) Methods for Factory:
  extend Factory,
    _cache: instanceCache = Cache(cacheSettings)

  customFactory(Factory, aOptions) unless Factory._objects

  registeredObjects = Factory._objects
  aliases = Factory._aliases

  getInstance = (aName, aOptions)->
    cached = aOptions.cached if aOptions?
    if cached?
      cls = Factory[aName]
      if cls is undefined
        aName = Factory.getRealNameFromAlias aName
        cls = Factory[aName] if aName
      return unless cls
      if cached is false
        # createObject(Class, arg1, arg2) = new Class(arg1, arg2)
        result = createObject cls, undefined, aOptions
      else
        # the cache item name:
        if isString cached
          cachedName = cached
          cached = undefined
        else
          popped = cached.popped
          if cached.name?
            cachedName = cached.name
          else
            opts = extend {}, aOptions
            delete opts.cached
            delete opts.name
            #opts.path = Factory.path cls
            #aOptions.name = aName unless aOptions.name?
            cachedName = bytewise.encode(opts)
        if isString(cachedName) and cachedName.length
          if cachedName[0] isnt '/'
            cachedName = path.join(Factory.path(cls), cachedName)
          result = instanceCache.get(cachedName)
          if result is undefined
            result = createObject cls, undefined, aOptions
            cached = undefined unless isObject cached
            instanceCache.set cachedName, result, cached
          else if popped
            instanceCache.del(cachedName)
        else
          result = Factory._get(aName, aOptions)
    else
      result = Factory._get(aName, aOptions)
    return result

  Factory.get = getInstance if getInstance isnt Factory.get
