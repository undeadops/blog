Title: Basic Math
Date: 2016-02-02 12:54:00
Category: Misc
Tags: python,basic math
Slug: basic-math
Authors: Mitch

### Python Basic Math

###### Updated below (Feb 13th 2016)

###### Originally Written on June 24th 2015

I had been interviewing lately... (its more official now which is why I'm writing about it) I did a bunch of interviews, some wanting to test my python prowess, and well they stumped me.  On basic math with python... yeah I was extremely frustrated by the experience as I've been doing python for years... never had many on the spot, do some basic math now kind of moments.  None the less, it irritated me.  So, I went home and revisited the question.  Not 5 minutes later I had the answer,
but it bugged me the whole drive home.  Which is something I do a lot, something bugs me regardless of how small and meaningless (like needing to do basic math in python), I'm posting here for posterity.  Question is not word for word what I got, because I didn't copy it, but heres the basics of it:

Write a script that will check numbers 1 through 100, to see if they are divisible by 4, if they are print "word".  If they are divisible by 6, print "anotherword", if they are divisible by both, print "both".  Otherwise print the number.

    :::python
    for x in range(1,101):
        is4 = False
        is6 = False
        if float(x/4.0).is_integer():
            print str(x) + "/4 = " + str(float(x/4.0))
            is4 = True
        if float(x/6.0).is_integer():
            print str(x) + "/6 = " + str(float(x/6.0))
            is6 = True
        if is6 is True and is4 is True:
            print str(x) + " is Divisible by both!"
        elif is6 is False and is4 is False:
            print x

Basing someones skill set off something, yes while simple, that is completely unrelated to the job, is pointless.  I didn't learn python while getting a BS in CompSci from <insert college here>, I've learned it on the job.  When not required of me to even learn it.  I've learned it because I wanted to, because I thought it was interesting.  Does that mean I may be missing something simple.  Sure, and obviously in this case, but does that also mean I'm unable to pick up on and learn/work on your super complex provisioning/automated deployment/whatever you have?  Thats how I learned python.

#### UPDATE

Because development was never part of my main job previously, and I don't have any good friends that are developers full time, so everything I do know is because its what I've been able to learn on my own, and mostly in my spare time(Family life to boot).  I came across a previously unknown operator that would make solving the above problem MUCH simpler, so to show off what I've learned, here it is:

    ::::python
    for x in range(1,101):
        if x % 4 == 0 and v %6 == 0:
            print "both"
        elif x % 4 == 0:
            print "word"
        elif x % 6 == 0:
            print "anotherword"
        else:
            print x

The solution utilizes the Python Modulus Operator, something I'd never heard of, or used before(Yeah, I don't have the full standard lib memorized, like I said... NOT a dev, but I'm working on it), but it does make for a distinctly more concise representation of whatever I was thinking of before.  #NeverStopLearning
