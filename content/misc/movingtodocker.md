Title: Moving to Docker
Date: 2016-01-01 18:01
Tags: docker, webhost, automation, tutum
Category: Misc
Slug: moving-to-docker
Author: Mitch

Its been a long time since I've written about anything.  I've had a lot of thoughts and things I've wanted to do. Just finding the time to write them up has been a challenge.  I did get a new job 6 months ago, with the title "Sr. DevOps Engineer", which if you follow "DevOps" as a practice it leads you to think wonder.  Anyway lets just describe my role uses the literal usage of it.  I work directly with the development teams providing them Operations support.  Or in other words "Developer Operations".  Our SaaS offering is hosted entirely in AWS (some via Heroku).  I've been leaning on my background with Ansible to continue managing the infrastructure, and even started down a few new paths with it.  More with be forth coming on those fronts, promise.

![Blog Workflow]({filename}/images/blog-workflow.png)

Purpose of this post, is a high level overview of deploying this blog from laptop to server, using Docker.  There are a few steps along the way as its all proper "devops" like stuff.  Because it is automated.  This blog is still done with  [http://blog.getpelican.com/](Pelican), which is a Python Static Site generator.  I write the blog posts on my laptop, which is a 15" MBP, and run its local test server to make sure things are turning up right.  The entire code base of the blog is checked into git and pushed to [https://github.com](GitHub), which is public on my github page at [https://github.com/undeadops/blog](github.com/undeadops/blog).  

From there, you will notice my Dockerfile that is used to build the docker image.

Which implements a webhook on commit to the master branch to [https://hub.docker.com/r/undeadops/blog](Docker Hub).  Docker Hub will auto-build this into a Docker Image that is public.

After a successful build of the Docker image, another webhook is called notifying [https://tutum.com](Tutum) about the updated image.  From there, I have a Tutum Node agent running on my newly spun up Digital Ocean Ubuntu 14.04 Server and Docker 1.9.1.  This agent is then notified of the new image, which will result in it calling a docker pull to fetch the latest image from Docker Hub.  Once downloaded, the agent executes a restart of the container using the options I've specified via the Tutum website.  

Pretty cool eh?  There could be and probably should be in most circumstances, a build/test server such as Jenkins, Circle-Ci, or Travis-Ci, that could easily have two places in that work flow.  Right after your git commit, to validate the code, make sure nothing glaringly is wrong with it, and able to proceed to have validation tests run against it.  Where that step could wait until after its had a Docker Image created from it so the tests are run against a container of the code.  If you noticed, there are quite literally dozens of ways to handle the whole process I just described.  Depending on the size of your environment and employee skill sets and how much of the "plumbing" you want your employees handling will guide you towards what solutions are the best fit for your organization.  Thats all for now.  I'll commit this and kick start the process I've described thats allowed you to read this.   
