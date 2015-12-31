Title: Better Monitoring options
Date: 2014-05-01 08:34
Category: Monitoring
Tags: monitoring, graphite, nagios
Slug: no-fan-monitoring
Authors: Mitch

Proper monitoring and trending have been a sore spot for me for a few years now, I've never really liked any of the solutions I could find.  I know Zenoss keeps tying to sell me on their solution, but its a glorified and more confusing nagios+nagios graphing.  Zenoss... Call a server a system/host and services that need monitoring a service... don't invent terminology its made me hate it from day one(And I truely wanted to like it at one time).  Sadly because of what has been a constant flux at work, I haven't really had the motivation to look into it that much more.  I was also fairly convinced that I would need to write custom solution for my monitoring woes.  So, I've left it on the back burner for way too long.

Recently, I've became reinvigorated to work on "monitoring" again, mostly because I've really needed a change in pace/scenery from what I've been doing.  Since I'm wanting the ability to graph everything and monitor based on what I will be graphing (why poll the data twice right?), I also want things to work "at cloud scale".  I very much dislike the idea of having to go to a central server to configure monitoring/trending.  I've rather liked using tools like [munin]('http://munin-monitoring.org/'), as far as the client side.  It still requires a modest amount of work to configure the munin poller to connect and pull info from the munin-node, but what is graphed is all configured client side.  ALMOST what I'd want.

What I wanted is the ability to have any server I spin up have my [configuration management]('http://www.saltstack.com') configure what needs to be monitored as part of configuring the server and then be done.  Alerting thresholds should have defaults, but customizable per host/group/resource type... and typically after seeing trending data from the host anyway.  Alerts could then be issued based on big picture ideas of multiple datapoints not just CPU is maxed... Maybe I don't care if the CPU is maxed if the website is still performing in acceptible norms?  That type of stuff.

So, what I want my monitoring to do is just accept data sent to it and graph it.  And, I something that I've come around to in this arena is [Graphite]('http://graphite.wikidot.com/').  It tackles my cloud scale trending problem exactly, since it does not require any configuration server side in order to receive data to graph.  Throw in a project such as [seyren]('https://github.com/scobal/seyren') and I have some alerting ability based off my Graphite data.  Granted my use case will still require some custom development work to make this all work the way I require.  But this stuff will get me started and I didn't have to develop it all from scratch!  Which is a major bonus.  I love Open Source.  More will follow for how I get this setup.

