inherits        = require 'inherits-ex/lib/inherits'
chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
chai.use(sinonChai)

path            = require('path.js/lib/path').path
extend          = require('inherits-ex/lib/_extend')
createCtor      = require 'inherits-ex/lib/createCtor'
factory         = require 'custom-factory'
cacheable       = require '../src/cache-factory'
Codec           = require('buffer-codec-bytewise')
bytewise        = Codec('bytewise')
setImmediate    = setImmediate || process.nextTick


class Codec
  factory   Codec
  cacheable Codec

  @formatName: (aName)->aName.toLowerCase()
  constructor: -> return super
  initialize: (aOptions)->
    if 'number' is typeof aOptions
      @bufferSize = aOptions
    else if aOptions
      @bufferSize = aOptions.bufSize


getNamed = (cls, aName)->
  result = path.join(Codec.path(cls), Codec.formatName aName)
  #console.log result
  result

getUnNamed = (cls, aOptions)->
  opts = extend {}, aOptions
  delete opts.cached
  delete opts.name
  #opts.path = Codec.path cls
  path.join(Codec.path(cls), bytewise.encode(opts))


testCodecInstance = (obj, expectedClass, bufSize)->
  should.exist obj, "testCodecInstance:" + expectedClass.name
  obj.should.be.instanceOf expectedClass
  obj.should.be.instanceOf Codec
  if bufSize > 0
    obj.should.have.property 'bufferSize', bufSize
getClass = (aName, expectedClass, bufSize)->
  aName = aName.toLowerCase()
  My = Codec[aName]
  should.exist My, 'My'
  My.should.be.equal expectedClass
  opt = bufSize:bufSize if bufSize?
  my = My opt
  testCodecInstance my, expectedClass, bufSize
  my.should.be.equal Codec(aName)
  My
describe 'Cache-able Factory', ->
  #before (done)->
  #after (done)->
  register  = Codec.register
  aliases   = Codec.aliases
  unregister= Codec.unregister

  class MyNewCodec
    register(MyNewCodec).should.be.ok
    constructor: Codec
  class MyBufferCodec
    register(MyBufferCodec).should.be.ok
    constructor: Codec
  class MyNewSubCodec
    register(MyNewSubCodec, MyNewCodec).should.be.ok
    constructor: -> return super
  class MyNewSub1Codec
    register(MyNewSub1Codec, MyNewSubCodec).should.be.ok
    constructor: Codec
  it 'should have register instance method', ->
    myCodec = Codec('MyNew')
    testCodecInstance myCodec, MyNewCodec
    myCodec.should.have.property 'register'
  it 'should have _cache property', ->
    Codec.should.have.ownProperty '_cache'
  it 'should have default cache settings', ->
    Codec._cache.maxFixedCapacity.should.be.equal 8192
    Codec._cache.maxCapacity.should.be.equal 8192
  it 'should change default cache settings', ->
    class MCodec
      cacheable MCodec,
        capacity: 1024
        fixedCapacity: 2096
        expires: 1000
        cleanInterval: 50
    MCodec._cache.maxFixedCapacity.should.be.equal 2096
    MCodec._cache.maxCapacity.should.be.equal 1024
    MCodec._cache.maxAge.should.be.equal 1000
    MCodec._cache.cleanInterval.should.be.equal 50*1000
  it 'should get un-named cache instance via Codec', ->
    opts = bufSize: 12, cached: true
    name = getUnNamed MyNewCodec, opts
    m = Codec('MyNew', opts)
    testCodecInstance m, MyNewCodec, 12
    Codec._cache.get(name).should.be.equal m
    m1 = Codec('MyNew', opts)
    testCodecInstance m1, MyNewCodec, 12
    m1.should.be.equal m
    Codec._cache.get(name).should.be.equal m1
  it 'should get named cache instance via Codec', ->
    opts  = bufSize: 12, cached: 'm'
    uname = getUnNamed MyNewCodec, opts
    name  = getNamed MyNewCodec, 'm'
    m = Codec('MyNew', opts)
    testCodecInstance m, MyNewCodec, 12
    Codec._cache.get(name).should.be.equal m
    m1 = Codec('MyNew', opts)
    testCodecInstance m1, MyNewCodec, 12
    m1.should.be.equal m
    Codec._cache.get(name).should.be.equal m1
    Codec._cache.get(uname).should.not.be.equal m1
  it 'should get named cache instance through cached.name via Codec', ->
    opts  =
      bufSize: 12
      cached:
        name: 'm'
    uname = getUnNamed MyNewCodec, opts
    name  = getNamed MyNewCodec, 'm'
    m = Codec('MyNew', opts)
    testCodecInstance m, MyNewCodec, 12
    Codec._cache.get(name).should.be.equal m
    m1 = Codec('MyNew', opts)
    testCodecInstance m1, MyNewCodec, 12
    m1.should.be.equal m
    Codec._cache.get(name).should.be.equal m1
    Codec._cache.get(uname).should.not.be.equal m1
  it 'should get un-named cache instance via MyNewCodec', ->
    opts = bufSize: 12, cached: true
    name = getUnNamed MyNewCodec, opts
    m = MyNewCodec(opts)
    testCodecInstance m, MyNewCodec, 12
    Codec._cache.get(name).should.be.equal m
    m1 = MyNewCodec(opts)
    testCodecInstance m1, MyNewCodec, 12
    m1.should.be.equal m
    Codec._cache.get(name).should.be.equal m1
  it 'should get named cache instance via MyNewCodec', ->
    opts  = bufSize: 12, cached: 'm'
    uname = getUnNamed MyNewCodec, opts
    name  = getNamed MyNewCodec, 'm'
    m = MyNewCodec(opts)
    testCodecInstance m, MyNewCodec, 12
    Codec._cache.get(name).should.be.equal m
    m1 = MyNewCodec(opts)
    testCodecInstance m1, MyNewCodec, 12
    m1.should.be.equal m
    Codec._cache.get(name).should.be.equal m1
    Codec._cache.get(uname).should.not.be.equal m1
  it 'should get named cache instance through cached.name via MyNewCodec', ->
    opts  =
      bufSize: 12
      cached:
        name: 'm'
    uname = getUnNamed MyNewCodec, opts
    name  = getNamed MyNewCodec, 'm'
    m = MyNewCodec(opts)
    testCodecInstance m, MyNewCodec, 12
    Codec._cache.get(name).should.be.equal m
    m1 = MyNewCodec(opts)
    testCodecInstance m1, MyNewCodec, 12
    m1.should.be.equal m
    Codec._cache.get(name).should.be.equal m1
    Codec._cache.get(uname).should.not.be.equal m1
  it 'should popup a cache instance through cached.name via MyNewCodec', ->
    opts  =
      cached:
        name: 'm'
        popped: true
    name  = getNamed MyNewCodec, 'm'
    m = MyNewCodec(opts)
    testCodecInstance m, MyNewCodec, 12
    should.not.exist Codec._cache.get(name)
    opts.bufSize = 123
    m1 = MyNewCodec(opts)
    testCodecInstance m1, MyNewCodec, 123
    m1.should.not.be.equal m
  it 'should get named cache instance directly via Codec(no set)', ->
    opts  = bufSize: 123, cached: 'm'
    uname = getUnNamed MyNewCodec, opts
    name  = getNamed MyNewCodec, 'm'
    m = MyNewCodec(opts) # set m to cache
    testCodecInstance m, MyNewCodec, 123
    Codec._cache.get(name).should.be.equal m
    m1 = Codec('/codec/mynew/m')
    testCodecInstance m1, MyNewCodec, 123
    m1.should.be.equal m
    Codec._cache.get(name).should.be.equal m1

  it 'should get named cache instance directly via MyNewCodec(no set)', ->
    opts  = bufSize: 123, cached: 'm'
    uname = getUnNamed MyNewCodec, opts
    name  = getNamed MyNewCodec, 'm'
    m = MyNewCodec(opts) # set m to cache
    testCodecInstance m, MyNewCodec, 123
    Codec._cache.get(name).should.be.equal m
    m1 = MyNewCodec('m')
    testCodecInstance m1, MyNewCodec, 123
    m1.should.be.equal m
    Codec._cache.get(name).should.be.equal m1
