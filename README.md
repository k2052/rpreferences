# Details  

A preferences controller for Macruby based off of [DBPrefsWindowController](http://www.mere-mortal-software.com/blog/details.php?d=2007-03-11) by [Dave Batton](http://www.mere-mortal-software.com/blog/about.php)

# Installation

Git clone into lib and `require 'lib/rpreferences/rpreferences'`. Sorry, no macgem at the moment; I'll do that eventually.  

# Usage

Create your views in a Preferences.nib and then extend `RPreferencesWindowController` and implement the setupToolBar method

```ruby 
class PreferencesWinController < RPreferencesWindowController       
  attr_accessor :view1, view2
	
  def setupToolbar()     
  	self.addView(@view1, label:"General")   
  	self.addView(@view2, label:"Bob")
  end
end
```

# Examples

- Demo Preferences App: [https://github.com/bookworm/rpreferences_demo_app](https://github.com/bookworm/rpreferences_demo_app)