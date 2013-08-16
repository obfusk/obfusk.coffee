[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2013-08-15

    Copyright   : Copyright (C) 2013  Felix C. Stegerman
    Version     : v0.0.1-SNAPSHOT

[]: }}}1

## Description
[]: {{{1

  obfusk.coffee - functional programming library for js/coffee

  ...

[]: }}}1

## Examples
[]: {{{1

[]: {{{2

```coffee
O = require 'obfusk'

O.match O.Just(42),
  Nothing: -> console.log 'Nothing to see here ...'
  Just: (x) -> console.log "The answer is: #{x.value}"

# ...
```

[]: }}}2

[]: }}}1

## Specs & Docs
[]: {{{1

    $ rake spec
    $ rake docs

[]: }}}1

## TODO
[]: {{{1

  * build!
  * examples!
  * more specs/docs?
  * ...

[]: }}}1

## License
[]: {{{1

  GPLv2 [1] or EPLv1 [2].

[]: }}}1

## References
[]: {{{1

  [1] GNU General Public License, version 2
  --- http://www.opensource.org/licenses/GPL-2.0

  [2] Eclipse Public License, version 1
  --- http://www.opensource.org/licenses/EPL-1.0

[]: }}}1

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
