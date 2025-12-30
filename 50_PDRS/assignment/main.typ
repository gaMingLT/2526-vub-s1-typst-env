#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#let cuhk = super(sym.suit.spade)

#let title = [
  weKittens: Exploding Kittens
]

#let authors = (
  // You can use grouped affiliations with mark
  (
    name: [Milan Lagae],
    email: [],
    mark: [],
  ),
)

#let affiliations = (
  (
    name: [Institution/University Name:],
    faculty: [Faculty:],
    course: [Course:],
  ),
  (
    name: [Vrije Universiteit Brussel],
    faculty: [Sciences and Bioengineering Sciences],
    course: [Programming Distributed and Replicated Systems],
  ),
)

#let conference = (
  name: [],
  short: [],
  year: [],
  date: [],
  venue: [],
)


#let doi = "/"

#show: acmart.with(
  title: title,
  authors: authors,
  affiliations: affiliations,
  conference: none,
  doi: doi,
  copyright: none,
  // Font Size as described by the assignment
  font-size: 11pt,
)


#outline()

// Modify the heading spacing above and below!
#show heading.where(): set block(above: 0.75em, below: 0.25em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 1em, below: 0.50em)



#colbreak()
= Intro

This report will discuss an implementation for the assignment "weKittens: Exploding Kittens" for the course: Programming Distributed & Replicated Systems".

First, the implementation itself will be discussed in section @implementation. Following the implementation, design choices will be discussed in @design-choices. Test scenarios in section @test-scenarios. And to close, running the game in section @manual.


// #colbreak()
= Implementation <implementation>

This subsection will discuss the implementation of the application. At first a general overview will be given of the application, using the image in @component-diagram, as a guide.

#figure(
  image("images/weKittensApp.svg"),
  caption: "weKittens Component Diagram",
) <component-diagram>


== UI

The interface of the application, will depending on the state, be either the `lobbyUI` or `gameUI`. The interface object, query the state of their respective logic objects during creation.

It is the job of the `weKittensApp` to refresh the interface when a state has occurred, so the interface can display it accordingly.


== Model

The purpose of the `KittensModel` class is to be the bridge between the Ambienttalk logic & the Java logic. The class can be see as the network controller.

All the messages send over the AT interface, must first pass through this class. All received messages from the AT `remoteInterface` are received by the respective method depending on the network state (lobby/game).

The received lobby/game-events are de-structured based on the specified enum value (`LobbyEventType`/`GameEventType`), and passed to the matching method. The method than applies the changes to the lobby or game object.


== Ambienttalk

The `localInterface` receives the messages from the `KittensModel` class, depending on if the event has to be broadcasted or send to a single player, a different method will be picked.

There are different broad/send methods for the lobby & game state. Broadcasting lobby events must happen network wide, while game events are restricted to game players only. The same counts for sending an event to a specific player.

During the transition from lobby to a game, the list of id's of the player's are set in the AT object by the method: `setGamePlayers`.


== Lobbies

The lobbies object maintains a list of all lobbies that are currently present on the network. A player will create a lobby, which will be reflected in the lobbies list of the other players active on the network.

If a player joins, the joining player get's a lobby object that is set to match the joined lobby. Other players on the network will receive the updated lobby information. More information about joining a lobby in @design-choices-lobby. Each player is also able to leave a already joined lobby.


== Game

The Game object, contains the state & logic of the Exploding Kittens game. Included in this state are the following most important fields: `GameDeck`, `GameTable`, `PlayerHands`.

The `GameDeck` represents the list of cards from which players can draw a card. The state of the table, is represented by the `GameTable`, it displays which card a user draw from the deck pile, which card a user played on the discard pile and the number of cards user has remaining in its hand.

Keeping record of which cards each has in its hand is maintained by the class `PlayerHands`. It consists, for each player of the game out of a `PlayerHand`. Containing the list of cards the user currently holds, the stack of the player (dead/disconnected, ...).


== Event Serialization

Building on the event system displayed during the practicums, each lobby/game event is a record that is serialized when passed over the AT network.

For each type of event, a record class is defined, containing the values that are to be send over. All values contained must also be serializable. Each record class matches with a values of the `LobbyEventType`/`GameEventType` enum.

On the receiving side, the AT remote interface, sends the event, to the `KittensModel`, which will cast the `Record` to its correct types based on the `Enum` value. This structure of passing events is similar for the lobby & game state of the application.


= Design Choices <design-choices>



== Lobby <design-choices-lobby>

The current implementation of the lobby system is a simple CRU system, no support for deleting a lobby at the moment.

On the creation of a lobby, the creator is set as the coordinator of the lobby. Each request for joining a lobby must be accepted by that specific player. This ensures a shared state of which players are included in the lobby and later the game. The game can also only be started by the initiating player.


== Game


== AT





= Test Scenarios <test-scenarios>



// TODO: Make video
== Video

Included in the zip folder, is a video detailing the workings of the application, according to the details mentioned in the report.


= Manual <manual>

The following subsection will describe on how to run the game, in the different player configuration and how to execute the accompanying tests.


== Game

The game can be started by creating 2 or more run configurations of the `main.at` file. Using the Jet-brains included `compound` functionality, the select number of applications can be started.

// TODO: Add example config running example script to folder?


== Tests <tests>



=== Ambienttalk <tests-at>



=== Java <tests-at>

Running the tests can be done by running any individual test or running all test included in the `test` directory.



#set page(columns: 1)
= Appendix <appendix>



#bibliography("references.bib")
