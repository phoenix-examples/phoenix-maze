# Experimenting with Elixir and Phoenix

/maze is a maze that would allow one or more people to play at the same time (not really useful in practice but a fun project)

/rawkets is trying to port Rawkets (https://github.com/robhawkes/rawkets) to Elixir and Phoenix. Rawkets is like Asteroids except there are other players instead of...well, asteriods. FYI - no Twitter login necessary like in original Rawkets

Demo site at http://canarymod16.cloudapp.net (/rawkets or /maze) but I don't always have it running since I think it'll burn throw my spending limit. 

To start your Phoenix application:

1. Install dependencies with `mix deps.get`

2. Start Phoenix endpoint with `mix phoenix.server`

3. Probably going to be alerted to run `npm install` to use brunch.io

4. If you get here you should stop server and run `mix Install` (this will setup Mnesia ('database')) otherwise multiple players won't work 

Now you can visit `localhost:4000`, 'localhost:4000\maze', `localhost:4000\rawkets` from your browser.
