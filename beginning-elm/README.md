### Super basics of elm the framework and what it do

the `elm-format <file target>` command can be used to format elm files

you can use `elm make <file target>` w/o the `--output` flag and it will create the index.html file for you, but it will lump all your generated js code into the html, which makes testing etc hard. So generally we prefer to invoke make as `elm make <file target> --output elm.js` and import the js into html as usual (see current index.html file). 
```
elm make src/HomePage.elm --output elm.js
```

The `elm reactor` command can be used to run a localhost server to see your elm results in action

the Ellie web app can be used as a in-browser alternative to all this make + reactor stuff

### ---- Syntax thoughts ----

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

To import specific functions from a module, use `import Module exposing (function)`. But it's best practice to call module functions w/ the module prefix: `Module.function`.

Anonymous funcs can be defined as `\param list -> "function body"`. It's common to also need to wrap them in `()` to disambiguate syntax.
```elm
String.filter (\ch -> ch /= '-') "222-44-1345"
-- occasionally, you can use partial functions as a sub for a full anon func;
String.filter ((/=) '-') "222-44-1234" -- use prefix notation for /= operator

List.filter (String.contains "nerd") ["nerd1", "some jock"]
```

`::` is the cons operator! `1 :: [2]` yields `[1,2]`

---- Standard Lib ----

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
