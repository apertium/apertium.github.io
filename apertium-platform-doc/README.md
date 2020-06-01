To build documentation, run `make docs` while in this `docs-source` directory.

For that to work, you'll need [Racket](https://racket-lang.org/) installed.

To view the generated documentation, run an http server of your choice in the
main directory of the repo, i.e. in `../docs-source. If you have Python3
installed, you can do:

```
python3 -m http.server
```

And then open localhost:8000 in your browser.

If you want to use a Racket-based web server, you can install a package called
`pollen` with:

```
raco pkg install pollen
```

and then run

```
raco pollen start
```

and then open localhost:8080 in your browser.
