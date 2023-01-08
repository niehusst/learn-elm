# Single-Page Web Apps in Elm

## Setup

The dummy file host server can be run via `json-server --watch server/db.json -p 5019`

(requires `npm i json-server -g` first)

`elm reactor` is also too pidly and weak for full web apps, so we need to use elm-live (requires `npm i elm-live -g` first).
Run with:
```
elm-live src/Main.elm --pushstate -- --output=elm.js
```
We need to specify the ouput js file since we dont want elm-live
to refresh our app source directly into the HTML.

## Organization (finally)

Typicall advice for Elm apps is that all modules should be built around a central type (aka the Model). This means that each page, which has its own Model type, should be its own module.

Data structs that are used in multiple modules will obvi be stored in their own module for reuse.

A router file handles navigation between different "pages" of our single page app. Then everything is tied together in Main.elm.

