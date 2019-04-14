# Temporal

[![Build Status](https://secure.travis-ci.org/jejacks0n/temporal.png)](http://travis-ci.org/jejacks0n/temporal)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

Temporal is a small (~7.5k) Javascript library that uses a collection of techniques to determine a clients time zone.
Once a time zone has been determined, a cookie is set which can be used on the server.  Now you can display local times
throughout the rest of the response cycle.

The first method is based on checking various times on different dates to resolve to a short list of time zones.  The
short list is by no means extensive, and is meant to provide the time zone offset -- not specifically the location of
the client.  The data is comprised of the most useful aspects of the [Time Zone Database](http://www.iana.org/time-zones) which keeps the data loaded
on the client small.

The second method is to use the HTML5 Geolocation API combined with the [GeoNames API](http://www.geonames.org/export/web-services.html).  Latitude and longitude is
provided by the client (when approved), and the name/offset of the time zone is fetched using JSONP via the GeoNames
API.  This method provides much more accurate location information -- though I haven't been able to get the two to
methods to disagree about the actual offset, so if you don't need this level of location accuracy you can get by
without it.


## The Story

If you've ever done time zone specific logic in your applications you know it's a bit of a beast.  First, you'll need
to ask each user where they're located to know what time zone you should use when displaying any times converted to
their local time.  Wouldn't it be nice not to have to ask users for their time zone?  That's one step removed from your
sign up / configuration process, and maybe you don't even have a sign up process, in which case it's even harder to
display local times.

I haven't found a really good solution for detecting a users time zone, and I'm not happy asking a user for it, so I
wrote Temporal to determine it for me before ever having to ask.  I'm putting it out there in case anyone else finds it
useful as a tool, or a learning opportunity.


## Installation

### Rails

    gem 'temporal-rails'

Then require temporal in your application.js:

    //= require temporal

### Just the Javascript?

Download [temporal.js](https://raw.github.com/jejacks0n/temporal/master/distro/temporal.js) or [temporal.min.js](https://raw.github.com/jejacks0n/temporal/master/distro/temporal.min.js)
and add them to your project.  The same API applies, but you would need to consume the cookie that's set on the back
end -- using data similar to [TZInfo](http://tzinfo.rubyforge.org/).


## Usage

There's really not much to it.  Call `Temporal.detect()` to trigger the detection.  This method sets a cookie on the
client, and the next request to the server will have that cookie, letting us use it to set the Rails Time.zone (which
is done for you in the Gem).  It's important to note that the exact location of the user isn't guaranteed, so it should
be treated as the time zone, and not the location (eg. don't display it unless you have a way to change it).

The `Temporal.detect` method takes two arguments:

- your GeoNames username -- can be created [here](http://www.geonames.org/login) and also turn on the web service [here](http://www.geonames.org/manageaccount) (it's near the bottom)
- a callback function

If you don't provide the first argument the HTML5 geolocation and GeoNames APIs will not be used.

The callback is called whenever the time zone is set or changed -- it can be called twice if you're using the GeoName
API because Temporal first does the quick detection and sets the cookie based on that, and then calls through to the
GeoNames API.  Since the GoeNames API uses JSONP, the reponse may take a moment to update the cookie further and with
more accuracy.

More reading about time zone handling in rails: [What time is it? Or, handling timezones in Rails](http://databasically.com/2010/10/22/what-time-is-it-or-handling-timezones-in-rails/)

Temporal is as efficient as possible when it comes to refreshing the users time zone and using the GeoNames API.  It
does this by caching the determined time zone for a month, and does a quick check on each page load to see if it looks
like the users time zone has changed (if they're traveling, or have moved, etc.).  If it looks like the time zone may
have changed it will trigger the GoeNames API hit again for clarification.


## License

Licensed under the [MIT License](http://opensource.org/licenses/mit-license.php)

Copyright 2012 [Jeremy Jackson](https://github.com/jejacks0n)


## Enjoy =)
