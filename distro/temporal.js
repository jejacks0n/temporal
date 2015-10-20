(function() {
  var AMBIGIOUS_ZONES, DST_START_DATES, HEMISPHERE_NORTH, HEMISPHERE_SOUTH, HEMISPHERE_UNKNOWN, TIMEZONES, Temporal, TimeZone,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty;

  Temporal = (function() {
    var jsonpCallback;

    jsonpCallback = "geoSuccessCallback" + (parseInt(Math.random() * 10000));

    Temporal.detect = function(username, callback) {
      if (username == null) {
        username = null;
      }
      if (callback == null) {
        callback = null;
      }
      return new Temporal(username, callback);
    };

    function Temporal(username, callback) {
      this.username = username != null ? username : null;
      this.callback = callback != null ? callback : null;
      this.parseGeoResponse = __bind(this.parseGeoResponse, this);

      this.geoSuccess = __bind(this.geoSuccess, this);

      this.detect();
    }

    Temporal.prototype.detect = function() {
      var timezone;
      timezone = this.detectLocally();
      if (this.username && navigator.geolocation && timezone.offset !== this.get().offset) {
        this.geoLocate();
      }
      return this.set(timezone);
    };

    Temporal.prototype.detectLocally = function() {
      var januaryOffset, juneOffset, key;
      januaryOffset = this.januaryOffset();
      juneOffset = this.juneOffset();
      key = {
        offset: januaryOffset,
        dst: 0,
        hemisphere: HEMISPHERE_UNKNOWN
      };
      if (januaryOffset - juneOffset < 0) {
        key = {
          offset: januaryOffset,
          dst: 1,
          hemisphere: HEMISPHERE_NORTH
        };
      } else if (januaryOffset - juneOffset > 0) {
        key = {
          offset: juneOffset,
          dst: 1,
          hemisphere: HEMISPHERE_SOUTH
        };
      }
      return new TimeZone("" + ([key.offset, key.dst].join(',')) + (key.hemisphere === HEMISPHERE_SOUTH ? ',s' : ''));
    };

    Temporal.prototype.geoLocate = function() {
      return navigator.geolocation.getCurrentPosition(this.geoSuccess, function() {});
    };

    Temporal.prototype.geoSuccess = function(position) {
      var script;
      window[jsonpCallback] = this.parseGeoResponse;
      script = document.createElement('script');
      script.setAttribute('src', "http://api.geonames.org/timezoneJSON?lat=" + position.coords.latitude + "&lng=" + position.coords.longitude + "&username=" + this.username + "&callback=" + jsonpCallback);
      return document.getElementsByTagName('head')[0].appendChild(script);
    };

    Temporal.prototype.parseGeoResponse = function(response) {
      delete window[jsonpCallback];
      if (response.timezoneId) {
        return this.set(new TimeZone({
          name: response.timezoneId,
          offset: response.rawOffset
        }));
      }
    };

    Temporal.prototype.set = function(timezone) {
      var expiration;
      this.timezone = timezone;
      window.timezone = this.timezone;
      expiration = new Date();
      expiration.setMonth(expiration.getMonth() + 1);
      document.cookie = "timezone=" + this.timezone.name + "; expires=" + (expiration.toGMTString());
      document.cookie = "timezone_offset=" + this.timezone.offset + "; expires=" + (expiration.toGMTString());
      return typeof this.callback === "function" ? this.callback(this.timezone) : void 0;
    };

    Temporal.prototype.get = function() {
      return {
        name: this.getCookie('timezone'),
        offset: parseFloat(this.getCookie('timezone_offset')) || 0
      };
    };

    Temporal.prototype.getCookie = function(name) {
      var match;
      match = document.cookie.match(new RegExp("(?:^|;)\\s?" + name + "=(.*?)(?:;|$)", 'i'));
      return match && unescape(match[1]);
    };

    Temporal.prototype.januaryOffset = function() {
      return this.dateOffset(new Date(2011, 0, 1, 0, 0, 0, 0));
    };

    Temporal.prototype.juneOffset = function() {
      return this.dateOffset(new Date(2011, 5, 1, 0, 0, 0, 0));
    };

    Temporal.prototype.dateOffset = function(date) {
      return -date.getTimezoneOffset();
    };

    return Temporal;

  }).call(this);

  TimeZone = (function() {
    var dateIsDst, resolveAmbiguity;

    dateIsDst = function(date) {
      return ((date.getMonth() > 5 ? this.juneOffset() : this.januaryOffset()) - this.dateOffset(date)) !== 0;
    };

    resolveAmbiguity = function() {
      var ambiguous, key, value;
      ambiguous = AMBIGIOUS_ZONES[this.name];
      if (typeof ambiguous === 'undefined') {
        return;
      }
      for (key in ambiguous) {
        value = ambiguous[key];
        if (dateIsDst(DST_START_DATES[value])) {
          this.name = value;
          return;
        }
      }
    };

    function TimeZone(keyOrProperties) {
      var property, value, zone;
      if (typeof keyOrProperties === 'string') {
        zone = TIMEZONES[keyOrProperties];
        for (property in zone) {
          if (!__hasProp.call(zone, property)) continue;
          value = zone[property];
          this[property] = value;
        }
        resolveAmbiguity();
      } else {
        for (property in keyOrProperties) {
          if (!__hasProp.call(keyOrProperties, property)) continue;
          value = keyOrProperties[property];
          this[property] = value;
        }
      }
    }

    return TimeZone;

  })();

  this.Temporal = {
    detect: Temporal.detect,
    reference: function() {
      return Temporal;
    }
  };

  HEMISPHERE_SOUTH = 'SOUTH';

  HEMISPHERE_NORTH = 'NORTH';

  HEMISPHERE_UNKNOWN = 'N/A';

  AMBIGIOUS_ZONES = {
    'America/Denver': ['America/Denver', 'America/Mazatlan'],
    'America/Chicago': ['America/Chicago', 'America/Mexico_City'],
    'America/Asuncion': ['Atlantic/Stanley', 'America/Asuncion', 'America/Santiago', 'America/Campo_Grande'],
    'America/Montevideo': ['America/Montevideo', 'America/Sao_Paolo'],
    'Asia/Beirut': ['Asia/Gaza', 'Asia/Beirut', 'Europe/Minsk', 'Europe/Istanbul', 'Asia/Damascus', 'Asia/Jerusalem', 'Africa/Cairo'],
    'Asia/Yerevan': ['Asia/Yerevan', 'Asia/Baku'],
    'Pacific/Auckland': ['Pacific/Auckland', 'Pacific/Fiji'],
    'America/Los_Angeles': ['America/Los_Angeles', 'America/Santa_Isabel'],
    'America/New_York': ['America/Havana', 'America/New_York'],
    'America/Halifax': ['America/Goose_Bay', 'America/Halifax'],
    'America/Godthab': ['America/Miquelon', 'America/Godthab']
  };

  DST_START_DATES = {
    'America/Denver': new Date(2011, 2, 13, 3, 0, 0, 0),
    'America/Mazatlan': new Date(2011, 3, 3, 3, 0, 0, 0),
    'America/Chicago': new Date(2011, 2, 13, 3, 0, 0, 0),
    'America/Mexico_City': new Date(2011, 3, 3, 3, 0, 0, 0),
    'Atlantic/Stanley': new Date(2011, 8, 4, 7, 0, 0, 0),
    'America/Asuncion': new Date(2011, 9, 2, 3, 0, 0, 0),
    'America/Santiago': new Date(2011, 9, 9, 3, 0, 0, 0),
    'America/Campo_Grande': new Date(2011, 9, 16, 5, 0, 0, 0),
    'America/Montevideo': new Date(2011, 9, 2, 3, 0, 0, 0),
    'America/Sao_Paolo': new Date(2011, 9, 16, 5, 0, 0, 0),
    'America/Los_Angeles': new Date(2011, 2, 13, 8, 0, 0, 0),
    'America/Santa_Isabel': new Date(2011, 3, 5, 8, 0, 0, 0),
    'America/Havana': new Date(2011, 2, 13, 2, 0, 0, 0),
    'America/New_York': new Date(2011, 2, 13, 7, 0, 0, 0),
    'Asia/Gaza': new Date(2011, 2, 26, 23, 0, 0, 0),
    'Asia/Beirut': new Date(2011, 2, 27, 1, 0, 0, 0),
    'Europe/Minsk': new Date(2011, 2, 27, 3, 0, 0, 0),
    'Europe/Istanbul': new Date(2011, 2, 27, 7, 0, 0, 0),
    'Asia/Damascus': new Date(2011, 3, 1, 2, 0, 0, 0),
    'Asia/Jerusalem': new Date(2011, 3, 1, 6, 0, 0, 0),
    'Africa/Cairo': new Date(2011, 3, 29, 4, 0, 0, 0),
    'Asia/Yerevan': new Date(2011, 2, 27, 4, 0, 0, 0),
    'Asia/Baku': new Date(2011, 2, 27, 8, 0, 0, 0),
    'Pacific/Auckland': new Date(2011, 8, 26, 7, 0, 0, 0),
    'Pacific/Fiji': new Date(2010, 11, 29, 23, 0, 0, 0),
    'America/Halifax': new Date(2011, 2, 13, 6, 0, 0, 0),
    'America/Goose_Bay': new Date(2011, 2, 13, 2, 1, 0, 0),
    'America/Miquelon': new Date(2011, 2, 13, 5, 0, 0, 0),
    'America/Godthab': new Date(2011, 2, 27, 1, 0, 0, 0)
  };

  TIMEZONES = {
    '-720,0': {
      offset: -12,
      name: 'Etc/GMT+12'
    },
    '-660,0': {
      offset: -11,
      name: 'Pacific/Pago_Pago'
    },
    '-600,1': {
      offset: -11,
      name: 'America/Adak'
    },
    '-660,1,s': {
      offset: -11,
      name: 'Pacific/Apia'
    },
    '-600,0': {
      offset: -10,
      name: 'Pacific/Honolulu'
    },
    '-570,0': {
      offset: -10.5,
      name: 'Pacific/Marquesas'
    },
    '-540,0': {
      offset: -9,
      name: 'Pacific/Gambier'
    },
    '-540,1': {
      offset: -9,
      name: 'America/Anchorage'
    },
    '-480,1': {
      offset: -8,
      name: 'America/Los_Angeles'
    },
    '-480,0': {
      offset: -8,
      name: 'Pacific/Pitcairn'
    },
    '-420,0': {
      offset: -7,
      name: 'America/Phoenix'
    },
    '-420,1': {
      offset: -7,
      name: 'America/Denver'
    },
    '-360,0': {
      offset: -6,
      name: 'America/Guatemala'
    },
    '-360,1': {
      offset: -6,
      name: 'America/Chicago'
    },
    '-360,1,s': {
      offset: -6,
      name: 'Pacific/Easter'
    },
    '-300,0': {
      offset: -5,
      name: 'America/Bogota'
    },
    '-300,1': {
      offset: -5,
      name: 'America/New_York'
    },
    '-270,0': {
      offset: -4.5,
      name: 'America/Caracas'
    },
    '-240,1': {
      offset: -4,
      name: 'America/Halifax'
    },
    '-240,0': {
      offset: -4,
      name: 'America/Santo_Domingo'
    },
    '-240,1,s': {
      offset: -4,
      name: 'America/Asuncion'
    },
    '-210,1': {
      offset: -3.5,
      name: 'America/St_Johns'
    },
    '-180,1': {
      offset: -3,
      name: 'America/Godthab'
    },
    '-180,0': {
      offset: -3,
      name: 'America/Argentina/Buenos_Aires'
    },
    '-180,1,s': {
      offset: -3,
      name: 'America/Montevideo'
    },
    '-120,0': {
      offset: -2,
      name: 'America/Noronha'
    },
    '-120,1': {
      offset: -2,
      name: 'Etc/GMT+2'
    },
    '-60,1': {
      offset: -1,
      name: 'Atlantic/Azores'
    },
    '-60,0': {
      offset: -1,
      name: 'Atlantic/Cape_Verde'
    },
    '0,0': {
      offset: 0,
      name: 'Africa/Casablanca'
    },
    '0,1': {
      offset: 0,
      name: 'Europe/London'
    },
    '60,1': {
      offset: 1,
      name: 'Europe/Berlin'
    },
    '60,0': {
      offset: 1,
      name: 'Africa/Lagos'
    },
    '60,1,s': {
      offset: 1,
      name: 'Africa/Windhoek'
    },
    '120,1': {
      offset: 2,
      name: 'Asia/Beirut'
    },
    '120,0': {
      offset: 2,
      name: 'Africa/Johannesburg'
    },
    '180,1': {
      offset: 3,
      name: 'Europe/Moscow'
    },
    '180,0': {
      offset: 3,
      name: 'Asia/Baghdad'
    },
    '210,1': {
      offset: 3.5,
      name: 'Asia/Tehran'
    },
    '240,0': {
      offset: 4,
      name: 'Asia/Dubai'
    },
    '240,1': {
      offset: 4,
      name: 'Asia/Yerevan'
    },
    '270,0': {
      offset: 4.5,
      name: 'Asia/Kabul'
    },
    '300,1': {
      offset: 5,
      name: 'Asia/Yekaterinburg'
    },
    '300,0': {
      offset: 5,
      name: 'Asia/Karachi'
    },
    '330,0': {
      offset: 5,
      name: 'Asia/Kolkata'
    },
    '345,0': {
      offset: 5.75,
      name: 'Asia/Kathmandu'
    },
    '360,0': {
      offset: 6,
      name: 'Asia/Dhaka'
    },
    '360,1': {
      offset: 6,
      name: 'Asia/Omsk'
    },
    '390,0': {
      offset: 6,
      name: 'Asia/Rangoon'
    },
    '420,1': {
      offset: 7,
      name: 'Asia/Krasnoyarsk'
    },
    '420,0': {
      offset: 7,
      name: 'Asia/Jakarta'
    },
    '480,0': {
      offset: 8,
      name: 'Asia/Shanghai'
    },
    '480,1': {
      offset: 8,
      name: 'Asia/Irkutsk'
    },
    '525,0': {
      offset: 8.75,
      name: 'Australia/Eucla'
    },
    '525,1,s': {
      offset: 8.75,
      name: 'Australia/Eucla'
    },
    '540,1': {
      offset: 9,
      name: 'Asia/Yakutsk'
    },
    '540,0': {
      offset: 9,
      name: 'Asia/Tokyo'
    },
    '570,0': {
      offset: 9.5,
      name: 'Australia/Darwin'
    },
    '570,1,s': {
      offset: 9.5,
      name: 'Australia/Adelaide'
    },
    '600,0': {
      offset: 10,
      name: 'Australia/Brisbane'
    },
    '600,1': {
      offset: 10,
      name: 'Asia/Vladivostok'
    },
    '600,1,s': {
      offset: 10,
      name: 'Australia/Sydney'
    },
    '630,1,s': {
      offset: 10.5,
      name: 'Australia/Lord_Howe'
    },
    '660,1': {
      offset: 11,
      name: 'Asia/Kamchatka'
    },
    '660,0': {
      offset: 11,
      name: 'Pacific/Noumea'
    },
    '690,0': {
      offset: 11.5,
      name: 'Pacific/Norfolk'
    },
    '720,1,s': {
      offset: 12,
      name: 'Pacific/Auckland'
    },
    '720,0': {
      offset: 12,
      name: 'Pacific/Tarawa'
    },
    '765,1,s': {
      offset: 12.75,
      name: 'Pacific/Chatham'
    },
    '780,0': {
      offset: 13,
      name: 'Pacific/Tongatapu'
    },
    '840,0': {
      offset: 14,
      name: 'Pacific/Kiritimati'
    }
  };

}).call(this);
