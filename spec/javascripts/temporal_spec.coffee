#= require temporal

describe "Temporal", ->

  beforeEach ->
    document.cookie = 'timezone='
    document.cookie = 'timezone_offset='
    @timezoneStub = {name: 'foo', offset: 0}  # 0 here ensure the jsonp request isn't made

  describe "signature", ->

    it "has a detect and reference method", ->
      expect(Object.keys(Temporal).length).toBe 2
      expect(Object.keys(Temporal)).toEqual ['detect', 'reference']
      expect(typeof(Temporal.detect)).toBe 'function'
      expect(typeof(Temporal.reference)).toBe 'function'


  describe ".detect", ->

    beforeEach ->
      window.Temporal = Temporal.reference() if Temporal.reference
      @spy = spyOn(Temporal.prototype, 'detectLocally').andReturn @timezoneStub
      @callback = ->

    it "instantiates an instance and passes arguments", ->
      instance = Temporal.detect('username', @callback)
      expect(@spy).toHaveBeenCalled()
      expect(instance.username).toBe 'username'
      expect(instance.callback).toBe @callback


  describe "constructor", ->

    it "calls #detectLocally", ->
      spy = spyOn(Temporal.prototype, 'detectLocally').andReturn @timezoneStub
      new Temporal()
      expect(spy.callCount).toBe 1

    it "calls #geoLocate if there's a username for the GeoName API", ->
      spyOn(Temporal.prototype, 'detectLocally').andReturn name: 'foo', offset: 1
      spy = spyOn(Temporal.prototype, 'geoLocate')
      new Temporal('username')
      if navigator.geolocation
        expect(spy.callCount).toBe 1

    it "doesn't call #geoLocate if there isn't a username", ->
      spyOn(Temporal.prototype, 'detectLocally').andReturn name: 'foo', offset: 1
      spy = spyOn(Temporal.prototype, 'geoLocate')
      new Temporal()
      expect(spy.callCount).toBe 0

    it "calls #set", ->
      spyOn(Temporal.prototype, 'detectLocally').andReturn @timezoneStub
      spy = spyOn(Temporal.prototype, 'set')
      new Temporal()
      expect(spy.callCount).toBe 1
      expect(spy).toHaveBeenCalledWith name: 'foo', offset: 0


  describe "#detectLocally", ->

    beforeEach ->
      spyOn(Temporal.prototype, 'detect')
      @temporal = new Temporal()

    it "returns a quickly determined time zone", ->
      spyOn(Temporal.prototype, 'januaryOffset').andReturn -420
      spyOn(Temporal.prototype, 'juneOffset').andReturn -360
      timezone = @temporal.detectLocally()
      expect(timezone).toEqual name: 'America/Denver', offset: -7

    it "handles other locations than denver", ->
      spyOn(Temporal.prototype, 'januaryOffset').andReturn 120
      spyOn(Temporal.prototype, 'juneOffset').andReturn 120
      timezone = @temporal.detectLocally()
      expect(timezone).toEqual name: 'Africa/Johannesburg', offset: 2
