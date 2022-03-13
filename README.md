# flutter_puzzle_hack

My Entry to the #FlutterPuzzleHack

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



My name is Fawaz Joseph and I would like thank everyone involved in creating this Hackathon.

## Inspiration
I was inspired by the base tutorial for the Project.
I, like a lot of people also like gifs so I wanted a way to put a 4x4 sliding puzzle and ways to discover gifs to use on Twitter.

## What it does
You get a random gif from giphy.org based on an optional tag.
This can be"dog", "reaction", "funny", e.t.c
In the beginning, the gif is covered by the tiles
The tiles become transparent once they are in the correct place.
When all the tiles are correct and the puzzle is solved, you can see your random gif.
You can also get hints or get it solved for you.
## How we built it
It was built using Giphy API to get the gif, particularly the random endpoint.
The PuzzleBoard was created using Stack and AnimatedPosition and also various implicit Animated Widget
Containers were used for the various decoration to highlight the states (movable, solved)
There are snack bars and progress bars to indicate messages and progress respectively
## Challenges we ran into
Learning how to write an algorithm to solve a puzzle.
Not being able to release on the web because of [compute() doesn't work on web](https://github.com/flutter/flutter/issues/33577)
## Accomplishments that we're proud of
First is the algorithm to determine whether a Puzzle is solvable or not.
The second was implementing a solver.
This is what is used to get hints and play the game for the user.
It was amazing to learn all the algorithms again.
When all the tests passed, I felt so good.
It felt like I was back in college.
I had to create an A* solving algorithm but that was too slow so I iterated to an iterative deep A*
Figuring the heuristics was amazing.
Manhattan Distance, hamming distance, number of Inversions, linear conflict.
I had to read a lot and It was so fun.
Thank you for creating this hackathon.
I learned a lot!!
## What we learned
A lot of algorithms.
A lot of new packages I didn't know existed.
## What's next for Gif Scratch-off

