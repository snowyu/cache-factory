# Copyright (c) 2014-2015 Riceball LEE, MIT License
path                  = require('path.js/lib/path').path
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

  Factory.getCacheName = getCacheName = (aName, aOptions, cls)->
    cached = aOptions.cached if aOptions?
    cached = cached.name if isObject(cached) and cached.name?

    if cached and not isString cached
      # no cache name, so 'hash' it.
      opts = extend {}, aOptions
      delete opts.cached
      delete opts.name
      # encode as cache name.
      cached = bytewise.encode(opts)

    if isString(cached) and cached.length
      if cached[0] isnt '/'
        cls = Factory.registeredClass aName unless cls
        cached = path.join(Factory.path(cls), cached)
    cached


  getInstance = (aName, aOptions)->
    cached = aOptions.cached if aOptions?
    if cached?
      cls = Factory.registeredClass aName
      return unless cls
      popped = cached.popped if cached.popped?
      cachedName = getCacheName aName, aOptions, cls
      if cachedName is false
        # createObject(Class, arg1, arg2) = new Class(arg1, arg2)
        result = createObject cls, undefined, aOptions
      else if isString cachedName
        result = instanceCache.get(cachedName)
        if result is undefined
          result = createObject cls, undefined, aOptions
          cached = undefined unless isObject cached
          instanceCache.set cachedName, result, cached
        else if popped
          instanceCache.del(cachedName)
    result = Factory._get(aName, aOptions) unless result
    return result


  Factory.get = getInstance if getInstance isnt Factory.get
