# HTQ

HTQ is a simple tool for extracting elements from html streams using CSS3 selectors and/or XPath queries. It uses the incomarable (lexborisov/myhtml)[https://github.com/lexborisov/myhtml] wrapper (kostya/myhtml)[https://github.com/kostya/myhtml].

## Building

```shell
shards install
shards build --release
```

## Usage

```
usage: htq [css_query] [options] [file ...]
    -c QUERY, --css=QUERY            Specify a css selector
    -x XPATH, --xpath=XPATH          Specify an XPATH selector
    -a ATTR, --attr=ATTR             Extract an attribute value
    -p, --pretty                     Pretty print output
    -t, --text                       Print text content
    -0, --print0                     Separate output by NULL
    -l, --list-files                 List matching files without matches
    -h, --help                       Print help message
```

## Examples

```
$ echo "<div><p>Lorem Ipsum</p></div>" | bin/htq p
<p>Lorem Ipsum</p>
$ echo "<div><p>Lorem Ipsum</p></div>" | bin/htq p -p
<p>
  Lorem Ipsum
</p>
$ echo "<div><p>Lorem Ipsum</p></div>" | bin/htq -x //p -t
Lorem Ipsum
```
