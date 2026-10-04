# timezone (timezone-0.11.1)

## CHANGELOG (ilk 150 satır)
```
## 0.11.1

- Specify `Etc/UTC` as the default timezone (replaces `UTC`)

## 0.11.0

- Make `Location.offset` a `Duration` instead of an `int`.
- Generate list of common locations fom IANA data.
- Move to `dart-lang/labs` monorepo.
- Add timezone data version to generated headers.

# 0.10.2

- Upgrade minimum SDK to `^3.10.0` and the databases to [2025c].

[2025c]: https://lists.iana.org/hyperkitty/list/tz-announce@iana.org/thread/TAGXKYLMAQRZRFTERQ33CEKOW7KRJVAK/

# 0.10.1

- Time zone database updated to 2025b. For your convenience here is the
  announcement for [2025a], [2025b].
- Added a `native` getter for `TZDateTime`. Thanks @klondikedragon!

[2025a]: https://lists.iana.org/hyperkitty/list/tz-announce@iana.org/thread/MWII7R3HMCEDNUCIYQKSSTYYR7UWK4OQ/
[2025b]: https://lists.iana.org/hyperkitty/list/tz-announce@iana.org/thread/6JVHNHLB6I2WAYTQ75L6KEPEQHFXAJK3/

# 0.10.0

- Update time zone-updating script to use `rearguard.zi`.
- Convert `browser.dart` to use `package:http` instead of `dart:html` for HTTP
  requests.
- Time zone database updated to 2024b. For your convenience here is the
  announcement for [2024b].

[2024b]: https://lists.iana.org/hyperkitty/list/tz-announce@iana.org/thread/IZ7AO6WRE3W3TWBL5IR6PMQUL433BQIE/

# 0.9.4

- Support cross-isolate issues by overriding `hashCode` and `operator ==` on
  class `Location`. (see #147)
- Fix incorrect DST transition. (see #166)

# 0.9.3

- Time zone database updated to 2024a. For your convenience here are the
  announcements for [2023d], [2024a].

[2023d]: https://mm.icann.org/pipermail/tz-announce/2023-December.txt
[2024a]: https://mm.icann.org/pipermail/tz-announce/2024-February.txt


# 0.9.2

- Time zone database updated to 2023c. For your convenience here are the
  announcements for [2023a], [2023b], [2023c].

[2023a]: https://mm.icann.org/pipermail/tz-announce/2023-March/000077.html
[2023b]: https://mm.icann.org/pipermail/tz-announce/2023-March/000078.html
[2023c]: https://mm.icann.org/pipermail/tz-announce/2023-March/000079.html

# 0.9.1

- Time zone database updated to 2022g. For your convenience here are the
  announcements for [2022d], [2022e], [2022f], [2022g].

[2022d]: https://mm.icann.org/pipermail/tz-announce/2022-September/000073.html
[2022e]: https://mm.icann.org/pipermail/tz-announce/2022-October/000074.html
[2022f]: https://mm.icann.org/pipermail/tz-announce/2022-October/000075.html
[2022g]: https://mm.icann.org/pipermail/tz-announce/2022-November/000076.html

# 0.9.0

- Time zone database updated to 2022c. For your convenience here are the
  announcements for [2022a], [2022b], [2022c].
- Removed named database files in `lib/data` (for example, `lib/data/2021e.tzf`).
  The only supported database files are all now named `latest_*`.

[2022a]: https://mm.icann.org/pipermail/tz-announce/2022-March/000070.html
[2022b]: https://mm.icann.org/pipermail/tz-announce/2022-August/000071.html
[2022c]: https://mm.icann.org/pipermail/tz-announce/2022-August/000072.html

# 0.8.1

- Time zone database updated to 2021e. For your convenience here are the
  announcements for [2021b], [2021c], [2021d], [2021e].
- Fixed encoding script to not skip a few missing time zones.

[2021b]: https://mm.icann.org/pipermail/tz-announce/2021-September/000066.html
[2021c]: https://mm.icann.org/pipermail/tz-announce/2021-October/000067.html
[2021d]: https://mm.icann.org/pipermail/tz-announce/2021-October/000068.html
[2021e]: https://mm.icann.org/pipermail/tz-announce/2021-October/000069.html

# 0.8.0

- Time zone database updated to 2021a. For your convenience here is the
  announcement for [2021a].
- Time zone databases encoded with UTF-16 instead of base64.
- **Breaking change**: Remove `tool/encode.dart` in favor of
  `tool/encode_dart.dart`.

[2021a]: https://mm.icann.org/pipermail/tz-announce/2021-January/000065.html


# 0.7.0

- **Breaking change**: Change some of TimeZone's constructor parameters to be
  named instead of positional.
- **Breaking change**: Rename `TimeZone.abbr` to `TimeZone.abbreviation`.
- Deprecate `LocationDatabase.isEmpty` in favor of
  `LocationDatabase.isInitialized`.
- Removed `new` usage from examples and fixed a typo in the `TZDateTime.from`
  example.
- Migrate to Dart's null safety language feature.

# 0.6.1

- Updated the `get` script (now `encode_tzf`) to work with a `zoneinfo`
  directory (as created by the `zic` tool) as input. Fetching and compiling this
  directory is now done by a bash script (`refresh.sh`) using standard tools.

  This allows pointing the tool at a custom `zoneinfo` directory.

# 0.6.0

- Stopping internal versioning of time zone data. Only the latest data will be
  included, as there is no use case for using an outdated version.
- Renaming the `_2015_2025` database to `_10y` for it to have a stable name.
  In the past `latest_2010-2020.tzf` had to be renamed to
  `latest_2015-2025.tzf`.

# 0.5.9

- Time zone database updated to 2020d. For your convenience here is the
  announcement for [2020d].

[2020d]: https://mm.icann.org/pipermail/tz-announce/2020-October/000062.html

# 0.5.8

- Time zone database updated to 2020b. For your convenience here is the
  announcement for [2020b].

[2020b]: https://mm.icann.org/pipermail/tz-announce/2020-October/000059.html

# 0.5.7

- Time zone database updated to 2020a. For your convenience here is the
  announcement for [2020a].
- Earlier null checking on some TZDateTime constructor arguments.
- Many internal changes; should not affect API.
```

## README (ilk 200 satır)
```
[![package:timezone](https://github.com/dart-lang/labs/actions/workflows/timezone.yml/badge.svg)](https://github.com/dart-lang/labs/actions/workflows/timezone.yml)
[![pub package](https://img.shields.io/pub/v/timezone.svg)](https://pub.dev/packages/timezone)
[![package publisher](https://img.shields.io/pub/publisher/timezone.svg)](https://pub.dev/packages/timezone/publisher)

# TimeZone

This package provides the [IANA time zone database] and time zone aware
`DateTime` class, [`TZDateTime`].

The current time zone database version is [2025c]. See [the announcement] for
details.

You can update to the current IANA time zone database by running
`tool/refresh.sh`.

Getting the current timezone of the device that the app is running on is  
highly platform dependent and is not a goal of this package. 

## Initialization

[`TimeZone`] objects require time zone data, so the first step is to load
one of our [time zone databases](#databases).

We provide three different APIs to load a database: one which is embedded
into a Dart library, one for browsers, and one for standalone environments.

### Database variants

We offer three different variants of the IANA database:

- **default**: doesn't contain deprecated and historical zones with some
  exceptions like "US/Eastern" and "Etc/UTC"; this is about 75% the size of the
  **all** database.
- **all**: contains all data from the [IANA time zone database].
- **10y**: default database truncated to contain historical data from 5 years 
  ago until 5 years in the future; this database is about 25% the size of the
  default database.

### Initialization from Dart library

This is the recommended way to initialize a time zone database for non-browser
environments. Each Dart library found in `lib/data`, for example
`lib/data/latest.dart`, contains a single no-argument function,
`initializeTimeZones`.

```dart
import 'package:timezone/data/latest.dart' as tz;
void main() {
  tz.initializeTimeZones();
}
```

To initialize the **all** database variant, `import
'package:timezone/data/latest_all.dart'`. To initialize the **10y**
database variant, `import 'package:timezone/data/latest_10y.dart'`.

### Initialization for browser environment

Import `package:timezone/browser.dart` library and run async function
`Future initializeTimeZone([String path])`.

```dart
import 'package:timezone/browser.dart' as tz;

Future<void> setup() async {
  await tz.initializeTimeZone();
  var detroit = tz.getLocation('America/Detroit');
  var now = tz.TZDateTime.now(detroit);
}
```

To initialize the **all** database variant, call
`initializeTimeZone('packages/timezone/data/latest_all.tzf')`. To initialize
the **10y** database variant, call
`initializeTimeZone('packages/timezone/data/latest_10y.tzf')`.

### Initialization for standalone environment

Import `package:timezone/standalone.dart` library and run async function
`Future initializeTimeZone([String path])`.

```dart
import 'package:timezone/standalone.dart' as tz;

Future<void> setup() async {
  await tz.initializeTimeZone();
  var detroit = tz.getLocation('America/Detroit');
  var now = tz.TZDateTime.now(detroit);
}
```

Note: This method likely will not work in a Flutter environment.

To initialize the **all** database variant, call
`initializeTimeZone('data/latest_all.tzf')`. To initialize the **10y**
database variant, call `initializeTimeZone('data/latest_10y.tzf')`.

### Local Location

By default, when library is initialized, local location will be `UTC`.

To overwrite local location you can use `setLocalLocation(Location
location)` function.

```dart
Future<void> setup() async {
  await tz.initializeTimeZone();
  var detroit = tz.getLocation('America/Detroit');
  tz.setLocalLocation(detroit);
}
```


## API

### Library Namespace

The public interfaces expose several top-level functions. It is recommended
then to import the libraries with a prefix (the prefix `tz` is common), or to
import specific members via a `show` clause.

### Location

> Each location in the database represents a national region where all
> clocks keeping local time have agreed since 1970. Locations are
> identified by continent or ocean and then by the name of the
> location, which is typically the largest city within the region. For
> example, America/New_York represents most of the US eastern time
> zone; America/Phoenix represents most of Arizona, which uses
> mountain time without daylight saving time (DST); America/Detroit
> represents most of Michigan, which uses eastern time but with
> different DST rules in 1975; and other entries represent smaller
> regions like Starke County, Indiana, which switched from central to
> eastern time in 1991 and switched back in 2006.
>
> [The tz database](https://www.iana.org/time-zones)

#### Get location by tz database/Olson name

```dart
final detroit = tz.getLocation('America/Detroit');
```

See [Wikipedia list] for more database entry names.

We don't provide any functions to get locations by time zone abbreviations
because of the ambiguities.

> Alphabetic time zone abbreviations should not be used as unique identifiers
> for UTC offsets as they are ambiguous in practice. For example, "EST" denotes
> 5 hours behind UTC in English-speaking North America, but it denotes 10 or 11
> hours ahead of UTC in Australia; and French-speaking North Americans prefer
> "HNE" to "EST".
>
> [The tz database](https://www.iana.org/time-zones)

### TimeZone

TimeZone objects represents time zone and contains offset, DST flag, and name
in the abbreviated form.

```dart
var timeInUtc = DateTime.utc(1995, 1, 1);
var timeZone = detroit.timeZone(timeInUtc.millisecondsSinceEpoch);
```

### TimeZone aware DateTime

The `TZDateTime` class implements the `DateTime` interface from `dart:core`,
and contains information about location and time zone.

```dart
var date = tz.TZDateTime(detroit, 2014, 11, 17);
```

#### Converting DateTimes between time zones

To convert between time zones, just create a new `TZDateTime` object using
`from` constructor and pass `Location` and `DateTime` to the constructor.

```dart
var localTime = tz.DateTime(2010, 1, 1);
var detroitTime = tz.TZDateTime.from(localTime, detroit);
```

This constructor supports any objects that implement `DateTime` interface, so
you can pass a native `DateTime` object or our `TZDateTime`.

### Listing known time zones

After initializing the time zone database, the `timeZoneDatabase` top-level
member contains all of the known time zones. Examples:

```dart
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  var locations = tz.timeZoneDatabase.locations;
```
