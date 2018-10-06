# Changelog

## 2.0.0
* Remove `#everything` method. (Breaking change.)
* Calling any method which takes the `limit` argument with  `limit`
  set to `:all` will automatically handle pagination, fetching all
  matching objects.
* Calling with `limit` set to `:lazy` returns a lazy `Enumerable`
  over which you can iterate. Every element is an object,
* Added one-word methods like `#snoozed`, `#active` and so-on to the
  `Alert` class. These replicate the behaviour of similarly named
  methods in the v1 SDK. (Though they use different underlying API
  calls, as the alerts API has changed significantly.)
* Added `#pending` and `#ongoing` methods to the `MaintenanceWindow`
  class.
* Added `MaintenanceWindow#summary` method, replicating the
  behaviour of the `summary` v1 API call.
* Added `#ids`, `#names` and `#empty?` helper methods to `Response` class.
* Add `Distribution` class to help you write [Histogram
  distributions](https://docs.wavefront.com/proxies_histograms.html).

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
