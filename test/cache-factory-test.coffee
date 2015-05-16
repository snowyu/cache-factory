inherits        = require 'inherits-ex/lib/inherits'
chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
chai.use(sinonChai)

createCtor      = require 'inherits-ex/lib/createCtor'
factory         = require 'custom-factory'
cacheable       = require '../src/cache-factory'
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


testCodecInstance = (obj, expectedClass, bufSize)->
  should.exist obj, "testCodecInstance:" + expectedClass.name
  obj.should.be.instanceOf expectedClass
  obj.should.be.instanceOf Codec
  if bufSize > 0
    obj.should.have.property 'bufferSize', bufSize
getClass = (aName, expectedClass, bufSize)->
  aName = aName.toLowerCase()
  My = Codec[aName]
  should.exist My, "My"
  My.should.be.equal expectedClass
  opt = bufSize:bufSize if bufSize?
  my = My opt
  testCodecInstance my, expectedClass, bufSize
  my.should.be.equal Codec(aName)
  My
describe "Cache-able Factory", ->
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
    it "should have register instance method", ->
      myCodec = Codec('MyNew')
      testCodecInstance myCodec, MyNewCodec
      myCodec.should.have.property 'register'
