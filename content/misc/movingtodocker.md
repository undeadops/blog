Title: Moving to Docker
Date: 2016-01-01 18:01
Tags: docker, webhost, automation, tutum
Category: Misc
Slug: moving-to-docker
Author: Mitch

Its been a long time since I've written about anything.  I've had a lot of thoughts and things I've wanted to do. Just finding the time to write them up has been a challenge.  I did get a new job 6 months ago, with the title "Sr. DevOps Engineer", which if you follow "DevOps" as a practice, I know, I didn't pick it.  Anyway, lets instead just describe my role as being a literal definition.  I work directly with the development teams providing operations support.  Or in other words "Developer Operations" or titles such as SRE (Site Reliability Engineer) all would apply.  Our SaaS offering is hosted entirely in AWS (some via Heroku).  Since I started, I've been leaning on my background with [Ansible](http://www.ansible.com/) to continue managing the infrastructure, and even started down a few new paths with it like Infrastructure as Code.  More will be coming on those fronts, promise.

![Blog Workflow]({filename}/images/blog-workflow.png)

Purpose of this post, is a high level overview of deploying this blog from my laptop to the live droplet, all completely through automation using [Docker](http://docker.com).  There are a few steps along the way as you can see in the image, but its all proper "devops" stuff.  This blog is still written with [Pelican](http://blog.getpelican.com/), which is a Python Static Site generator.  I write each blog posts on my laptop, a 15" MBP, and run its local python test server to make sure things are rendering correctly.  The entire code base of the blog is checked into git and pushed to [GitHub](https://github.com), which is a public repository on my github page at [github.com/undeadops/blog](https://github.com/undeadops/blog).  

From there, you will notice my [Dockerfile](https://github.com/undeadops/blog/blob/master/Dockerfile) that is used to build the docker image.  I'm using [Docker Hub](https://hub.docker.com/r/undeadops/blog) to automatically build and store this image on my public docker registry.

After a successful build of the Docker image, another webhook is called notifying [Tutum](https://www.tutum.co/) about the updated image.  The Tutum agent is running on my newly spun up [Digital Ocean](https://www.digitalocean.com/) Ubuntu 14.04 droplet and Docker 1.9.1.  This agent is notified of the new image, which results in a docker pull to fetch the latest image from Docker Hub.  Once downloaded, the agent executes a restart of the container using the options I've specified via the Tutum dashboard.

Pretty cool eh?  One thing missing is a build/test server such as Jenkins, Circle-Ci, or Travis-Ci.  A build server could be used as a gatekeeper in a number of places in this workflow, and even replace the DockerHub build step entirely.  Were this actual code vs, raw html files, I would have put a build server right after the git commit, to validate the code(and I may eventually do something to validate the HTML).  If the code requires a "build" step itself, that would be run at this point.  Also, If you noticed, there are quite literally dozens of ways to handle this whole process I just described.  Depending on the size of your environment, and employee skill sets and preferences, and how much of the "plumbing" you want your employees handling, will guide you towards what solutions are the best fit for your organization.  Thats all for now.  I'll commit this and kick start the process I've described thats allowed you to read about it.   
