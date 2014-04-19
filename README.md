# eventkalender

Small sinatra web application to serve feeds for [c3voc](http://c3voc.de) [events](https://c3voc.de/wiki/events).

Supported feed formats:

  * ical → /events.ical
  * atom → /events.atom
  * json → /events.json
  * txt  → /events.txt

To filter for past or upcoming events, following keywords (e.g. `/events.txt?filter=past`) can be used:

  * past
  * upcoming
  * today
  * year (e.g. 2013)
  * all (default)

Eventkalender is tested against Ruby `1.9.3`, `2.0.0` and `2.1.1`. [![Build Status](https://travis-ci.org/voc/eventkalender.svg?branch=master)](https://travis-ci.org/voc/eventkalender)

## Install

Clone repository.

```
 git clone https://github.com/voc/eventkalender;
 cd eventkalender
```

Install dependencies.

```
 bundle install
```

Test installation and run application with puma.

```
 ruby webapp.rb
```

## Deployment

It is highly recommended to deploy this application with passenger or comparable webservers.

## License

Copyright (c) 2014, c3voc<br>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.