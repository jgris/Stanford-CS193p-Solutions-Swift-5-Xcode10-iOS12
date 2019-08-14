
# Assignment III: Graphical Set, No Extra
## Game mode: User vs iPhone

1. All functionality of Assignment II with Extra
2. Cards now have a standard look for the Set game.
3. In this assignment, we are using UIView instead of UIButton for cards. A tap gesture on a card selects/deselects it.
4. Additional gestures. A swipe down gesture on game field to deal 3 more cards. A two-fingers rotation gesture on game field shuffles cards on it.
5. In this version, we do not limit UI to a fixed number of cards. Cards change their size depending on-screen real estate available.
6. Game works properly and looks good in both Portrait and Landscape orientations on all iPhones and iPads.

I didn't use Grid.swift provided by Stanford's instructor to define the frames for cards, but my Grid object is very similar to it. 
But there are some differences. For example if we need to define the frames of cards to display 81 cards ('cellCount = 81'), we don't have to go through 'for' cycle from 1 to 'cellCount' where 'cellCount' = 81. We can break the cycle as soon as we get 'estimatedCell' of the same value that 'largestCell' already has:
```swift
private func largestCellForAspectRatio() -> CGSize {
	var largestCell = CGSize.zero
	if cellCount > 0 && aspectRatio > 0 {
		for rowCount in 1...cellCount {
	        let estimatedCell = estimatedCellSize(rowCount: rowCount, currentLargestAllowedSize: largestCell)
	        // We do not need to go through from 1 to 'cellCount' to find out the largest cell available.
                // If 'estimatedCell' give us the same size that 'largestCell' alrady has, we can break the loop.
	        if estimatedCell != CGSize.zero {
	            if estimatedCell == largestCell { break }
	            largestCell = estimatedCell
            }
        }
...
```
