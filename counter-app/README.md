# Elm framework/architecture

This app demos some of the most important basics of the elm architecture.
It uses models to represent state (most will be more complex than a type alias for Int, likely a record) and it uses a view function to return the UI for a given state.

Today I learned that the `elm reactor` command isn't powerful enough to actually run your app; it can only show a static page (probably for UI view debugging). You need to run `elm-live src/Counter.elm --pushstate` to really run the app locally for real. Not sure yet if you only need to pass in the file that contains `main` or if you would need to pass in all files...
