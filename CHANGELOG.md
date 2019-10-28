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
