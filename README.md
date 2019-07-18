# HTQ

HTQ is a simple tool for extracting elements from html streams using CSS3 selectors. It uses the incomarable (lexborisov/myhtml)[https://github.com/lexborisov/myhtml] wrapper (kostya/myhtml)[https://github.com/kostya/myhtml].

## Building

```shell
shards install
shards build --release
```

## Usage

```
usage: htq [files] [options]
    -c QUERY, --css=QUERY            Specify a css query
    -p, --pretty                     Pretty print output
    -t, --text                       Print text content
    -a ATTR, --attr=ATTR             Extract an attribute value
    -h, --help                       Print help message
```

## Examples

```
$ echo "<div><p>Lorem Ipsum</p></div>" | bin/htq -c p
<p>Lorem Ipsum</p>
$ echo "<div><p>Lorem Ipsum</p></div>" | bin/htq -p -c p
<p>
  Lorem Ipsum
</p>
```
