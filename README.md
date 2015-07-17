# paraply2

Remake of the old Paraply.

Paraply is a super simple event aggregator which can fetch events from Facebook, Meetup and Eventbrite and save/display events in a standardised format

## Install & run
You need Node.js and Elastic Search installed.

1) ```npm install -g coffee-script forever && npm install```

2) ```forever -c coffee index.coffee```

Paraply 2 should now run on http://localhost:8888