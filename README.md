A quick hack to compare keyword counts in the twitter streaming API. I used cats and dogs in a stunning lack of creativity.

Later on I decided to play with Server-Side Events as a more compatible subset of WebSockets for realtime streaming.  So I suppose this project could serve as a template for someone who wants to see either how to subscribe to and monitor via the Twitter streaming API with redis backing, and/or how to monitor that in realtime via a web UI using SSE or polling.

## Configuration

The app uses heroku-style configuration via environment variables, so the easiest way to do local development is to make sure you have an `.env` file with the needed variables:

  CONSUMER_KEY=aaa
  CONSUMER_SECRET=bbb
  OAUTH_TOKEN=ccc
  OAUTH_TOKEN_SECRET=ddd
  REDISTOGO_URL=redis:/url.here/
  VERBOSE=true

And then run the needed processes via `foreman start`.

## How stuff works

### Tweetstream process

Managed via `petstream.rb`, it subscribes to the Twitter streaming API, and then tracks a count of matching terms in Redis, and keeps a FIFO list of the most recent matching tweets in a constantly truncated redis list.  It also now squirts each matching tweet out over redis `PUBLISH` so that clients can stream from it in realtime.

### Web process
Can you guess where this is? I bet you can. (hint: `web.rb`)

#### Web UI (polling)

Nothing much special here, values are retreived from redis and made available via the `/data` endpoint.  The web UI periodically polls it via AJAX and updates the interface.

#### Web UI (streaming)

As an experiment, this was later refactored to have a SSE endpoint at `/subscribe` which is populated via a secondary redis `SUBSCRIBE` connection on a thread.  You can use JS EventSource binding to then get realtime updates, which after building I actually found to be uglier in terms of UI, but it's an interesting academic exercise which could have good applications somewhere else.
