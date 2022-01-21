<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# HTTP_Client

Flutter package wrap around Http package.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

Add package

```yaml
dependencies:
  http_client:
    git:
      url: git://github.com/wongprayoon/http_client.git
      ref: main
```

```dart
var http = HttpClient();

/// Set Token Schema using default implementation of TotkaSchema ([TokenWithRefreshTokenSchema])
http.setTokenSchema(
  TokenWithRefreshTokenSchema(
    Uri.parse("<refresh token endpoint>"),
    Uri.parse("<sign in endpoint>"),
    (p) => p['jwtToken'],
    (p) => jsonEncode({'refreshToken': p['refreshToken']}),
    jsonEncode({'refreshToken': token.refreshToken}),
    jsonEncode({
      "username": username,
      "password": password
    }),
    DateTime.now(),
    '<jwtToken>',
  )
);

/// Calling
var response = await http.onFetch(
  auth: false,
  builder: (client, headers) => client.post(
      uri.build('/user/signin'),
      headers: headers,
      body: jsonEncode(
        {
	  "username": username,
	  "password": password,
        }
      ),
    )
  );
if (response is HttpResponseOk) {
  // on 200 http response
}
// otherwise throw
throw response;
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
