Title: Sync Directory to S3
Date: 2011-08-14 12:23
Category: Python 
Tags: boto, S3, python, script
Slug: sync-directory-to-s3
Authors: Mitch

I needed the ability to sync a directory to S3 for a client... so I wrote up a script I'm calling [sync2S3.py](http://metauser.net/files/sync2S3.py "sync2S3.py").  Some of the code came from the Django extensions project, which I modified to work without django and just sync a directory in an rsync like fashion.  Enjoy
