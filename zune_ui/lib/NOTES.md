## Application Measurments

### Display Size
Width -> 272
Height -> 480

### Current Played
Width -> 160
Height -> 160

### Album Tiles
Width -> 80
Height -> 80

### Major Caveat
So OverflowBox class allows child to overflow its parent,
however if this child has Listener of some sorts,
the listener bounding rectangle will correspond to the original constraint only.
Meaning the overflow area will not consume listener events, thus will not be
interactable.
Conclusion based on this [discussion](https://github.com/flutter/flutter/issues/61316)
