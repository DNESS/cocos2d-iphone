**DEPRECATED**
**DEPRECATED**

Use this page instead:
http://www.cocos2d-iphone.org/wiki/doku.php/faq


#summary Frequently Asked Questions


## Can I use _cocos2d for iPhone_ in my closed-source iPhone application ? ##

Yes, you can.

_cocos2d for iPhone_ is licensed under the 'cocos2d for iPhone license'. Basically it is like a LGPL license but allows you to use the library as a static library or by including the _cocos2d for iPhone_ sources in your project.

Remember that _cocos2d for iPhone_ follows the copyleft idea. So if you improve the library, send me the patches or make them public so that I can include them in future releases.

If you have any doubt, please read the 'cocos2d for iPhone license':
http://cocos2d-iphone.googlecode.com/svn/trunk/LICENSE


## Can I use 3D objects in cocos2d ? ##

You can include some 3D objects in your 2d game to improve the quality of your graphics without any problem.

Also, the default projection matrix of cocos2d is a 3D one, so probably you won't need to change it.


## I've found a bug / I have an enhancement proposal. What should I do ? ##

Please, open a ticket in the issue tracker: http://code.google.com/p/cocos2d-iphone/issues/list .

You can also mention the bug/enhancement in the discussion list, but please, don't forget to open a ticket in the issue tracker.


## How do I submit a patch ? ##
If you want to contribute with code, please, send me patches using
these steps:
  1. Download the latest sources from the svn:
> > `svn checkout http://cocos2d-iphone.googlecode.com/svn/trunk/ cocos2d-iphone-read-only`

  1. apply your changes in the recently downloaded repository
  1. go to the repository. eg:
> > `cd ~/src/cocos2d-iphone-read-only`
  1. generate the patch. eg:
> > `svn diff > patch.diff`
  1. open a ticket in the issue tracker, and put the patch there
  1. Don't forget to describe what the patch does.


## I don't know how to do XXX in cocos2d. Can I send you an email ? ##

Please, no. Don´t send me an email asking for help.

The project has a special place to ask any kind of question: The cocos2d discussion list

> http://groups.google.com/group/cocos2d-iphone-discuss