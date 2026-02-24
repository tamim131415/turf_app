# TurfMate Project - Animation Widgets Documentation

## Overview
This document covers all animation-related widgets and controllers used in the TurfMate project. Animations enhance user experience by providing visual feedback and smooth transitions.

---

## 1. AnimationController

### Purpose
`AnimationController` manages the lifecycle and timing of animations.

### Usage in TurfMate
- **Splash Screen**: Logo animation on app startup
- **Loading Indicators**: Custom loading animations
- **Transition Effects**: Screen entry/exit animations
- **Interactive Animations**: User-triggered effects

### Key Features Used
```dart
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this, // SingleTickerProviderStateMixin required
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward(); // Start animation
    
    // Listen to animation status
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        navigateToHome();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Logo(),
    );
  }
}
```

### Why Used
- **Control**: Start, stop, reverse animations
- **Timing**: Control animation duration
- **Status**: Know when animation completes
- **Performance**: Efficient animation management

### Examples in Project
- `lib/screens/splash/splash_screen.dart` - Splash animation
```dart
_controller = AnimationController(
  duration: Duration(seconds: 2),
  vsync: this,
);
_animation = CurvedAnimation(
  parent: _controller, 
  curve: Curves.easeInOut,
);
_controller.forward();
```

---

## 2. SingleTickerProviderStateMixin

### Purpose
Provides a `Ticker` for `AnimationController`, optimized for single animations.

### Usage in TurfMate
- **One Animation**: Screens with single animation controller
- **Performance**: More efficient than TickerProviderStateMixin
- **Splash Screen**: Logo fade-in animation

### Key Features Used
```dart
class _MyAnimatedWidgetState extends State<MyAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // 'this' provides the ticker
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Why Used
- **Required**: AnimationController needs vsync
- **Frame Sync**: Animations run at 60fps
- **Performance**: Pauses when widget not visible
- **Efficiency**: Single ticker for single animation

### Examples in Project
- `lib/screens/splash/splash_screen.dart`
```dart
class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller uses this
}
```

---

## 3. CurvedAnimation

### Purpose
`CurvedAnimation` applies easing curves to animations for natural motion.

### Usage in TurfMate
- **Smooth Animations**: Natural acceleration/deceleration
- **Bounce Effects**: Spring-like animations
- **Ease In/Out**: Gradual start and end
- **Custom Curves**: Tailored animation feels

### Key Features Used
```dart
// Simple curve
final animation = CurvedAnimation(
  parent: _controller,
  curve: Curves.easeInOut,
);

// Different curves for forward/reverse
final animation = CurvedAnimation(
  parent: _controller,
  curve: Curves.easeIn,
  reverseCurve: Curves.easeOut,
);

// Common curves in Flutter:
Curves.linear          // No easing
Curves.easeIn          // Slow start
Curves.easeOut         // Slow end
Curves.easeInOut       // Slow start and end
Curves.bounceIn        // Bounce start
Curves.bounceOut       // Bounce end
Curves.elasticIn       // Elastic start
Curves.elasticOut      // Elastic end
Curves.fastOutSlowIn   // Material Design standard
```

### Why Used
- **Natural Motion**: Mimics real-world physics
- **Professional**: Feels polished
- **User Experience**: Smooth, pleasant animations
- **Material Design**: Google's recommended curves

### Examples in Project
- `lib/screens/splash/splash_screen.dart`
```dart
_animation = CurvedAnimation(
  parent: _controller,
  curve: Curves.easeInOut,
);
```

---

## 4. FadeTransition Widget

### Purpose
`FadeTransition` animates the opacity of a widget.

### Usage in TurfMate
- **Splash Screen**: Logo fade-in
- **Modal Overlays**: Dialog fade in/out
- **Content Loading**: Fade in loaded content
- **Indicator Transitions**: Smooth show/hide

### Key Features Used
```dart
FadeTransition(
  opacity: _animation,
  child: Container(
    child: Text('Fade in/out'),
  ),
)

// With custom opacity range
FadeTransition(
  opacity: _animation.drive(
    Tween<double>(begin: 0.0, end: 1.0),
  ),
  child: Widget(),
)
```

### Why Used
- **Performance**: Efficient opacity animation
- **Common Effect**: Frequently needed
- **Smooth**: Better than setState opacity
- **Professional**: Polished appearance

### Examples in Project
- Splash screen logo animation
- Dialog fade effects
- Loading state transitions

---

## 5. SlideTransition Widget

### Purpose
`SlideTransition` animates the position of a widget with smooth sliding.

### Usage in TurfMate
- **Screen Transitions**: Slide in new screens
- **Drawer**: Menu slide in/out
- **Bottom Sheets**: Slide up from bottom
- **Panels**: Sliding side panels

### Key Features Used
```dart
SlideTransition(
  position: Tween<Offset>(
    begin: Offset(1.0, 0.0), // Start off-screen right
    end: Offset.zero,         // End at normal position
  ).animate(_controller),
  child: Container(
    child: Text('Sliding content'),
  ),
)

// Slide from different directions:
Offset(0.0, 1.0)  // From bottom
Offset(0.0, -1.0) // From top
Offset(1.0, 0.0)  // From right
Offset(-1.0, 0.0) // From left
```

### Why Used
- **Directional**: Shows content origin
- **Engaging**: More interesting than fade
- **Navigation**: Common in navigation patterns
- **Performance**: Hardware-accelerated

### Examples in Project
- Custom page transitions
- Bottom sheet animations
- Dialog slide effects

---

## 6. ScaleTransition Widget

### Purpose
`ScaleTransition` animates the scale (size) of a widget.

### Usage in TurfMate
- **Button Press**: Scale down on tap
- **Pop-up**: Grow from center
- **Attention**: Draw focus to element
- **Add to Cart**: Product scale animation

### Key Features Used
```dart
ScaleTransition(
  scale: Tween<double>(
    begin: 0.0,  // Start at 0% size
    end: 1.0,    // End at 100% size
  ).animate(_controller),
  child: Dialog(
    child: Text('Popup content'),
  ),
)

// With custom alignment
ScaleTransition(
  scale: _animation,
  alignment: Alignment.center, // Scale from center
  child: Widget(),
)
```

### Why Used
- **Attention**: Naturally draws eye
- **Feedback**: Button press feedback
- **Modern**: Contemporary UI pattern
- **Smooth**: Better than instant appearance

### Examples in Project
- Add to cart button feedback
- Dialog appearance
- Success indicators

---

## 7. Hero Widget

### Purpose
`Hero` creates shared element transitions between screens.

### Usage in TurfMate
- **Product Images**: Image transitions to detail screen
- **Profile Pictures**: Expand to full view
- **Shared Elements**: Connect related screens
- **Visual Continuity**: Smooth screen transitions

### Key Features Used
```dart
// On source screen (product card)
Hero(
  tag: 'product-${product.id}', // Unique tag
  child: Image.network(product.imageUrl),
)

// On destination screen (product detail)
Hero(
  tag: 'product-${product.id}', // Same tag!
  child: Image.network(product.imageUrl),
)

// With custom animation
Hero(
  tag: 'hero-tag',
  flightShuttleBuilder: (
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return Material(
      child: /* custom animation widget */,
    );
  },
  child: Image(),
)
```

### Why Used
- **Visual Continuity**: Connects related screens
- **Professional**: Polished transitions
- **User Experience**: Helps understand navigation
- **Engaging**: Beautiful effect

### Examples in Project
- Product card to detail screen transitions
- Avatar expansions
- Image gallery transitions

---

## 8. AnimatedContainer Widget

### Purpose
`AnimatedContainer` automatically animates property changes.

### Usage in TurfMate
- **Size Changes**: Expand/collapse widgets
- **Color Changes**: Interactive color feedback
- **Property Transitions**: Smooth property updates
- **Responsive Animations**: Adapt to state changes

### Key Features Used
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  
  // These properties animate when changed:
  width: _isExpanded ? 200 : 100,
  height: _isExpanded ? 200 : 100,
  color: _isSelected ? Colors.green : Colors.grey,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(_isExpanded ? 20 : 10),
  ),
  
  child: Center(child: Text('Animated')),
)
```

### Why Used
- **Implicit Animation**: No AnimationController needed
- **Simple**: Easy to use
- **Multiple Properties**: Animates all changes
- **Clean Code**: Less boilerplate

### Examples in Project
- Button hover effects
- Selection indicators
- Panel expansions
- Interactive elements

---

## 9. AnimatedOpacity Widget

### Purpose
`AnimatedOpacity` implicitly animates opacity changes.

### Usage in TurfMate
- **Show/Hide**: Fade in/out elements
- **Focus**: Dim background
- **Loading Overlays**: Fade overlay in/out
- **Disabled States**: Fade out disabled elements

### Key Features Used
```dart
AnimatedOpacity(
  opacity: _isVisible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  child: Container(
    child: Text('Fading content'),
  ),
)

// With callback
AnimatedOpacity(
  opacity: _opacity,
  duration: Duration(milliseconds: 500),
  onEnd: () {
    print('Animation completed');
  },
  child: Widget(),
)
```

### Why Used
- **Simple Fade**: No controller needed
- **Cleaner**: Than FadeTransition for simple cases
- **Readable**: Clear intent in code
- **Common Use**: Frequently needed effect

### Examples in Project
- Loading overlays
- Toast messages fade out
- Disabled button states
- Show/hide indicators

---

## 10. PageView Transitions

### Purpose
  Swipe-based page transitions with animation.

### Usage in TurfMate
- **Onboarding**: Welcome screen pages
- **Image Gallery**: Product images
- **Step Navigation**: Multi-step processes
- **Content Carousels**: Featured products

### Key Features Used
```dart
PageView.builder(
  controller: _pageController,
  itemCount: _pages.length,
  onPageChanged: (int page) {
    setState(() {
      _currentPage = page;
    });
  },
  itemBuilder: (context, index) {
    return _pages[index];
  },
)

// Manual page change with animation
_pageController.animateToPage(
  page,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
)

// Jump without animation
_pageController.jumpToPage(page)
```

### Why Used
- **Natural Gesture**: Swipe is intuitive
- **Smooth**: Built-in physics
- **Common Pattern**: Familiar to users
- **Easy**: Simple implementation

### Examples in Project
- `lib/screens/onboarding/onboarding_screen.dart` - Welcome pages
```dart
final PageController _pageController = PageController();
int _currentPage = 0;

PageView.builder(
  controller: _pageController,
  itemCount: _pages.length,
  onPageChanged: (int page) {
    setState(() {
      _currentPage = page;
    });
  },
  itemBuilder: (context, index) {
    return OnboardingPageWidget(page: _pages[index]);
  },
)
```

---

## Animation Patterns in TurfMate

### 1. Splash Screen Animation
```dart
class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.forward();

    Future.delayed(Duration(seconds: 3), () async {
      // Navigate after animation
      if (authController.isLoggedIn.value) {
        await Get.offNamed(Routes.home);
      } else {
        await Get.offNamed(Routes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text('TurfMate', style: TextStyle(fontSize: 32)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 2. Button Press Animation
```dart
class AnimatedButton extends StatefulWidget {
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: ElevatedButton(
          onPressed: () {},
          child: Text('Press Me'),
        ),
      ),
    );
  }
}
```

### 3. Loading Overlay
```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        AnimatedOpacity(
          opacity: isLoading ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200),
          child: Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## Animation Best Practices

### Performance Guidelines
```dart
// ✅ Good - Use implicit animations when possible
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  color: isSelected ? Colors.green : Colors.grey,
)

// ❌ Bad - Unnecessary explicit animation
AnimationController(
  duration: Duration(milliseconds: 300),
);
// ... complex setup for simple color change

// ✅ Good - Dispose controllers
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// ✅ Good - Use const for static children
FadeTransition(
  opacity: _animation,
  child: const Icon(Icons.favorite), // const!
)
```

### Animation Durations
```dart
// TurfMate Standard Durations:
Duration(milliseconds: 100)  // Button press feedback
Duration(milliseconds: 200)  // Quick transitions
Duration(milliseconds: 300)  // Standard animations
Duration(milliseconds: 500)  // Emphasis animations
Duration(milliseconds: 800)  // Slow, dramatic effects
```

### Curve Usage
```dart
// Fast interactions
Curves.easeOut

// Screen transitions
Curves.easeInOut

// Attention-grabbing
Curves.elasticOut

// Material Design standard
Curves.fastOutSlowIn
```

---

## Summary

### Animation Widgets Used in TurfMate
```
Explicit Animations:
├── AnimationController (Splash screen)
├── FadeTransition (Fade effects)
├── SlideTransition (Screen transitions)
└── ScaleTransition (Pop-ups)

Implicit Animations:
├── AnimatedContainer (Size, color changes)
├── AnimatedOpacity (Fade in/out)
├── Hero (Shared element transitions)
└── PageView (Swipe transitions)
```

### Animation Locations
- **Splash Screen**: Logo fade-in (2-second animation)
- **Onboarding**: PageView swipe transitions
- **Product Cards**: Hero transitions to detail
- **Buttons**: Press feedback (scale)
- **Loading**: Fade overlays
- **Dialogs**: Fade + scale entrance

### Performance Notes
- ✅ All animations run at 60fps
- ✅ Controllers properly disposed
- ✅ Use implicit animations when possible
- ✅ Hardware-accelerated transforms
- ✅ Minimal widget rebuilds
- ✅ Appropriate durations

### Future Animation Enhancements
- [ ] Add to cart animation (fly to cart)
- [ ] Pull-to-refresh custom animation
- [ ] Success checkmark animation
- [ ] Empty cart animation
- [ ] Order placed celebration

---

**Last Updated**: February 2026
**Project**: TurfMate - Football Jersey E-commerce App
**Framework**: Flutter 3.x with GetX
