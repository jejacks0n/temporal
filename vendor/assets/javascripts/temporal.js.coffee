# Temporal -- use detect() to detect, and reference() if you need a reference
# to the class so you can use it.
# -----------------------------------------------------------------------------
class Temporal

  jsonpCallback = "geoSuccessCallback#{parseInt(Math.random() * 10000)}"

  @detect: (username = null, callback = null) =>
    new Temporal(username, callback)

  constructor: (@username = null, @callback = null) ->
    @detect()

  detect: ->
    timezone = @detectLocally()
    @geoLocate() if @username and navigator.geolocation and timezone.offset != @get().offset
    @set(timezone)

  detectLocally: ->
    januaryOffset = @januaryOffset()
    juneOffset = @juneOffset()
    key = {offset: januaryOffset, dst: 0, hemisphere: HEMISPHERE_UNKNOWN}
    if januaryOffset - juneOffset < 0
      key = {offset: januaryOffset, dst: 1, hemisphere: HEMISPHERE_NORTH}
    else if januaryOffset - juneOffset > 0
      key = {offset: juneOffset, dst: 1, hemisphere: HEMISPHERE_SOUTH}
    new TimeZone("#{([key.offset, key.dst].join(','))}#{if key.hemisphere is HEMISPHERE_SOUTH then ',s' else ''}")

  geoLocate: ->
    navigator.geolocation.getCurrentPosition(@geoSuccess, ->)

  geoSuccess: (position) =>
    window[jsonpCallback] = @parseGeoResponse
    script = document.createElement('script')
    script.setAttribute('src', "http://api.geonames.org/timezoneJSON?lat=#{position.coords.latitude}&lng=#{position.coords.longitude}&username=#{@username}&callback=#{jsonpCallback}")
    document.getElementsByTagName('head')[0].appendChild(script)

  parseGeoResponse: (response) =>
    delete(window[jsonpCallback])
    @set(new TimeZone(name: response.timezoneId, offset: response.rawOffset)) if response.timezoneId

  set: (@timezone) ->
    window.timezone = @timezone
    expiration = new Date()
    expiration.setMonth(expiration.getMonth() + 1)
    document.cookie = "timezone=#{@timezone.name}; expires=#{expiration.toGMTString()}"
    document.cookie = "timezone_offset=#{@timezone.offset}; expires=#{expiration.toGMTString()}"
    @callback?(@timezone)

  get: ->
    name: @getCookie('timezone')
    offset: parseFloat(@getCookie('timezone_offset')) || 0

  getCookie: (name) ->
    match = document.cookie.match(new RegExp("(?:^|;)\\s?#{name}=(.*?)(?:;|$)", 'i'))
    match && unescape(match[1])

  januaryOffset: ->
    @dateOffset(new Date(2011, 0, 1, 0, 0, 0, 0))

  juneOffset: ->
    @dateOffset(new Date(2011, 5, 1, 0, 0, 0, 0))

  dateOffset: (date) ->
    -date.getTimezoneOffset()


# Timezone -- contains offset and timezone name
# -----------------------------------------------------------------------------
class TimeZone

  dateIsDst = (date) ->
    (((if date.getMonth() > 5 then @juneOffset() else @januaryOffset())) - @dateOffset(date)) isnt 0

  resolveAmbiguity = ->
    ambiguous = AMBIGIOUS_ZONES[@name]
    return if typeof(ambiguous) is 'undefined'
    for key, value of ambiguous
      if dateIsDst(DST_START_DATES[value])
        @name = value
        return

  constructor: (keyOrProperties) ->
    if typeof(keyOrProperties) == 'string'
      zone = TIMEZONES[keyOrProperties]
      @[property] = value for own property, value of zone
      resolveAmbiguity()
    else
      @[property] = value for own property, value of keyOrProperties


# Expose Temporal to the global scope
# -----------------------------------------------------------------------------
@Temporal = {detect: Temporal.detect, reference: -> Temporal}


# Data
# -----------------------------------------------------------------------------
HEMISPHERE_SOUTH = 'SOUTH'
HEMISPHERE_NORTH = 'NORTH'
HEMISPHERE_UNKNOWN = 'N/A'
AMBIGIOUS_ZONES =
  'America/Denver': ['America/Denver', 'America/Mazatlan']
  'America/Chicago': ['America/Chicago', 'America/Mexico_City']
  'America/Asuncion': ['Atlantic/Stanley', 'America/Asuncion', 'America/Santiago', 'America/Campo_Grande']
  'America/Montevideo': ['America/Montevideo', 'America/Sao_Paolo']
  'Asia/Beirut': ['Asia/Gaza', 'Asia/Beirut', 'Europe/Minsk', 'Europe/Istanbul', 'Asia/Damascus', 'Asia/Jerusalem', 'Africa/Cairo']
  'Asia/Yerevan': ['Asia/Yerevan', 'Asia/Baku']
  'Pacific/Auckland': ['Pacific/Auckland', 'Pacific/Fiji']
  'America/Los_Angeles': ['America/Los_Angeles', 'America/Santa_Isabel']
  'America/New_York': ['America/Havana', 'America/New_York']
  'America/Halifax': ['America/Goose_Bay', 'America/Halifax']
  'America/Godthab': ['America/Miquelon', 'America/Godthab']
DST_START_DATES =
  'America/Denver': new Date(2011, 2, 13, 3, 0, 0, 0)
  'America/Mazatlan': new Date(2011, 3, 3, 3, 0, 0, 0)
  'America/Chicago': new Date(2011, 2, 13, 3, 0, 0, 0)
  'America/Mexico_City': new Date(2011, 3, 3, 3, 0, 0, 0)
  'Atlantic/Stanley': new Date(2011, 8, 4, 7, 0, 0, 0)
  'America/Asuncion': new Date(2011, 9, 2, 3, 0, 0, 0)
  'America/Santiago': new Date(2011, 9, 9, 3, 0, 0, 0)
  'America/Campo_Grande': new Date(2011, 9, 16, 5, 0, 0, 0)
  'America/Montevideo': new Date(2011, 9, 2, 3, 0, 0, 0)
  'America/Sao_Paolo': new Date(2011, 9, 16, 5, 0, 0, 0)
  'America/Los_Angeles': new Date(2011, 2, 13, 8, 0, 0, 0)
  'America/Santa_Isabel': new Date(2011, 3, 5, 8, 0, 0, 0)
  'America/Havana': new Date(2011, 2, 13, 2, 0, 0, 0)
  'America/New_York': new Date(2011, 2, 13, 7, 0, 0, 0)
  'Asia/Gaza': new Date(2011, 2, 26, 23, 0, 0, 0)
  'Asia/Beirut': new Date(2011, 2, 27, 1, 0, 0, 0)
  'Europe/Minsk': new Date(2011, 2, 27, 3, 0, 0, 0)
  'Europe/Istanbul': new Date(2011, 2, 27, 7, 0, 0, 0)
  'Asia/Damascus': new Date(2011, 3, 1, 2, 0, 0, 0)
  'Asia/Jerusalem': new Date(2011, 3, 1, 6, 0, 0, 0)
  'Africa/Cairo': new Date(2011, 3, 29, 4, 0, 0, 0)
  'Asia/Yerevan': new Date(2011, 2, 27, 4, 0, 0, 0)
  'Asia/Baku': new Date(2011, 2, 27, 8, 0, 0, 0)
  'Pacific/Auckland': new Date(2011, 8, 26, 7, 0, 0, 0)
  'Pacific/Fiji': new Date(2010, 11, 29, 23, 0, 0, 0)
  'America/Halifax': new Date(2011, 2, 13, 6, 0, 0, 0)
  'America/Goose_Bay': new Date(2011, 2, 13, 2, 1, 0, 0)
  'America/Miquelon': new Date(2011, 2, 13, 5, 0, 0, 0)
  'America/Godthab': new Date(2011, 2, 27, 1, 0, 0, 0)
TIMEZONES =
  '-720,0':   {offset: -12,   name: 'Etc/GMT+12'}
  '-660,0':   {offset: -11,   name: 'Pacific/Pago_Pago'}
  '-600,1':   {offset: -11,   name: 'America/Adak'}
  '-660,1,s': {offset: -11,   name: 'Pacific/Apia'}
  '-600,0':   {offset: -10,   name: 'Pacific/Honolulu'}
  '-570,0':   {offset: -10.5, name: 'Pacific/Marquesas'}
  '-540,0':   {offset: -9,    name: 'Pacific/Gambier'}
  '-540,1':   {offset: -9,    name: 'America/Anchorage'}
  '-480,1':   {offset: -8,    name: 'America/Los_Angeles'}
  '-480,0':   {offset: -8,    name: 'Pacific/Pitcairn'}
  '-420,0':   {offset: -7,    name: 'America/Phoenix'}
  '-420,1':   {offset: -7,    name: 'America/Denver'}
  '-360,0':   {offset: -6,    name: 'America/Guatemala'}
  '-360,1':   {offset: -6,    name: 'America/Chicago'}
  '-360,1,s': {offset: -6,    name: 'Pacific/Easter'}
  '-300,0':   {offset: -5,    name: 'America/Bogota'}
  '-300,1':   {offset: -5,    name: 'America/New_York'}
  '-270,0':   {offset: -4.5,  name: 'America/Caracas'}
  '-240,1':   {offset: -4,    name: 'America/Halifax'}
  '-240,0':   {offset: -4,    name: 'America/Santo_Domingo'}
  '-240,1,s': {offset: -4,    name: 'America/Asuncion'}
  '-210,1':   {offset: -3.5,  name: 'America/St_Johns'}
  '-180,1':   {offset: -3,    name: 'America/Godthab'}
  '-180,0':   {offset: -3,    name: 'America/Argentina/Buenos_Aires'}
  '-180,1,s': {offset: -3,    name: 'America/Montevideo'}
  '-120,0':   {offset: -2,    name: 'America/Noronha'}
  '-120,1':   {offset: -2,    name: 'Etc/GMT+2'}
  '-60,1':    {offset: -1,    name: 'Atlantic/Azores'}
  '-60,0':    {offset: -1,    name: 'Atlantic/Cape_Verde'}
  '0,0':      {offset: 0,     name: 'Africa/Casablanca'}
  '0,1':      {offset: 0,     name: 'Europe/London'}
  '60,1':     {offset: 1,     name: 'Europe/Berlin'}
  '60,0':     {offset: 1,     name: 'Africa/Lagos'}
  '60,1,s':   {offset: 1,     name: 'Africa/Windhoek'}
  '120,1':    {offset: 2,     name: 'Asia/Beirut'}
  '120,0':    {offset: 2,     name: 'Africa/Johannesburg'}
  '180,1':    {offset: 3,     name: 'Europe/Moscow'}
  '180,0':    {offset: 3,     name: 'Asia/Baghdad'}
  '210,1':    {offset: 3.5,   name: 'Asia/Tehran'}
  '240,0':    {offset: 4,     name: 'Asia/Dubai'}
  '240,1':    {offset: 4,     name: 'Asia/Yerevan'}
  '270,0':    {offset: 4.5,   name: 'Asia/Kabul'}
  '300,1':    {offset: 5,     name: 'Asia/Yekaterinburg'}
  '300,0':    {offset: 5,     name: 'Asia/Karachi'}
  '330,0':    {offset: 5,     name: 'Asia/Kolkata'}
  '345,0':    {offset: 5.75,  name: 'Asia/Kathmandu'}
  '360,0':    {offset: 6,     name: 'Asia/Dhaka'}
  '360,1':    {offset: 6,     name: 'Asia/Omsk'}
  '390,0':    {offset: 6,     name: 'Asia/Rangoon'}
  '420,1':    {offset: 7,     name: 'Asia/Krasnoyarsk'}
  '420,0':    {offset: 7,     name: 'Asia/Jakarta'}
  '480,0':    {offset: 8,     name: 'Asia/Shanghai'}
  '480,1':    {offset: 8,     name: 'Asia/Irkutsk'}
  '525,0':    {offset: 8.75,  name: 'Australia/Eucla'}
  '525,1,s':  {offset: 8.75,  name: 'Australia/Eucla'}
  '540,1':    {offset: 9,     name: 'Asia/Yakutsk'}
  '540,0':    {offset: 9,     name: 'Asia/Tokyo'}
  '570,0':    {offset: 9.5,   name: 'Australia/Darwin'}
  '570,1,s':  {offset: 9.5,   name: 'Australia/Adelaide'}
  '600,0':    {offset: 10,    name: 'Australia/Brisbane'}
  '600,1':    {offset: 10,    name: 'Asia/Vladivostok'}
  '600,1,s':  {offset: 10,    name: 'Australia/Sydney'}
  '630,1,s':  {offset: 10.5,  name: 'Australia/Lord_Howe'}
  '660,1':    {offset: 11,    name: 'Asia/Kamchatka'}
  '660,0':    {offset: 11,    name: 'Pacific/Noumea'}
  '690,0':    {offset: 11.5,  name: 'Pacific/Norfolk'}
  '720,1,s':  {offset: 12,    name: 'Pacific/Auckland'}
  '720,0':    {offset: 12,    name: 'Pacific/Tarawa'}
  '765,1,s':  {offset: 12.75, name: 'Pacific/Chatham'}
  '780,0':    {offset: 13,    name: 'Pacific/Tongatapu'}
  '840,0':    {offset: 14,    name: 'Pacific/Kiritimati'}
