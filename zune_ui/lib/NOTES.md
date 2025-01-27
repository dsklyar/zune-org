## Libraries
[RINF](https://rinf.cunarist.com/frequently-asked-questions/#how-can-i-await-a-response)

## Application Measurements

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


## Examples

### Future Builder
```
FutureBuilder<List<SongModel>>(
	future:
			state.currentlyPlaying?.album.getSongs(),
	builder: (BuildContext context,
			AsyncSnapshot<List<SongModel>> snapshot) {
		final doneLoading =
				snapshot.connectionState ==
								ConnectionState.done &&
						snapshot.data != null &&
						snapshot.data!.isNotEmpty;
		// Check if over one so that the .length > 3 doesnt break single song albums
		if (doneLoading &&
				snapshot.data!.length > 1) {
			return Column(
				crossAxisAlignment:
						CrossAxisAlignment.start,
				children: snapshot.data!
						.map((e) => Text(
									e.name,
									style: Styles.listItem,
								))
						.toList()
						.slice(
								1,
								snapshot.data!.length > 3
										? 4
										: snapshot.data!.length -
												1),
			);
		}

		return const SizedBox.shrink();
	},
```