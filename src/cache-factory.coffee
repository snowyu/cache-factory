# Copyright (c) 2014-2015 Riceball LEE, MIT License
customFactory         = require('custom-factory')
injectMethods         = require('util-ex/lib/injectMethods')
inherits              = require('inherits-ex/lib/inherits')
isInheritedFrom       = require('inherits-ex/lib/isInheritedFrom')
createObject          = require('inherits-ex/lib/createObject')
extend                = require('inherits-ex/lib/_extend')
Codec                 = require('buffer-codec-bytewise')
isFunction            = require('util-ex/lib/is/type/function')
isString              = require('util-ex/lib/is/type/string')
isObject              = require('util-ex/lib/is/type/object')
bytewise              = Codec('bytewise')

module.exports = (Factory, aOptions)->
  return Factory if Factory._cache?

  #customFactory(Factory, aOptions)

  registeredObjects = Factory._objects
  aliases = Factory._aliases

  getInstance = (aName, aOptions)->
    instanced = aOptions.instance if aOptions?
    if instanced?
      cls = Factory[aName]
      if cls is undefined
        aName = Factory.getRealNameFromAlias aName
        cls = Factory[aName] if aName
      return unless cls
      if instanced is false or not instanced.cached
        # createObject(Class, arg1, arg2) = new Class(arg1, arg2)
        result = createObject cls, undefined, aOptions
      else
        if instanced.name?
          instanced = instanced.name
        else
          opts = aOptions or {}
          delete opts.instance
          delete opts.name
          opts.path = Factory.path cls
          #aOptions.name = aName unless aOptions.name?
          instanced = bytewise.encode(opts)
        if isString instanced
          result = instanceCache[instanced]
          if result is undefined
            result = createObject cls, undefined, aOptions
            instanceCache[instanced] = result
        else
          result = Factory._get(aName, aOptions)
    else
      result = Factory._get(aName, aOptions)
    return result

  Factory.get = getInstance if getInstance isnt Factory.get

  # the Static(Class) Methods for Factory:
  extend Factory,
    _cache: instanceCache = {}
