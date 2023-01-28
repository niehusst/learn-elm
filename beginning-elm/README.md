### Super basics of elm the framework and what it do

This whole project (in the `beginning-elm/` dir was created with `elm init`. New package deps can be added to an inited project with `elm install` (which I think just uses NPM behind the scenes?).

the `elm-format <file target>` command can be used to format elm files

you can use `elm make <file target>` w/o the `--output` flag and it will create the index.html file for you, but it will lump all your generated js code into the html, which makes testing etc hard. So generally we prefer to invoke make as `elm make <file target> --output elm.js` and import the js into html as usual (see current index.html file). 
```
elm make src/HomePage.elm --output elm.js
```

The `elm reactor` command can be used to run a localhost server to see your elm results in action

the Ellie web app can be used as a in-browser alternative to all this make + reactor stuff

### ---- Syntax thoughts ----

Everything is an immutible constant in Elm (this functional language thing). So you cant have mutable variables ever.

Boolean not in Elm is `not`, and not equal is `/=`. Other bool operators are like C.

Many logic/arithmatic operators can be used in modern standard form; `x / y`, but the traditional prefix form is also available: `(/) x y`

Elm REQUIRES an else statement in conditionals; `if condition then thing1 else thing2`

Functions are defined w/ no special syntax really bcus everyting is function :). Defined function name first, followed by parameter names, all space separated. Then equals sign and function body (if on sep line than =, must indent at least 1 space or Elm will shit itself). Type annotations arent necessary and maybe not even possible because Elm is just too helpful. It enforces type strictness for you (no mixing return types).
e.g.
```elm
awesomeFunction p1 p2 =
  if p1 > p2 then
    p1
  else
    p2
```

Elm allows partial functions. If it detects that a function hasnt been given enough arguments, rather than executing the function, it will return a partial function, which can be used later when given the remaining arguments necessary to run.
```elm
add n1 n2 =
  n1 + n2

partAdd = add 2
res = partAdd 2 
-- res == 4
```
The `|>` forward function application operator or `<|` backward function application operator makes this process a bit simpler by allowing direct feeding of arguments to partial functions:
```elm
res1 =
  1 - 5
    |> add 3

res2 = add 3 <| 1 - 5

-- res1 == res2 == -1
```

You can define local variables using let.

```elm
escapeEarth myVelocity mySpeed fuelStatus =
    let
        escapeVelocityInKmPerSec =
            11.186

        orbitalSpeedInKmPerSec =
            7.67

        whereToLand fuel =
            if fuel == "low" then
                "Land on droneship"

            else
                "Land on launchpad"
    in
    if myVelocity > escapeVelocityInKmPerSec then
        "Godspeed"

    else if mySpeed == orbitalSpeedInKmPerSec then
        "Stay in orbit"

    else
        whereToLand fuelStatus
```

Anonymous funcs can be defined as `\param list -> "function body"`. It's common to also need to wrap them in `()` to disambiguate syntax.
```elm
String.filter (\ch -> ch /= '-') "222-44-1345"
-- occasionally, you can use partial functions as a sub for a full anon func;
String.filter ((/=) '-') "222-44-1234" -- use prefix notation for /= operator

List.filter (String.contains "nerd") ["nerd1", "some jock"]
```

`::` is the cons operator! `1 :: [2]` yields `[1,2]`

Elm does type inference of you functions etc, but you can provide type hints to make things less ambiguous if necessary:
```elm
-- this only allows this concat function to be used w/ string, rather than any appendable
add : String -> String -> String
add s1 s2 =
  s1 ++ s2

-- im guessing the function def is like this because of function partials
funcName : param1Type -> paramNType -> RetType
funcName =
  ... -- definition
```

You can also create new types, basically enums, that arent associated to any existing standard type. (technical term for this is a union type)
```elm
type BasicallyEnum
  = CaseOne
  | CaseTwo
  | CaseN

whichCase : BasicallyEnum -> String
whichCase enumCase =
  case enumCase of
    CaseOne ->
      "its 1"
    CaseTwo ->
      "its 2"
    CaseN ->
      "its n"
    _ ->         -- default case is actually optional because there is finite options w/ enum type
      "oops!"
```
Elm even allows associated types w/ enum cases:
```elm
type Result
  = Loading
  | Success Int
  | Failure Int String

handleResult : Result -> String
handleResult res =
  case res of
    Loading ->
      "loading ..."
    Success httpCode ->
      String.join " "
        [ "succeeded with code"
        , String.fromInt httpCode
        ]
    Failure httpCode errorMsg ->
      String.join " "
        [ "failed with code"
        , String.fromInt httpCode
        , errorMsg
        ]

-- while `Loading` is a complete value in its own right, `Success` and `Failure` are
-- data constructor functions. So they need to be initialized w/ values to be created
handleResult (Success 200)
```
This is how the `Maybe type` optional type works. It's a union type defined as follows. To unwrap a Just value, you need to use switch case.
```elm
type Maybe a
  = Just a
  | Nothing
```
By not providing a type hint, Elm interprets the value as a generic and allows as wide a usage as possible (based on the type inference it can do, if any). This allows great flexibility for things like the Result type I made above, which is limited by type requirements. (Elm actually has a similarly named type defined in elm/json)

Switch cases in Elm allow for convenient patter matching. It can do the standard single value cases, but also tuples for matching multiple case inputs. But it can't do computation i case statments (like Kotlin can).
```elm
map2 : (a -> b -> value) -> Result x a -> Result x b -> Result x value
map2 func rxa rxb =
  case (rxa, rxb) of
    (Ok a, Ok b) ->
      Ok (func a b)
    ( _, Err x) ->
      Err x
    (Err x, _) ->
      Err x

-- lists let you do some interesting pattern matching + value unpacking on them
-- this impl of reduce showcases unpacking values from a list tail in a case
foldl : (a -> b -> b) -> b -> List a -> b
foldl func accumulator list =
  case list of
    [] ->
      accumulator
    x :: xs -> -- this pattern unpackes `list` as a cons of a value onto a tail. (Elm often refers to elements as x and collection of those elems as xs (plural))
      foldl func (func x accumulator) xs
```
This unpacking ability is available in function parameter lists too. An interesting example is with records (dicts).
```elm
-- this is basically saying the func accepts ANY record that has at least these 2 fields (rather than only those 2)
hello : { record | isLoggedIn: Bool, name: String } -> String
--       hello : { isLoggedIn: Bool, name: String } -> String   -- this would accept only records w/ only those 2 fields
hello { isLoggedIn, name } =    -- record unpacking in func name
  case isLoggedIn of
    True ->
      "Hello " ++ name ++ "!"
    False ->
      "login you shit"
```

Extensible Record is a type that you can use to help narrow types and expose fewer fields
of large records to functions. An extensible record means a record that
just has all the specified and no less (but maybe more).
This allows you to pass in a large record to a function that takes an
extensible record type and only expose the specified fields.
```elm
type alias Extensible r =
  { r
      | name : String
      , age : Int
  }
```


### ---- Standard Lib ----

The `++` operator can be used to concat strings: `"s1" ++ "s2"`.

Regex is a separate package, so you have to install `elm/regex` package to import Regex.

`Maybe` values are Elm optionals, meaning they're either `Nothing` or `Just <value>` and Just has to be unwrapped.

`Debug.toString` will turn arbitrary (or at least standard) types to string for easier debug.

The List type is a linked list. To convert to or create an array from constant list, you need to call `Array.fromList`.
Creating an empty array like `Array.initialize len (always fillerValue)`. The second param of Array.initialize is passed the index at each position to fill the Array, so you can do list comprehension esque things with that if you want probs.
Array uses get and set functions for accessing contained elements (**List does NOT have a way to access positional values!!**). `get` returns Maybe values (so they have to be unwrapped). Note that `set` returns a modified list w/o affecting the original.
```elm
a = Array.fromList [1, 2, 3]
Array.get 2 a -- returns `Just 3`
Array.get 3 a -- returns `Nothing`
Array.set 1 4 -- returns `Array [1, 4, 3]`
```

Tuple, unlike List/Array, can hold values of different data types.

Records (aka maps) similarly have no constraints on the value types that can be mapped to w/in the same structure. Each key value has to be camelCase and not quoted. Record values can be accessed via dot notation (but secretly behind the scenes, elm creates a stand-alone function that could be invoked as `.name someRecord`. This allows for things like `List.map .name listOfRecords`).
You can use `type alias` to create a shortcut type name + constructor for record types you want to use frequently.
```elm
someRecord = { name = "Jim", age = 100, height = 2.3 }
type alias Person = { name : String, age : Int, height : Float }
somePerson = Person "Jim" 100 2.3
```

Every data structure in Elm is immutable, so while you can change the values in a record, it will always return a new record rather than edit the existing one. Also, syntax is real weird:
```elm
{ recordToEdit | fieldName1 = newValue1, fieldName2 = newValue2 } 
-- curly brackets are necessary. Returns a new record 
```

### ---- Import/Export src code ----

An entire module can be imported with `import Module`. This makes it so that functions from the module have be accessed w/ the module name prefixed. To import specific functions from a module, use `import Module exposing (function)`. But it's best practice to import the whole module and call module functions w/ the module prefix anyway: `Module.function`.
Sometimes, for modules that contain a type + related functions, to avoid repeating the module name before type names (since those are often the same), you can import just the type definitions from the module (as long as there are no collisions) with `import Module exposing (Module(..))`. Other functions from the module can still be accessed via dot notation, just the union type case defintions will be imported directly.

To shorten frequently used module names, you can alias an import use `Import Module as ShorterName exposing (..)`.

Elm only looks for exposed functions in modules from the directories specified in the `elm.json` file under `"source-directories"`, so if you add new directories not nested in an already included src dir, be sure to add it to that list to make sure Elm will look for source files there.

Packages contain module(s). Packages are released via a package manager. Using a package in Elm is similar to using local modules; `import Package` and then the module(s) in the package are accessed as `Package.Module.Function`, except where Package and Module are the same, then Elm is nice and lets us only say it once.

### ---- Testing ----

To start using elms test framework, we need to install `elm-test` via npm `npm install elm-test -g`. Then you need to call `elm-test init` in the project you want to add tests in.

There are no special rules for writing tests in Elm (e.g. dont have to start func names with test). Anything exposed by the files in the `test/` directories will be run as a test. If you have helper funcs you dont want run as tests, define as internal scope to a test function, or explicitly define the exposed functions in your test file.

Elm test framework uses `describe` to allow grouping of test functions together.
```elm
testGroup =
  describe "Similar tests"
    [ test "1 < 2" <|
      \_ -> 1 |> Expect.lessThan 2
    , test "2 < 3" <|
      \_ -> 2 |> Expect.lessThan 3
    ]
```
You can nest `describe` calls together as well by putting a describe in the list of another describe.

Elm has built in fuzz (random) testing capability. Using the Test and Fuzz modules in tandem, you can write fuzz tests to feed random values to your functions. You can define your own fuzzers if necessary. Fuzz testing provides a powerful tool for testing, but isnt the same as unit testing, because it tests properties of functions, not specific cases. E.g. testing List.length with a fuzzer you could test the property "length is never negative", but that property test alone cant tell you if the length function is working as expected. So sometimes you need fuzz tests and unit tests in tandem to verify functions fully/better.

