Title: Basic Math
Date: 2015-06-24 07:27:00 
Category: Misc
Tags: python,basic math
Slug: basic-math
Authors: Mitch

### Python Basic Math
I had been interviewing lately... (its more official now which is why I'm writting about it) I did a bunch of interviews, some wanting to test my python prowess, and well they stumped me.  On basic math with python... yeah I was extremely frustred by the experince as I've been doing python for years... never had many on the spot, do some basic math now kind of moments.  None the less, it irritated me.  So, I went home and revisited the question.  Not 5 minutes later I had the answer,
but it bugged me the whole drive home.  Which is something I do alot, something bugs me reguardless of how small and meaningless (like needing to do basic math in python), I'm posting here for posterity.  Question is not word for word what I got, because I didn't copy it, but heres the basics of it:

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

