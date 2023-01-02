# intro to side-effects
side effects are a big no-no in functional programming and they ruin a lot of the inherent assumptions we should be able to make about our functional code when we are forced to introduce them (e.g. for HTTP requests or random num generation).

Elm handles this by handing off all side-effect having code to the elm runtime so that all our application logic can remain pure without touching nasty disgusting side-effect-having code. We do this through Cmd messaging and subscription (using Browser.element for our main function instead of Browser.sandbox).

Cmd is a type wrapper for any type of side-effect we want the elm runtime to handle for us. It then (async eventually) returns the result to our functional code via the update function and a Msg (action enum type) that was determined when the Cmd was issued.

More about subscriptions in different mini proj.
