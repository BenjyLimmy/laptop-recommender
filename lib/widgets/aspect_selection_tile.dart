import 'dart:math';

import 'package:flutter/material.dart';
import 'package:laptop_reco/widgets/ripple_animation.dart';

class AspectSelectionTile extends StatefulWidget {
  final String aspect;
  final bool isSelected;
  final double weight;
  final Function(bool?)? onSelectedChanged;
  final Function(double)? onWeightChanged;

  const AspectSelectionTile({
    required this.aspect,
    required this.isSelected,
    required this.weight,
    this.onSelectedChanged,
    this.onWeightChanged,
  });

  @override
  _AspectSelectionTileState createState() => _AspectSelectionTileState();
}

class _AspectSelectionTileState extends State<AspectSelectionTile>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  // In aspect_selection_tile.dart
  // In aspect_selection_tile.dart
  final GlobalKey<RippleAnimationState> _rippleKey =
      GlobalKey<RippleAnimationState>();

  bool _isErrorMessageShown = false;

  @override
  void initState() {
    super.initState();
    // Initialize shake animation controller
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // Create a shake animation that oscillates left and right
    _shakeAnimation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    // Add listener to rebuild the widget during animation
    _shakeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // Function to play the shake animation
  // Function to play the shake animation and show error message
  void _playShakeAnimation(BuildContext context) {
    _shakeController.reset();
    _shakeController.forward();
    // Only play animation and show message if not already shown
    if (!_isErrorMessageShown) {
      // Set flag to prevent multiple messages
      _isErrorMessageShown = true;

      // Show a tooltip or snackbar to explain why
      ScaffoldMessenger.of(context)
        // Clear any existing snackbars
        ..hideCurrentSnackBar()
        // Show the new snackbar
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Maximum selections reached. Deselect an aspect first.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[700],
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // Reset the flag when the snackbar is dismissed
            onVisible: () {
              // Add a listener to reset the flag when dismissed
              Future.delayed(Duration(seconds: 2), () {
                _isErrorMessageShown = false;
              });
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate shake offset based on animation value
    final double shakeOffset = _shakeAnimation.value == 0
        ? 0
        : sin(_shakeAnimation.value * 3 * pi) * 5;

    double width = MediaQuery.of(context).size.width;
    bool showImportance = width >= 1200;
    bool showNumbers = width >= 1000;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileHeight = widget.isSelected ? 180.0 : 70.0;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: widget.onSelectedChanged == null
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: tileHeight,
            margin: EdgeInsets.only(
              top: _isHovering ? 0 : 4,
              bottom: _isHovering ? 4 : 0,
            ),
            transform: Matrix4.translationValues(
                shakeOffset, 0, 0), // Apply shake offset
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isHovering
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: RippleAnimation(
              key: _rippleKey,
              rippleColor: widget.isSelected
                  ? _getImportanceColor(widget.weight).withOpacity(0.3)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.2),
              duration: Duration(milliseconds: 400),
              child: GestureDetector(
                onTap: () {
                  if (widget.onSelectedChanged != null) {
                    _rippleKey.currentState?.startRipple();
                  }
                  // If selection is disabled, play the shake animation
                  if (widget.onSelectedChanged == null && !widget.isSelected) {
                    _playShakeAnimation(context);
                  } else if (widget.onSelectedChanged != null) {
                    // Normal selection toggle
                    widget.onSelectedChanged!(!widget.isSelected);
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: Card(
                    elevation: _isHovering ? 4 : (widget.isSelected ? 2 : 1),
                    color: widget.isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(_isHovering ? 0.5 : 0.3)
                        : widget.onSelectedChanged == null && _isHovering
                            ? Colors.red
                                .withOpacity(0.1) // Hint at disabled state
                            : _isHovering
                                ? Theme.of(context).cardColor.withOpacity(0.9)
                                : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: widget.isSelected
                          ? BorderSide(
                              color: _getImportanceColor(widget.weight),
                              width: 2)
                          : BorderSide(
                              color: widget.onSelectedChanged == null &&
                                      _isHovering
                                  ? Colors.red.withOpacity(
                                      0.5) // Red border for disabled
                                  : _isHovering
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5)
                                      : Colors.grey.shade300,
                              width: _isHovering ? 1.5 : 1),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: widget.isSelected
                          ? _buildSelectedContent(
                              context,
                              showNumber: showNumbers,
                              showImportance: showImportance,
                            )
                          : _buildUnselectedContent(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnselectedContent(BuildContext context) {
    return Center(
      child: AnimatedDefaultTextStyle(
        duration: Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: 18,
          fontWeight: _isHovering ? FontWeight.w500 : FontWeight.normal,
          color: _isHovering
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
        ),
        child: Text(
          widget.aspect,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSelectedContent(
    BuildContext context, {
    bool showSlider = true,
    bool showNumber = true,
    bool showImportance = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with checkbox and title
        Row(
          children: [
            Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: widget.isSelected,
                onChanged: widget.onSelectedChanged,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: Text(
                widget.aspect,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _isHovering
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Rest of the content remains the same
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (showNumber)
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 40 + (_isHovering ? 4 : 0),
                  height: 40 + (_isHovering ? 4 : 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getImportanceColor(widget.weight),
                    boxShadow: _isHovering
                        ? [
                            BoxShadow(
                              color: _getImportanceColor(widget.weight)
                                  .withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.weight.round()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              if (showSlider)
                // Slider for importance
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: _getImportanceColor(widget.weight),
                      thumbColor: _getImportanceColor(widget.weight),
                      trackHeight: 4,
                      overlayColor:
                          _getImportanceColor(widget.weight).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: widget.weight,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: widget.onWeightChanged,
                    ),
                  ),
                ),
              if (showImportance)
                // Label for importance
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: _isHovering ? 13 : 12,
                    color: _getImportanceColor(widget.weight),
                    fontWeight: FontWeight.bold,
                  ),
                  child: Text(
                    _getImportanceLabel(widget.weight),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getImportanceLabel(double value) {
    if (value >= 9) return 'Critical';
    if (value >= 7) return 'Very Important';
    if (value >= 5) return 'Important';
    if (value >= 3) return 'Somewhat Important';
    return 'Less Important';
  }

  Color _getImportanceColor(double weight) {
    if (weight >= 8) return Colors.red;
    if (weight >= 6) return Colors.orange;
    if (weight >= 4) return Colors.blue;
    return Colors.grey;
  }
}
