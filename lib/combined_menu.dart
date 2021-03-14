import 'package:flutter/material.dart';

import 'widgets/horizontal_menu/horizontal_list.dart';
import 'widgets/vertical_sections/section_model.dart';
import 'widgets/vertical_sections/vertical_list.dart';

class CombinedMenu extends StatefulWidget {
  final List<SectionModel> sections;
  final double menuItemWidth;
  final double height;
  final double width;
  final int horizontalScrollDurationInMilliseconds;
  final int verticalScrollDurationInMilliseconds;
  final Color baseLineColor;
  final double baseLineThickness;
  final Color inticatorColor;
  final double indicatorThickness;
  final int indicatorWidthRelationFlex;
  final int itemBaseLineWidthRelationFlex;
  final double horizontalPadding;
  final double verticalContentPadding;

  const CombinedMenu({
    Key key,
    this.baseLineColor = Colors.black26,
    this.baseLineThickness = 1.0,
    this.inticatorColor = Colors.black,
    this.indicatorThickness = 2.0,
    this.indicatorWidthRelationFlex = 3,
    this.sections,
    this.menuItemWidth = 80.0,
    this.height, // = 611,
    this.width, // = 375,
    this.horizontalScrollDurationInMilliseconds = 250,
    this.verticalScrollDurationInMilliseconds = 350,
    this.itemBaseLineWidthRelationFlex = 1,
    this.horizontalPadding = 0.0,
    this.verticalContentPadding = 0.0,
  }) : super(key: key);

  @override
  _CombinedMenuState createState() => _CombinedMenuState();
}

class _CombinedMenuState extends State<CombinedMenu> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  final List<double> _initialVerticalPositions = [];
  final List<double> _initialHorizontalPositions = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _getVerticalPositions();
      _getHorizontalPositions();
      _verticalScroll.addListener(_addVerticalScrollListeners);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: widget.height,
        width: widget.width,
        child: Column(
          children: [
            HorizontalList(
              selectedIndex: _selectedIndex,
              controller: _horizontalScroll,
              menuItemWidth: widget.menuItemWidth,
              sections: widget.sections,
              baseLineColor: widget.baseLineColor,
              baseLineThickness: widget.baseLineThickness,
              inticatorColor: widget.inticatorColor,
              indicatorThickness: widget.indicatorThickness,
              indicatorWidthRelationFlex: widget.indicatorWidthRelationFlex,
              itemBaseLineWidthRelationFlex:
                  widget.itemBaseLineWidthRelationFlex,
              horizontalPadding: widget.horizontalPadding,
              onHorizontalMenuItemSelect: ({int selectedIndex}) {
                setState(() {
                  _selectedIndex = selectedIndex;
                });
                _verticalScroll.animateTo(
                  _initialVerticalPositions[selectedIndex] -
                      _initialVerticalPositions[0] +
                      1,
                  duration: Duration(
                      milliseconds:
                          widget.verticalScrollDurationInMilliseconds),
                  curve: Curves.linear,
                );
              },
            ),
            Expanded(
              child: VerticalSectionList(
                sections: widget.sections,
                controller: _verticalScroll,
                verticalContentPadding: widget.verticalContentPadding,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset _getRenderBoxOffset({GlobalKey elementKey}) {
    final RenderBox renderBox = elementKey.currentContext.findRenderObject();
    return renderBox.localToGlobal(Offset.zero);
  }

  void _getVerticalPositions() {
    widget.sections.forEach((section) {
      _initialVerticalPositions
          .add(_getRenderBoxOffset(elementKey: section.sectionKey).distance);
    });
    print(_initialVerticalPositions);
  }

  void _getHorizontalPositions() {
    widget.sections.forEach((section) {
      _initialHorizontalPositions
          .add(_getRenderBoxOffset(elementKey: section.menuItemKey).distance);
    });
    print(_initialHorizontalPositions);
  }

  void _addVerticalScrollListeners() {
    for (var i = 0; i < widget.sections.length; i++) {
      if (i == 0) {
        if (_verticalScroll.offset <
                (_initialVerticalPositions[i + 1] -
                    _initialVerticalPositions[0]) &&
            _selectedIndex != i) {
          // print('section $i');
          setState(() {
            _selectedIndex = i;
          });
          _scrollMenuHorizontally(index: i);
        }
      } else if (i == widget.sections.length - 1) {
        if (_verticalScroll.offset >
                (_initialVerticalPositions[i] - _initialVerticalPositions[0]) &&
            _selectedIndex != i) {
          // print('section $i');
          setState(() {
            _selectedIndex = i;
          });
          _scrollMenuHorizontally(index: i);
        }
      } else {
        if (_verticalScroll.offset <
                (_initialVerticalPositions[i + 1] -
                    _initialVerticalPositions[0]) &&
            _verticalScroll.offset >
                (_initialVerticalPositions[i] - _initialVerticalPositions[0]) &&
            _selectedIndex != i) {
          // print('section $i');
          setState(() {
            _selectedIndex = i;
          });
          _scrollMenuHorizontally(index: i);
        }
      }
    }
  }

  void _scrollMenuHorizontally({int index}) {
    List<GlobalKey> horizontalItems = widget.sections.map((section) => section.menuItemKey).toList();
    Scrollable.ensureVisible(horizontalItems[index].currentContext);
  }
}
