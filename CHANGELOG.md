4.1.1
=====
Support for unencoded Date + DateTime parameters for query parameters. 

4.1.0
=====
Support for Date and Date-Time to be properly encoded for forms and query parameters (urlencoded, Dart 2.12 null + null-safe)

4.0.0
=====
support for release version of Dio (only change)

4.0.0-prev1
=====
support for the new null safe binaries. pre-release as we are waiting on Dio.

3.2.0
=====
support for toDateString() and toDateStringList(). Had to hard code the dependency for the http multi server
because the 2.1.0 version does not compile.

3.1.0
=====
removing LocalClientApi and QueryParamHelper from api to make it simpler to
use. Introduction of Rich Response for extension methods.

3.0.1
=====
fix for dio content headers

3.0.0
=====
significant refactoring to co-inside with the 3.x release of the Dart plugin cleanup.

2.0.1
======
* swapping to Dio introduced a subtle bug in DELETE for browser. A DELETE with a browser
would cause an exception that couldn't be caught and only showed up in the browser as a
Bad Element.

2.0.0
======
* swap to Dio from the http package. Dio has extensive support for all sorts of features,
particularly including client side certificate pinning.

1.1.1
=======
* http code 204 returns a null json response which caused a crash

1.1.0
=======
* breaking change, generated code needs to know how to serialize

1.0.2
=======
* allow content-type header to be empty

1.0.1
=======
* Feedback from release process

1.0.0
=======
* Initial release tested and working with existing Flutter for Web and e2e Ogurets code.
