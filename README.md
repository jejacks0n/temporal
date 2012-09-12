# Temporal

Temporal is a small (~5.5k) Javascript library that uses a collection of techniques to determine a clients timezone.
Once a timezone has been determined, a cookie is set which can be used on the server.  Now you can display local times
throughout the rest of the response cycle.

The first method is based on checking various times on different dates to resolve to a short list of timezones.  The
short list is by no means extensive, and is meant to provide the timezone offset -- not specifically the location of
the client.  The data is comprised of the most useful aspects of the [Time Zone Database](http://www.iana.org/time-zones) which keeps the data loaded
on the client small.

The second method is to use the HTML5 Geolocation API combined with the [GeoNames API](http://www.geonames.org/export/web-services.html).  Latitude and longitude is
provided by the client (when approved), and the name of the timezone is fetched using JSONP via the GeoNames API.  This
method provides much more accurate location information -- though I haven't been able to get them to disagree about the
actual offset.


## The Story

If you've ever done timezone specific logic in your applications you know it's a bit of a beast.  First, you'll need to
ask each user where they're located to know what timezone you should use when displaying any times converted to their
local timezone.  Wouldn't it be nice not to have to ask users for their timezone?  That's one step removed from your
sign up / configuration process.  Maybe you don't even have a sign up process, in which case it's even harder to
display local times.

I haven't found a good solution for detecting a users timezone, and I'm not happy asking a user for it, so I wrote
Temporal to determine it for me before ever having to ask.  I'm putting it out there in case anyone else finds it
useful as a tool, or a learning opportunity.


## Installation

### Rails

    gem 'temporal-rails'

Then require temporal in your application.js:

    //= require temporal

Just the Javascript?  Download [temporal.js](https://raw.github.com/jejacks0n/temporal/master/distro/temporal.js) or [temporal.min.js](https://raw.github.com/jejacks0n/temporal/master/distro/temporal.min.js).


## Usage

There's really not much to it.  Call `Temporal.detect()` to trigger the detection.  This method sets a cookie on the
client, and the next request to the server will have that cookie, letting us use it to set the Rails Time.zone.  It's
important to note that the exact location of the user isn't guaranteed, so it should be treated as the timezone, and
not the location (eg. don't display it unless you have a way to change it).

The `Temporal.detect` method takes two arguments:

- your GeoNames username -- which can be created [here](http://www.geonames.org/login) and turn on the web service [here](http://www.geonames.org/manageaccount) (it's near the bottom)
- a callback function

If you don't provide the first argument the GeoNames API will not be used.

The callback is called whenever the timezone is set or changed -- it can be called twice if you're using the GeoName
API.  Temporal first does the quick detection and sets the cookie based on that, and then calls through to the
GeoNames API (if a username was provided).  Since the GoeNames API uses JSONP the reponse may take a moment to update
the cookie further and with more accuracy.

More reading about timezone handling in rails: [What time is it? Or, handling timezones in Rails](http://databasically.com/2010/10/22/what-time-is-it-or-handling-timezones-in-rails/)


## Enjoy. =)
