# Changelog

* Always pass through invalid timestamp on time-parsing error.

## 5.4.2 (2021-01-11)
* Fix bug which blocked event updates.

## 5.4.1 (2020-12-17)
* Fix error on derived metric modification.

## 5.4.0 (2020-12-16)
* Add `raw_response` option, which makes the SDK return the raw API response
  as plain JSON text, rather than as a `Wavefront::Response` object.

## 5.3.1 (2020-12-11)
* Fix error when renaming ingestion policies, and improve testing which should
  have caught the problem in the first place.

## 5.3.0 (2020-10-10)
* Add `Wavefront::Proxy#shutdown` which can shut down a proxy via the API.

## 5.2.1 (2020-09-18)
* Remove necessity for user to `require 'pathname'`

## 5.2.0 (2020-09-03)
* Add `:raise_on_no_profile` option to `Wavefront::Credentials` constructor
  options. If this is true and a specific config stanza is requested but not
  found, `Wavefront::Exception::MissingConfigProfile` is thrown.

## 5.1.0 (2020-08-15)
* Add `create_aws_external_id`, `delete_aws_external_id`, and
  `confirm_aws_external_id` methods to `Wavefront::CloudIntegration`.

## 5.0.1 (2020-07-08)
* Reinstate `Wavefront::Role#grant` and `Wavefront::Role#revoke`, which were
  accidentally removed prior to release of 5.0.0.

## 5.0.0 (2020-07-08)
* Remove `Wavefront::UserGroup#grant` and `Wavefront::UserGroup#revoke` as [the
 API paths they used have been
 removed](https://docs.wavefront.com/2020.06.x_release_notes.html#obsolete-and-deprecated-apis).
 (Breaking change.)
* Remove `Wavefront::MonitoredCluster` class, as it has been removed from the
  public API.
* Deprecate `Wavefront::User` class, as [the user API is now
  deprecated](https://docs.wavefront.com/2020.06.x_release_notes.html#obsolete-and-deprecated-apis)
* Add `Wavefront::Role` class, for managing roles.
* Promote `Wavefront::Spy` class from unstable. It is now an official API.

## 4.0.0 (2020-02-17)
* Drop support for Ruby 2.3. (Breaking change.)
* Add `Wavefront::MonitoredCluster` class.
* Add `Wavefront::Unstable::Spy` class to speak to (undocumented) spy
  interface.
* Add `Wavefront::Unstable::Chart` class to speak to (undocumented) chart
  interface.

## 3.7.1 (2020-02-09)
* `Response` object returned by `Wavefront::Write#write` includes a valid HTTP
  code, rather than `nil`.

## 3.7.0 (2020-01-23)
* Add `Account`, `Usage` and `IngestionPolicy` classes.
* Allow modification of `Wavefront::Response`'s `response` object.
* Add `User#validate_users` method.

## 3.6.1 (2020-01-15)
* Test build against, and fix warning messages on, Ruby 2.7.0

## 3.6.0 (2019-11-12)
* Add `User#business_functions` method.
* Update Faraday and Rubocop dependencies

## 3.5.0 (2019-09-30)
* Extend `apitoken` class to cover new service account paths.

## 3.4.0 (2019-09-28)
* Add `serviceaccount` class.
* Validator exceptions now return the value which failed validation.

## 3.3.4 (2019-09-18)
* Upgrade Rubocop dev dependency to 0.74.0, and make codebase compliant with
  those standards. No interfaces are changed.

## 3.3.3 (2019-09-10)
* Fix slightly misleading verbose message when using recursive or
  lazy calls
* Fix bug where `Alert#versions` would fault on a noop.
* Make `Search` work correctly with API classes which use cursors.
* Improve user response shim, and its tests.

## 3.3.2 (2019-05-24)
* Don't report `moreItems` as true at the end of a recursive GET.

## 3.3.1 (2019-05-10)
* Better handling of query errors.

## 3.3.0 (2019-05-09)
* Reflect the way the API ACL format has changed.

## 3.2.0 (2019-05-01)
* Add support for new `apitoken` path.
* Add support for alert ACLs
* Tag and ACL methods have been broken out into mixins which are
  automatically included by classes which support them

## 3.1.0 (2019-04-23)
* When using `Wavefront::Write`, large numbers of points are written
  in chunks, rather than all at once. The chunk size can be set by
  the user when instantiating the class.

## 3.0.2 (2019-04-06)
* Better handling of non-existent or malformed config files.
* Look for `~/.wavefront.conf` as well as `~/.wavefront`. Both these
  fixes are related to finding out that other Wavefront tooling
  creates `~/.wavefront` as a directory.

## 3.0.1 (2019-04-05)
* User IDs do not have to be e-mail addresses.

## 3.0.0 (2019-03-23)
* Drop support for Ruby 2.2. (Potentially breaking change.)
* Add `Wavefront::Settings` class to cover new `settings` API
  endpoint.
* Add ACL methods to `Wavefront::Dashboard` class.
* Add `Dashboard#favourite` and `Dashboard#unfavourite` methods, as
  aliases to `favorite` and `unfavorite`.
* Add `sort_field` to `Wavefront::Search` options. Lets user select
  the field on which to sort results.

## 2.5.1 (2019-03-06)
* Fix messy handling of raw query errors.

## 2.5.0 (2019-02-21)
* New `Wavefront::UserGroup` class, for new API `UserGroup` feature.
* Extended `Wavefront::User` to cover new API methods.

## 2.4.0 (2019-01-28)
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

## 2.3.0 (2019-01-06)
* When sending points via the API, send bundles of up to 100 points
  with each `POST`, rather than a call per point.

## 2.2.1 (2018-12-20)
* Fix typo in `Wavefront::Alert#affected_by_maintenance` method
  name.
* Full `Wavefront::Alert` test coverage.

## 2.2.0 (2018-12-15)
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

## 2.1.0 (2018-11-25)
* New `unix` writer lets you write points to a local Unix datagram
  socket.

## 2.0.3 (2018-10-23)
* Remove unnecessarily strict argument check on `event#list`.

## 2.0.2 (2018-10-22)
* Bugfix

## 2.0.1 (2018-10-22)
* Bugfix on response types.

## 2.0.0 (2018-10-20)
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

## 1.6.2 (2018-08-22)
* Drop log priority of write class messages.

## 1.6.1 (2018-08-22)
* Fix Ruby 2.2 bugs
* Improve unit test separation
* Allow updating of all external link parameters

## 1.6.0 (2018-08-07)
* Improve validation of point tags.
* Break extensions to standard library out into their own files.
* Improve README.

## 1.5.0 (2018-06-25)
* Add [derived
  metric](https://docs.wavefront.com/derived_metrics.html) support.
* Add this changelog.

## 1.4.0 (2018-04-10)
* Add support for [direct
  ingestion](https://docs.wavefront.com/direct_ingestion.html).

## 1.3.2 (2018-04-03)
* Fix regression in write class.

## 1.3.1 (2018-04-03)
* Fix Ruby 2.2 support.
* Code tidy and linting improvements.

## 1.3.0 (2018-03-29)
* Add support for delta metrics.
* Add automatic pagination support for long lists of objects.
  Such lists can be treated as Ruby enumerables.
* Assume Wavefront proxies are listening on port 2878, though you
  can still override this.
* Improve test coverage.
* Update dependencies.
* Support Ruby 2.5.

## 1.2.1 (2017-10-12)
* Fix bug in relative time support.
* Fix Ruby 2.4 support.

## 1.2.0 (2017-10-12)
* Support relative times through mixin methods.

## 1.1.0 (2017-10-09)
* Add support for notificant (alert target) API path.
* Add support for integration API path.
* Support new source description set/delete API endpoint.

## 1.0.3 (2017-09-20)
* Gracefully handle tags with `nil` values.
* Bump dependencies.

## 1.0.2 (2017-08-04)
* Maintenance window bugfixes.

## 1.0.1 (2017-07-31)
* Fix message ID validator.

## 1.0.0 (2017-06-11)
First official release.
