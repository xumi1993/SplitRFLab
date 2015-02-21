processRFmatlab
===============

MATLAB functions and scripts for working with receiver functions

These are functions I wrote during my post doc at USC (2009-2011) to
work with receiver function data.  It is not any formal program, but
the codes are made available in case they might be useful for learning
about receiver functions or reproducing some results.

There are three main aims while writing

(1) try and use as much of matlab's functionality as possible (e.g.,
signal processing libraries)

(2) try to allow independence of functions with few dependencies on
other functions or specific data structures

(3) Keep the input and output consistent with SAC file data structure
since this is fairly standard

I'm not working in this research area now, so I don't expect to use or
modify these codes much.  Still I would like to maintain them if they
are useful so I'm happy to hear if you have any
comments/questions/contributions.  iainbailey@gmail.com


How to get the codes:
---------------------

If you want to keep up to date ...

1 - Learn about Git and how to use it on your operating system.

2 - Download the Git repository for this code from github to a
    directory on your computer.

3 - If there turn out to be mistakes or changes, I will make changes
    and upload them to Git, you can then update your local copy.  If
    you want to have access to make changes yourself, let me know.

Otherwise just get the zip file above.

How to use:
-----------

The functions are in separate directories based on their general class
of function.  You will need them in your path to use them. Modify the
script processRFmatlab_startup.m then run it before using the
functions or change your own startup.m file if you want to do this
automatically.


