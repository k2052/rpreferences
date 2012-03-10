class RPreferencesWindowController < NSWindowController   
  attr_accessor :showWindow
  
  @@sharedPrefsWindowController = nil
  
  def self.create(window=nil)           
  	
  	unless @@sharedPrefsWindowController      
  	  if window   
  	    @@sharedPrefsWindowController = self.alloc.initWithWindow(window)  
	    else
    		@@sharedPrefsWindowController = self.alloc.initWithWindowNibName(self.nibName)  
  		end
		end

  	return @@sharedPrefsWindowController
  end        
  
  def self.nibName()
    return "Preferences"
  end  
  
  def initWithWindow(window)
  	super(nil)          	
	  @toolbarIdentifiers = NSMutableArray.alloc.init
  	@toolbarViews       = NSMutableDictionary.alloc.init
  	@toolbarItems       = NSMutableDictionary.alloc.init

  	@crossFade = false
    @shiftSlowsAnimation = false

  	@contentSubview = nil  
  	
  	@viewAnimation  = NSViewAnimation.alloc.init()  
		@viewAnimation = NSViewAnimation.alloc.init()
		@viewAnimation.setAnimationBlockingMode(NSAnimationNonblocking)
		@viewAnimation.setAnimationCurve(NSAnimationEaseInOut)
		@viewAnimation.setDelegate(self)

		self.setCrossFade(true) 
		self.setShiftSlowsAnimation(true)   
		     	
  	return self
	end   
	
	def windowDidLoad   
	  window = NSWindow.alloc.initWithContentRect(NSMakeRect(0,0,1000,1000), 
  												    styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask),
  													  backing:NSBackingStoreBuffered,
  													    defer:true)
    self.setWindow(window)
  	@contentSubview = NSView.alloc.initWithFrame(self.window.contentView.frame())
  	@contentSubview.setAutoresizingMask(NSViewMinYMargin | NSViewWidthSizable)
  	self.window.contentView.addSubview(@contentSubview)
  	self.window.setShowsToolbarButton(false)
  end  
  
  def setupToolbar()     
  	# Subclasses must override this method to add items to the
  	# toolbar by calling -addView:label: or -addView:label:image:.
  end
  
  def dealloc     
    @toolbarIdentifiers.release
  	@toolbarViews.release
  	@toolbarItems.release
  	@viewAnimation.release()
    super.dealloc()
	end 
	
	def addView(view, label:label)
	  self.addView(view, label:label, image:NSImage.imageNamed(label))
	end

  def addView(view, label:label, image:image)   
  	identifier = label.copy()

  	@toolbarIdentifiers.addObject(identifier)
  	@toolbarViews.setObject(view, forKey:identifier)

  	item = NSToolbarItem.alloc.initWithItemIdentifier(identifier)
  	item.setLabel(label)
  	item.setImage(image)
  	item.setTarget(self)
  	item.setAction('toggleActivePreferenceView:')

  	@toolbarItems.setObject(item, forKey:identifier)
	end    
	
	def setCrossFade(fade)
	  @crossFade = fade
  end
  
  def setShiftSlowsAnimation(slows)
    @shiftSlowsAnimation = slows
  end     
  
  def showWindow(sender)
  	self.window()

  	@toolbarIdentifiers.removeAllObjects()
  	@toolbarViews.removeAllObjects()
  	@toolbarItems.removeAllObjects()         
  	self.setupToolbar()

  	if self.window().toolbar() == nil
  		toolbar = NSToolbar.alloc.initWithIdentifier("RPreferencesToolbar")
  		toolbar.setAllowsUserCustomization(false)
  		toolbar.setAutosavesConfiguration(false)
  		toolbar.setSizeMode(NSToolbarSizeModeDefault)
  		toolbar.setDisplayMode(NSToolbarDisplayModeIconAndLabel)
  		toolbar.setDelegate(self)
  		self.window.setToolbar(toolbar)
    end
           
  	firstIdentifier = @toolbarIdentifiers.objectAtIndex(0)
  	self.window().toolbar.setSelectedItemIdentifier(firstIdentifier)
  	self.displayViewForIdentifier(firstIdentifier, animate:false)

  	self.window().center()

  	super(sender)
	end     
	
	def toolbarDefaultItemIdentifiers(toolbar)
  	return @toolbarIdentifiers
	end
  	
  def toolbarAllowedItemIdentifiers(toolbar) 
  	return @toolbarIdentifiers
	end

  def toolbarSelectableItemIdentifiers(toolbar)
  	return @toolbarIdentifiers
	end

  def toolbar(toolbar, itemForItemIdentifier:identifier, willBeInsertedIntoToolbar:willBeInserted)
  	return @toolbarItems.objectForKey(identifier)
	end          
	
	def toggleActivePreferenceView(toolbarItem)
  	self.displayViewForIdentifier(toolbarItem.itemIdentifier(), animate:true)
  end                           
  
  def displayViewForIdentifier(identifier, animate:animate) 
  	newView = @toolbarViews.objectForKey(identifier)     
  	oldView = nil  

  	if @contentSubview.subviews().count > 0     	  
  	  subviewsEnum = @contentSubview.subviews.reverseObjectEnumerator()
  		oldView = subviewsEnum.nextObject()

  		reallyOldView = nil
  		while reallyOldView = subviewsEnum.nextObject() != nil
  			reallyOldView.removeFromSuperviewWithoutNeedingDisplay()
			end
    end      
    
  	if !newView.isEqualTo(oldView)	
  		frame = newView.bounds
  		frame.origin.y = NSHeight(@contentSubview.frame()) - NSHeight(newView.bounds())
  		newView.setFrame(frame)
  		@contentSubview.addSubview(newView)
  		self.window.setInitialFirstResponder(newView)
         
  		if animate && @crossFade && oldView != nil 
  			self.crossFadeView(oldView, withView:newView)
  		else    
  		  if oldView != nil  
    			oldView.removeFromSuperviewWithoutNeedingDisplay()
  			end       
  			newView.setHidden(false)       
  			self.window().setFrame(self.frameForView(newView), display:true, animate:animate)
  		end    

  		self.window().setTitle(@toolbarItems.objectForKey(identifier).label())
		end    
	end 
	
	def crossFadeView(oldView, withView:newView)
  	@viewAnimation.stopAnimation()

    if self.shiftSlowsAnimation() && self.window().currentEvent.modifierFlags & NSShiftKeyMask
  		@viewAnimation.setDuration(1.25)
    else
  		@viewAnimation.setDuration(0.25)
		end   

  	fadeOutDictionary = NSDictionary.dictionaryWithObjectsAndKeys(oldView, NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, 
    	NSViewAnimationEffectKey, nil)

  	fadeInDictionary = NSDictionary.dictionaryWithObjectsAndKeys(newView, NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, 
    	NSViewAnimationEffectKey, nil)

    resizeDictionary = NSDictionary.dictionaryWithObjectsAndKeys(self.window(), NSViewAnimationTargetKey, NSValue.valueWithRect(self.window.frame), 
      NSViewAnimationStartFrameKey, NSValue.valueWithRect(self.frameForView(newView)), NSViewAnimationEndFrameKey,
      nil)  
    
    animationArray = NSArray.arrayWithObjects(fadeOutDictionary, fadeInDictionary, resizeDictionary, nil)
    
    @viewAnimation.setViewAnimations(animationArray)
    @viewAnimation.startAnimation()
  end  
  
  def animationDidEnd(animation)
  	subview = nil

    subviewsEnum = @contentSubview.subviews.reverseObjectEnumerator()
  	subview = subviewsEnum.nextObject()

  	while subview = subviewsEnum.nextObject() != nil
  		subview.removeFromSuperviewWithoutNeedingDisplay()
  	end

  	self.window.makeFirstResponder(nil)
	end   
	
  def frameForView(view)
  	windowFrame = self.window.frame()
  	contentRect = self.window.contentRectForFrameRect(windowFrame)
  	windowTitleAndToolbarHeight = NSHeight(windowFrame) - NSHeight(contentRect)

  	windowFrame.size.height = NSHeight(view.frame) + windowTitleAndToolbarHeight
  	windowFrame.size.width  = NSWidth(view.frame)
  	windowFrame.origin.y    = NSMaxY(self.window.frame) - NSHeight(windowFrame)

  	return windowFrame
	end
end