# Developers #

Guidelines regarding how to add new features / fix bugs

# Details #

If you want to fix a bug, or you want to add a new feature, take into account the following guidelines.
The general purpose of these guidelines is to make the project easier to maintain and extend.

## New features ##
New features requires:
  * A test (or several sub-tests) that tests the functionality
  * New classes/methods must have doxygen strings (documentation)
  * .m files should follow the objective-c name convention
  * indentation: use XCode default indentation
  * Run the [llvm static analyzer](http://clang.llvm.org/StaticAnalysis.html) on your code, an fix the possible bugs. If llvm reports a false-positive (eg: memory leak that it isn't) consider documenting it in the code. (eg: `// the object is released on the callback`)

## Refactoring ##
Refactoring key components:
  * avoid it during point releases

## Bug Fixes ##
Bug fixes:
  * Compatibility should not be broken during point releases
  * Before introducing any change that might break compatibility in a major release, it must be discussed first

## Commits ##
Commits:
  * every commit must be associated with an issue
  * when commiting something, add in the comment something like this:
> > `fixing issue #123`
  * and the issue should have a comment like this:
> > `fixed in r829`
  * Add a brief line to the [CHANGELOG file](http://code.google.com/p/cocos2d-iphone/source/browse/trunk/CHANGELOG) documenting your change.

## Discussion ##
Discussion list:
  * For the moment lets discuss devel topics on the [cocos2d-iphone-discuss](http://groups.google.com/group/cocos2d-iphone-discuss) adding the `[devel]` prefix to the subject.
  * If there is a lot of noise on that list, we can create another list.