# Communicating w/ JS libs

We have to output to a separate JS file so that
we can more easily build our elm app and have JS
functions to respond to port message subscriptions.
```
elm make src/PortExamples.elm --output elm.js
```

This is an important feature of Elm since some things
can't be done easily in elm, compared to JS, since the
number of available libs is so different. This inter-op
feature also allows for gradual introduction of Elm into
JS projects, bit by bit.

This is all done via the built-in "port" keyword, which
handles the magic. Elm treats JS like a remote server,
passing data and messages asynchronously to avoid having
a direct dependency on JS code. JS code must subscribe to
the elm app in order to receive port messages.

To get data back from JavaScript, our elm app has to define
subscriptions which will listen for messages delivered
to us from the JS layer.

For this example, the JS we are communicating with is inside
the index.html page, where we create our elm app. So if running
this with `elm reactor`, make sure to open the HTML file,not
the elm file when testing the JS communication.
