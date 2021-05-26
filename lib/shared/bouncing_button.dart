import 'package:flutter/material.dart';

class BouncingButton extends StatefulWidget {
  BouncingButton(
    String labelText,
    this.onClick, {
    this.color = const Color(0xffFFCC80),
    this.width = 200,
    this.height = 50,
    this.labelColor = Colors.black,
    this.logo = null,
    this.labelSize = 12.0,
  })  : label = Text(
          labelText,
          style: TextStyle(fontSize: labelSize, fontWeight: FontWeight.w700, color: labelColor),
        ),
        radius = null;
  BouncingButton.circle(
    this.label,
    this.onClick, {
    this.color = const Color(0xffFFCC80),
    this.radius = 60,
  })  : this.width = null,
        this.height = null,
        this.labelColor = null,
        this.logo = null,
        this.labelSize = null;
  final Widget label;
  final Function onClick;
  final Color color;
  final double radius;
  final Color labelColor;
  final double width;
  final double height;
  final String logo;
  final double labelSize;
  @override
  _BouncingButtonState createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 92));
    _animation =
        Tween<double>(begin: 0.0, end: 0.1).animate(CurvedAnimation(curve: Curves.decelerate, parent: _controller));
    // ..addListener(() {
    //     setState(() {});
    //   });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onClick();
        print("Tapped");
      },
      onTapDown: (details) => _controller.forward().then((_) => _controller.reverse()),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.scale(scale: 1 - _animation.value, child: child),
        child: Container(
          width: widget.width ?? widget.radius,
          height: widget.height ?? widget.radius,
          decoration: BoxDecoration(
            shape: widget.radius != null ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.radius != null ? null : BorderRadius.circular(100.0),
            boxShadow: [
              BoxShadow(
                color: Color(0x80000000),
                blurRadius: 12.0,
                offset: Offset(0.0, 5.0),
              ),
            ],
            color: widget.color,
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Color(0xFF3D7588),
            //     Color(0xffff99cc),
            //   ],
            // ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.logo != null) Positioned(left: 12, width: 24, child: Image.asset(widget.logo)),
              widget.label,
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
