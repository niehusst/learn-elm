# Single-Page Web Apps in Elm

## Setup

The dummy file host server can be run via `json-server --watch server/db.json -p 5016`

(requires `npm i json-server -g` first)

## Organization (finally)

Typicall advice for Elm apps is that all modules should be built around a central type (aka the Model). This means that each page, which has its own Model type, should be its own module.

Data structs that are used in multiple modules will obvi be stored in their own module for reuse.

A router file handles navigation between different "pages" of our single page app. Then everything is tied together in Main.elm.

