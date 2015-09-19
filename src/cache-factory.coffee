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

  ###
  # result:
  #  * false: no cache and create a new object instance always.
  #  * 'string': the cache name.
  #  * undefined: no cache and using the global object instance.
  ###
  Factory.getCacheName = getCacheName = (aOptions, aTypeClass)->
    cached = aOptions.cached if aOptions?
    cached = cached.name if isObject(cached) and cached.name?

    if cached
      if isString cached
        cached = Factory.formatName cached
      else
        # no cache name, so 'hash' it.
        opts = extend {}, aOptions
        delete opts.cached
        delete opts.name
        # encode as cache name.
        cached = bytewise.encode(opts)

    if isString(cached) and cached.length
      if cached[0] isnt '/'
        #aTypeClass = Factory.registeredClass aName unless aTypeClass
        cached = path.join(Factory.path(aTypeClass), cached)
    cached


  Factory.getCacheItem = getCacheItem = (aClass, aOptions)->
    cached = aOptions.cached if aOptions?
    if cached?
      popped = cached.popped
      cachedName = getCacheName aOptions, aClass
      if cachedName is false
        # create a new instance always.
        result = createObject aClass, undefined, aOptions
      else if isString cachedName
        result = instanceCache.get(cachedName)
        if result is undefined
          result = createObject aClass, undefined, aOptions
          unless popped
            cached = undefined unless isObject cached
            result.cached = cachedName
            instanceCache.set cachedName, result, cached
        else if popped
          instanceCache.del(cachedName)
    result

  getInstance = (aName, aOptions)->
    cached = aOptions.cached if aOptions?
    if cached?
      cls = Factory.registeredClass aName
      return unless cls
      result = getCacheItem cls, aOptions
    else
      result = Factory._get(aName, aOptions)
      unless result?
        aName = aOptions.name unless aName
        if aName and isString(aName) and aName[0] isnt '/'
          # arguments.callee is forbidden if strict mode enabled.
          # arguments.callee.caller = CustomFactory
          try vCaller = arguments.callee.caller.caller
          if vCaller and isInheritedFrom vCaller, Factory
            cls = vCaller
            vCaller = vCaller.caller
            #get farest hierarchical registered class
            while isInheritedFrom vCaller, cls
              cls = vCaller
              vCaller = vCaller.caller
          aName = path.join(Factory.path(cls), Factory.formatName(aName))
        result = instanceCache.get(aName)
    return result


  Factory.get = getInstance if getInstance isnt Factory.get
