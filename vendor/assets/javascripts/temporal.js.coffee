class TimeZone

  constructor: (key, @name = '') ->
    if key
      @name = TIMEZONES[key]
      @resolveAmbiguity()

  resolveAmbiguity: ->
    ambiguous = AMBIGIOUS_ZONES[@name]
    return if typeof(ambiguous) is 'undefined'
    for key, value of ambiguous
      if Temporal.dateIsDst(DST_START_DATES[value])
        @name = value
        return

class Temporal

  @detect: (@username = null, @callback = null) =>
    navigator.geolocation.getCurrentPosition(@geoSuccess, ->) if @username and navigator.geolocation
    @fallback()

  @geoSuccess: (position) =>
    window[JSONP_CALLBACK] = @parseGeoResponse
    script = document.createElement('script')
    script.setAttribute('src', "http://api.geonames.org/timezoneJSON?lat=#{position.coords.latitude}&lng=#{position.coords.longitude}&username=#{@username}&callback=#{JSONP_CALLBACK}")
    document.getElementsByTagName('head')[0].appendChild(script)

  @parseGeoResponse: (response) =>
    delete(window[JSONP_CALLBACK])
    @set(new TimeZone(null, response.timezoneId)) if response.timezoneId

  @fallback: =>
    januaryOffset = @januaryOffset()
    juneOffset = @juneOffset()
    key = {offset: januaryOffset, dst: 0, hemisphere: HEMISPHERE_UNKNOWN}
    if januaryOffset - juneOffset < 0
      key = {offset: januaryOffset, dst: 1, hemisphere: HEMISPHERE_NORTH}
    else if januaryOffset - juneOffset > 0
      key = {offset: juneOffset, dst: 1, hemisphere: HEMISPHERE_SOUTH}
    @set(new TimeZone("#{([key.offset, key.dst].join(','))}#{if key.hemisphere is HEMISPHERE_SOUTH then ',s' else ''}"))

  @set: (timezone) ->
    window.timezone = timezone
    document.cookie = "timezone=#{timezone.name}"
    @callback?(timezone)

  @januaryOffset: ->
    @dateOffset(new Date(2011, 0, 1, 0, 0, 0, 0))

  @juneOffset: ->
    @dateOffset(new Date(2011, 5, 1, 0, 0, 0, 0))

  @dateOffset: (date) ->
    -date.getTimezoneOffset()

  @dateIsDst: (date) ->
    (((if date.getMonth() > 5 then @juneOffset() else @januaryOffset())) - @dateOffset(date)) isnt 0

JSONP_CALLBACK = "geoSuccessCallback#{parseInt(Math.random() * 10000)}"
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
  '-720,0': 'Etc/GMT+12'
  '-660,0': 'Pacific/Pago_Pago'
  '-600,1': 'America/Adak'
  '-660,1,s': 'Pacific/Apia'
  '-600,0': 'Pacific/Honolulu'
  '-570,0': 'Pacific/Marquesas'
  '-540,0': 'Pacific/Gambier'
  '-540,1': 'America/Anchorage'
  '-480,1': 'America/Los_Angeles'
  '-480,0': 'Pacific/Pitcairn'
  '-420,0': 'America/Phoenix'
  '-420,1': 'America/Denver'
  '-360,0': 'America/Guatemala'
  '-360,1': 'America/Chicago'
  '-360,1,s': 'Pacific/Easter'
  '-300,0': 'America/Bogota'
  '-300,1': 'America/New_York'
  '-270,0': 'America/Caracas'
  '-240,1': 'America/Halifax'
  '-240,0': 'America/Santo_Domingo'
  '-240,1,s': 'America/Asuncion'
  '-210,1': 'America/St_Johns'
  '-180,1': 'America/Godthab'
  '-180,0': 'America/Argentina/Buenos_Aires,'
  '-180,1,s': 'America/Montevideo'
  '-120,0': 'America/Noronha'
  '-120,1': 'Etc/GMT+2'
  '-60,1': 'Atlantic/Azores'
  '-60,0': 'Atlantic/Cape_Verde'
  '0,0': 'Africa/Casablanca'
  '0,1': 'Europe/London'
  '60,1': 'Europe/Berlin'
  '60,0': 'Africa/Lagos'
  '60,1,s': 'Africa/Windhoek'
  '120,1': 'Asia/Beirut'
  '120,0': 'Africa/Johannesburg'
  '180,1': 'Europe/Moscow'
  '180,0': 'Asia/Baghdad'
  '210,1': 'Asia/Tehran'
  '240,0': 'Asia/Dubai'
  '240,1': 'Asia/Yerevan'
  '270,0': 'Asia/Kabul'
  '300,1': 'Asia/Yekaterinburg'
  '300,0': 'Asia/Karachi'
  '330,0': 'Asia/Kolkata'
  '345,0': 'Asia/Kathmandu'
  '360,0': 'Asia/Dhaka'
  '360,1': 'Asia/Omsk'
  '390,0': 'Asia/Rangoon'
  '420,1': 'Asia/Krasnoyarsk'
  '420,0': 'Asia/Jakarta'
  '480,0': 'Asia/Shanghai'
  '480,1': 'Asia/Irkutsk'
  '525,0': 'Australia/Eucla'
  '525,1,s': 'Australia/Eucla'
  '540,1': 'Asia/Yakutsk'
  '540,0': 'Asia/Tokyo'
  '570,0': 'Australia/Darwin'
  '570,1,s': 'Australia/Adelaide'
  '600,0': 'Australia/Brisbane'
  '600,1': 'Asia/Vladivostok'
  '600,1,s': 'Australia/Sydney'
  '630,1,s': 'Australia/Lord_Howe'
  '660,1': 'Asia/Kamchatka'
  '660,0': 'Pacific/Noumea'
  '690,0': 'Pacific/Norfolk'
  '720,1,s': 'Pacific/Auckland'
  '720,0': 'Pacific/Tarawa'
  '765,1,s': 'Pacific/Chatham'
  '780,0': 'Pacific/Tongatapu'
  '840,0': 'Pacific/Kiritimati'

@Temporal = {detect: Temporal.detect}
