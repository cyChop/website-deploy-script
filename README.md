# Website deployment script

[![Licensed under GPL v3](https://www.gnu.org/graphics/gplv3-88x31.png)](https://www.gnu.org/licenses/gpl-3.0.en.html)

## What it does

* Copy your website to the directory of your choice
* Removes any .git information to avoid publication of sensitive information on your website
* Applies some basic minification to make your website more efficient and hide information (comments)

## Better tools

They are many. This is essentially a utility for basic mostly static websites. Some examples:

* JavaScript website: many Grunt or Gulp plugin perform a much better minification according to your requirements and your RCS repository should not be included in your final version.
* Java JAR: some Maven plugins allow for minification too and, unless badly configured, no RCS information should be included in your binary.

