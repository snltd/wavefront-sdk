# Changelog

* When using `Wavefront::Write`, large numbers of points are written
  in chunks, rather than all at once. The chunk size can be set by
  the user when instantiating the class.

## 3.0.2 (06/04/2019)
* Better handling of non-existent or malformed config files.
* Look for `~/.wavefront.conf` as well as `~/.wavefront`. Both these
  fixes are related to findind out that other Wavefront tooling
  creates `~/.wavefront` as a directory.

## 3.0.1 (05/04/2019)
* User IDs do not have to be e-mail addresses.

## 3.0.0 (23/03/2019)
* Drop support for Ruby 2.2. (Potentially breaking change.)
* Add `Wavefront::Settings` class to cover new `settings` API
  endpoint.
* Add ACL methods to `Wavefront::Dashboard` class.
* Add `Dashboard#favourite` and `Dashboard#unfavourite` methods, as
  aliases to `favorite` and `unfavorite`.
* Add `sort_field` to `Wavefront::Search` options. Lets user select
  the field on which to sort results.

## 2.5.1 (06/03/2019)
* Fix messy handling of raw query errors.

## 2.5.0 (21/02/2019)
* New `Wavefront::UserGroup` class, for new API `UserGroup` feature.
* Extended `Wavefront::User` to cover new API methods.

## 2.4.0 (28/01/2019)
* New `Wavefront::MetricHelper` class creates and in-memory buffer
  to which you can instantaneously add metrics, flushing it to
  Wavefront when appropriate. All `Writer` types are supported.
* Add `noauto` option to `Write` class. This lets you manage the
  connection yourself without having to pass `false` as the second
  argument to every single `Write#write` call. (Though this still
  works.)
* Improve error handling when proxy socket is not available.
* Raise an exception if an interval is not given when writing a
  histogram.
* Improve `README` instructions on writing metrics.
* Support Ruby 2.6.

## 2.3.0 (06/01/2019)
* When sending points via the API, send bundles of up to 100 points
  with each `POST`, rather than a call per point.

## 2.2.1 (20/12/2018)
* Fix typo in `Wavefront::Alert#affected_by_maintenance` method
  name.
* Full `Wavefront::Alert` test coverage.

## 2.2.0 (15/12/2018)
* New methods to cover new API paths.
 * `Wavefront::Alert#install`,
 * `Wavefront::Alert#uninstall`,
 * `Wavefront::CloudIntegration#disable`
 * `Wavefront::CloudIntegration#enable`
 * `Wavefront::Dashboard#favorite`
 * `Wavefront::Dashboard#unfavorite`
 * `Wavefront::Integration#install_all_alerts`
 * `Wavefront::Integration#uninstall_all_alerts`
 * `Wavefront::Integration#installed`

## 2.1.0 (25/11/2018)
* New `unix` writer lets you write points to a local Unix datagram
  socket.

## 2.0.3 (23/10/2018)
* Remove unnecessarily strict argument check on `event#list`.

## 2.0.2 (22/10/2018)
* Bugfix

## 2.0.1 (22/10/2018)
* Bugfix on response types.

## 2.0.0 (20/10/2018)
* Remove `#everything` method from all classes. (Breaking change.)
* Calling any method which takes the `limit` argument with  `limit`
  set to `:all` will automatically handle pagination, fetching all
  matching objects.
* Calling with `limit` set to `:lazy` returns a lazy `Enumerable`
  over which you can iterate. Every element is an object,
* Added one-word methods like `#snoozed`, `#active` and so-on to the
  `Wavefront::Alert` class. These replicate the behaviour of similarly
  named methods in the v1 SDK. (Though they use different underlying
  API calls, as the alerts API has changed significantly.)
* Added `#pending` and `#ongoing` methods to
  `Wavefront::MaintenanceWindow`.
* Added `MaintenanceWindow#summary` method, replicating the behaviour
  of the `summary` v1 API call.
* Added `#ids`, `#names` and `#empty?` helper methods to
  `Wavefront::Response`.
* Add `Distribution` class to help you write [Histogram
  distributions](https://docs.wavefront.com/proxies_histograms.html).
* Writing points or distributions (or reporting points) shows the
  wire-format point being sent if in `debug` or `verbose` mode.
* Broke up old write classes, moving the transport mechanism
  into a separate class. The interface is backward-compatible,
  though a new `:writer` constructor option  lets you select the
  transport mechanism.
* New transport mechanism class allows points to be HTTP POSTed to a
  proxy rather than being written to a socket.
* The summary object returned when writing points is now a
  standalone class.
* Use `wavefront` rather than `graphite_v2` as the `report` data
  type.
* `Wavefront::Report` is now a shim around `Wavefront::Write`, left
  in for backward-compatability. The "correct" way to send data via
  the API is using `Wavefront::Write`, specifying the `:api` writer.
* `Wavefront::Credentials` object has new `all` method, which gives
  a hash of proxy *and* API credentials. This is useful for passing
  to `Wavefront::Write` as it means all writers will work without
  modifying your code.
* Make `Wavefront::Response#next_item` work with sources. (Or any
  future class which uses a cursor rather than an offset.)
* Make `Wavefront::User` return a response object containing an
  `items` element, like every other class.

## 1.6.2 (22/08/2018)
* Drop log priority of write class messages.

## 1.6.1 (22/08/2018)
* Fix Ruby 2.2 bugs
* Improve unit test separation
* Allow updating of all external link parameters

## 1.6.0 (07/08/2018)
* Improve validation of point tags.
* Break extensions to standard library out into their own files.
* Improve README.

## 1.5.0 (25/06/2018)
* Add [derived
  metric](https://docs.wavefront.com/derived_metrics.html) support.
* Add this changelog.

## 1.4.0 (10/04/2018)
* Add support for [direct
  ingestion](https://docs.wavefront.com/direct_ingestion.html).

## 1.3.2 (03/04/2018)
* Fix regression in write class.

## 1.3.1 (03/04/2018)
* Fix Ruby 2.2 support.
* Code tidy and linting improvements.

## 1.3.0 (29/03/2018)
* Add support for delta metrics.
* Add automatic pagination support for long lists of objects.
  Such lists can be treated as Ruby enumerables.
* Assume Wavefront proxies are listening on port 2878, though you
  can still override this.
* Improve test coverage.
* Update dependencies.
* Support Ruby 2.5.

## 1.2.1 (12/10/2017)
* Fix bug in relative time support.
* Fix Ruby 2.4 support.

## 1.2.0 (12/10/2017)
* Support relative times through mixin methods.

## 1.1.0 (09/10/2017)
* Add support for notificant (alert target) API path.
* Add support for integration API path.
* Support new source description set/delete API endpoint.

## 1.0.3 (20/09/2017)
* Gracefully handle tags with `nil` values.
* Bump dependencies.

## 1.0.2 (04/08/2017)
* Maintenance window bugfixes.

## 1.0.1 (31/07/2017)
* Fix message ID validator.

## 1.0.0 (11/06/2017)
First official release.
