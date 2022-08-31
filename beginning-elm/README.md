the `elm-format <file target>` command can be used to format elm files

you can use `elm make <file target>` w/o the `--output` flag and it will create the index.html file for you, but it will lump all your generated js code into the html, which makes testing etc hard. So generally we prefer to invoke make as `elm make <file target> --output elm.js` and import the js into html as usual (see current index.html file). 

The `elm reactor` command can be used to run a localhost server to see your elm results in action

the Ellie web app can be used as a in-browser alternative to all this make + reactor stuff
