import 'package:flutter/material.dart';

/// if header height != 0.0, then assert header is null (and vice versa)
class CustomBottomSheet extends StatefulWidget {
  CustomBottomSheet({Key? key,
    this.scrollController,
    required this.maxHeight,
    this.headerHeight = 0.0,
    this.minHeight = 0.0,
    this.header,
    this.body,
    this.bgColor = Colors.white,
    this.borderRadius,
    this.boxShadow,
    this.hasBottomViewPadding = true,
    this.children,
  }) : super(key: key) {
    if (this.body == null && this.children == null) assert(this.body != null || this.children != null, "either body or children required");
    if (this.body != null && this.children != null) assert(this.body != null || this.children != null, "can't have both body and children");
    assert(this.headerHeight >= 0.0, "header height cannot be less than 0");
    if (this.header != null) assert(this.headerHeight > 0.0, "header height required if header is present");

  }

  final ScrollController? scrollController;
  final double maxHeight;
  final double headerHeight;
  /// if you want the bottom sheet to be shown (not including header part)
  final double minHeight;
  final Widget? header;
  final Widget? body;
  final List<Widget>? children;
  final Color bgColor;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  /// for safe area - bottom: true effect
  final bool hasBottomViewPadding;

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> with SingleTickerProviderStateMixin<CustomBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  Animation? _animation;
  AnimationController? _animationController;

  double _bodyHeight = 0.0;
  bool _isAtTop = false;
  bool _isDragUp = true;
  double _initPosition = 0.0;

  void _saveInitPosition(DragStartDetails d) => this._initPosition = d.globalPosition.dy;

  void _followDrag(DragUpdateDetails d) {
    final double _movedAmount = this._initPosition - d.globalPosition.dy; /// negative = drag down, positive = drag up
    double _newHeight = this._bodyHeight + _movedAmount;

    if (_newHeight < 0.0) _newHeight = 0.0; /// makes sure the bodyHeight does not fall under 0.0
    if (_newHeight > this.widget.maxHeight) _newHeight = this.widget.maxHeight; /// makes sure the bodyHeight does not go above max height
    this._bodyHeight = _newHeight;
    this.setState(() {});
    this._initPosition = d.globalPosition.dy;
  }

  /// scroll based on position
  Future<void> _onDragEndPosition(DragEndDetails d) async {
    this._animationController!.duration = const Duration(milliseconds: 300);
    if (this._bodyHeight >= this.widget.maxHeight * 1/3) {
      this._animation = Tween<double>(begin: this._bodyHeight, end: this.widget.maxHeight).animate(this._animationController!);
      this._animationController?.reset();
      await this._animationController?.forward();
    }
    if (this._bodyHeight < this.widget.maxHeight * 1/3) {
      this._animation = Tween<double>(begin: this._bodyHeight, end: 0.0).animate(this._animationController!);
      this._animationController?.reset();
      await this._animationController?.forward();
    }
  }


  /// scroll based on velocity with two different speeds
  Future<void> _onDragEndVelocity(DragEndDetails d) async {
    if (d.primaryVelocity == null) return;

    double _animateTo = this._bodyHeight - d.primaryVelocity! / 20.0; /// to be used for moderate swipe speed
    Duration _duration = const Duration(milliseconds: 100); /// 100 for moderate swipe, 300 for fast swipe

    /// if negative --> scrolling up and positive --> scrolling down
    if (d.primaryVelocity!.isNegative) {
      if (d.primaryVelocity! < - 2000.0) {
        _duration = const Duration(milliseconds: 300);
        _animateTo = this.widget.maxHeight; /// scroll up all the way up
      } else {
        if (_animateTo > this.widget.maxHeight) _animateTo = this.widget.maxHeight; /// makes sure does not go past max height
      }
    } else {
      if (d.primaryVelocity! > 2000.0) {
        _duration = const Duration(milliseconds: 300);
        _animateTo = 0.0; /// scroll all the way down
      } else {
        if (_animateTo < 100.0) _animateTo = 0.0; /// make sure does not go below 0.0
      }
    }
    this._animationController?.duration = _duration;
    this._animation = Tween<double>(begin: this._bodyHeight, end: _animateTo).animate(this._animationController!);
    this._animationController?.reset();
    await this._animationController?.forward();
  }


  Future<void> _onDragEndVelocitySimple(DragEndDetails d) async {
    double _end;
    if (d.primaryVelocity! < 0.0) {
      _end = this.widget.maxHeight;
    } else {
      _end = 0.0;
    }
    this._animation = Tween<double>(begin: this._bodyHeight, end: _end).animate(this._animationController!);
    this._animationController?.reset();
    await this._animationController?.forward();
  }


  Future<void> _onDragEnd(DragEndDetails d) async {
    if (d.primaryVelocity == null) return;
    if (d.primaryVelocity == 0) await this._onDragEndPosition(d);
    if (d.primaryVelocity != 0) await this._onDragEndVelocitySimple(d);
  }


  void _followDragWithBodyAsList(DragUpdateDetails d) {
    final double _movedAmount = this._initPosition - d.globalPosition.dy; /// negative = drag down, positive = drag up
    final double _scrollTo = this._scrollController.offset + _movedAmount; /// needed for scrolling the inner list

    /// the list inside has not been touched yet
    if (this._scrollController.position.extentBefore == 0.0) {
      if (this._isAtTop && d.primaryDelta!.isNegative) { /// bottom sheet has been scrolled to the top and the user is scrolling more upwards
        this._scrollController.jumpTo(_scrollTo);
      } else {
        /// follow drag gesture
        double _newHeight = this._bodyHeight + _movedAmount;
        if (_newHeight < 0.0) _newHeight = 0.0; /// makes sure the bodyHeight does not fall under 0.0
        if (_newHeight > this.widget.maxHeight) _newHeight = this.widget.maxHeight; /// makes sure the bodyHeight does not go above max height
        this._bodyHeight = _newHeight;
        this.setState(() {});
        this._isAtTop = false;
      }

    } else {
      /// user is scrolling the inner list
      if (_scrollTo > this._scrollController.position.maxScrollExtent) return;
      this._scrollController.jumpTo(_scrollTo);
    }
    this._initPosition = d.globalPosition.dy;
  }


  Future<void> _onDragEndWithBodyAsList(DragEndDetails d) async {
    if (d.primaryVelocity == null) return;

    if (!this._isAtTop) { /// scrolls the bottom sheet container
      if (d.primaryVelocity == 0) await this._onDragEndPosition(d);
      if (d.primaryVelocity != 0) await this._onDragEndVelocitySimple(d);
    } else {
      /// scrolls the inner list
      double _animateTo = this._scrollController.offset - d.primaryVelocity! / 5;

      if (d.primaryVelocity! > 0.0 && _animateTo < 0.0) _animateTo = 0.0; /// does not overscroll upwards
      if (d.primaryVelocity! < 0.0 && _animateTo > this._scrollController.position.maxScrollExtent) {
        _animateTo = this._scrollController.position.maxScrollExtent; /// does not overscroll downwards
      }

      int _duration = 1600; /// scroll duration for inner parts

      if (_animateTo == 0.0 && this._scrollController.offset - _animateTo < _duration) _duration = 600;
      if (_animateTo == this._scrollController.offset && this._scrollController.offset - _animateTo < _duration) _duration = 300;
      await this._scrollController.animateTo(_animateTo, duration: Duration(milliseconds: _duration), curve: Curves.easeOutCubic);
    }

    if (this._bodyHeight >= this.widget.maxHeight) {
      this._isAtTop = true;
    } else {
      this._isAtTop = false;
    }
  }


  @override
  void initState() {
    super.initState();
    this._animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300), )
      ..addListener(() {
        this._bodyHeight = this._animation!.value;
        /// this is for when the bottom sheet was controlled by animation controller
        this.setState(() {});
      })..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && this._bodyHeight >= this.widget.maxHeight) this._isAtTop = true;
      });
  }

  @override
  void dispose() {
    this._scrollController.dispose();
    this._animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: this._saveInitPosition,
      onVerticalDragUpdate: this._followDragWithBodyAsList,
      onVerticalDragEnd: this._onDragEndWithBodyAsList,
      child: SingleChildScrollView(
        child: Container(
          padding: this.widget.hasBottomViewPadding ? EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom) : null,
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(
            maxHeight: this.widget.maxHeight + this.widget.headerHeight,
            minHeight: this.widget.headerHeight + this.widget.minHeight
          ),
          decoration: BoxDecoration(
            color: this.widget.bgColor,
            borderRadius: this.widget.borderRadius,
            boxShadow: this.widget.boxShadow,
          ),
          height: this.widget.headerHeight + this._bodyHeight + (this.widget.hasBottomViewPadding ? MediaQuery.of(context).viewPadding.bottom : 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: this.widget.headerHeight,
                alignment: Alignment.center,
                child: this.widget.header,
              ),
              Expanded(
                child: this.widget.body ?? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: this._scrollController,
                  padding: const EdgeInsets.only(bottom: 45.0),
                  itemCount: this.widget.children!.length,
                  itemBuilder: (_, int index) => this.widget.children![index]
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
