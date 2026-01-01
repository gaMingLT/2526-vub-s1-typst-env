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

First, the implementation itself will be discussed in section @implementation. Following the implementation, design choices will be discussed in section @design-choices. Test scenarios in section @test-scenarios. And to close, running the game in section @manual.


#colbreak()
= Implementation <implementation>

This subsection will discuss the implementation of the application. At first a general overview will be given of the application, using the image in @component-diagram, as a guide.

#figure(
  image("images/weKittensApp.svg"),
  caption: "weKittens Component Diagram",
) <component-diagram>

There are more classes responsible for the workings of the application, but the more important ones are included in @component-diagram.

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

Multiple games can be played on the network, by creating separate lobbies using the lobby system.



== Game

This subsection will discuss design choices pertaining to the game.


=== Disconnects

When is player is detected to be offline, if it is currently that player's turn, the game is paused for all players, user input is blocked.

In the other case, the players's are allowed to continue playing, until it is that player's turn.



=== Reconnect

When a player reconnects after disconnecting from the network, the current player will send the updates value of the game to the reconnecting player.

On receiving the GameEvent, the player will replace the current game values with the new values. Currently the implementation is disabled, since the order of events is not guaranteed to be 'total', it is possible for the reconnect event to be arrive before game events occurred earlier.

Possible solution to this problem, is implementing a sort of order on the game events. Or making the operations idempotent on the game state.


=== Exploding Kitten

If a player draws an exploding exploding kitten card and no defuse card is present in the players hand the player is considered dead.

For the implementation, it was chosen to discard all the cards in the player hand, and the game continues without the player in the game order, but is allowed to spectate the game. If the player wishes, he is able to leave/exit the application.



=== Nope Card <nope-card>


When any card is played, the variable `waitingForAck` is set to `true` and for each player a timer is started, for more info on the AT implementation see @at-time-out.

Each time a response is received from a player, either passing or playing a nope card, the list of online player is retrieved. The id of the player is set to `true`, in the `cardPlayedAck` hash map. And the timer for the particular player is terminated.

Then the value of the `card` value is checked, if the card is not null, and the type of the played card is a nope card, the action of playing a nope card is activated, and last played card power is activated. The timers for all players are also cancelled.

Two boolean are created, one for checking if all players have acknowledge or if all online players have acknowledged. If that is the case, the power of the last card is activated.



=== Dead & Leaving

After a player is dead, he is still able to follow the game, but all his cards have been placed on the discard pile and is unable to draw any more cards.

In both cases, the player is removed from the game order.

For the actions, where there is expected player action or application responses, these are handled by taking into account the 'online' player list.

When playing a favor/cat card, if the card is allowed to be played (accepted by all participating players), the player may select the player he wishes to request a card from. The list of selectable players is kept up to date by the players are that are actively participating and online.



== AT

This subsection will discuss design choices made pertaining to the distributed part of the application in Ambienttalk.


=== Nope Card Time-Out <at-time-out>


When a card is played, the AT method `setNopeCardTimeOut` is called with the list of players currently in the game. For each player a future is created, when the future is resolved, the accompanying offline timer is cancelled. When the future is ruined, the `passPassPlayedCardTimer` method on the `Kittensmodel` class is called, passing the played card in that players name.

The response timer is created, with a timing of 10 seconds (testing purposes). If the timer has elapsed, an exception is created named: `XReponseException`, with subtype: `Exeception`. The exeception is passed as a value to the `ruin` method on the `reponseResolver`. with a messages indicated which player did not response in time. The message is than logged in the `catch` block of the future.


=== Offline Time-Out <offline-time-out>

When a player is detected to be offline, a future is created. At the same time a timer is started, when the timer has elapsed, the future is ruined by creating an exception and calling the `ruin(e)` method on the resolver.

In case the user appears online again, the `resolve()` message is send to the resolver. This will resolve the future, and not future action will be taken. When the `ruin` message is send to the resolver, the `catch` block on the future is triggered.

The message in the exceptions is retrieved and logged. The id of the user is passed to the `kickPlayer` method defined on the `model`. The method on it's part will handle kicking the player if he is part of the game.



= Test Scenarios <test-scenarios>



== Mock Network

For easier testing of the application, a mock network implementation was created to mimic behavior of the AT network as best as possible.

The mock implementation can be found in the: `mock` directory inside the `test` directory. The implementation consists of the following files: `MockNetwork`, `MockInterface`, `MockLocalInterface`, `MockRemoteInterface`.

When starting a test scenario, a mock network is created. Each application receives a `MockInterface`, consisting of a `MockLocalInterface` and `MockRemoteInterface`. The `MockLocalInterface` implements the `atLocalInterface` interface class, as best as possible. The `MockRemoteInterface` is responsible for passing the received messages to the `KittensModel` class as the AT implementation does.

The `MockNetwork` mimics the discovery of an actor when one is added to the network, interface status is also updated across the network. Since the AT implementation expects events to be serialized across the network, the values passed through the mock network must also mimic the behavior. Copying the values passed over the network is handle by the `deepCopyRecord` function.


== Threads

To prevent threading issues, when executing actions, such as clicking buttons, selecting rows in a table, the code must be passed to the `awt.EventQueue`. This ensures all actions are processed in the correct order and no other thread than the `awt` one performs UI actions.

Most calls to the `awt.EventQueue`, are also wrapped inside of a `CompletableFuture`, containing a delay depending on the previous action performed before. This allows the returning future to be delayed by calling `join` on the result, but the main thread containing, the application(s) and network to continue working.

Once the time inside of the future has passed, the asserts are performed on the application values.



== Lobby

The following test scenarios are declared for the lobbies:
+ `createLobby`
+ `disconnectFromLobby`
+ `startGame`
+ `leaveLobby`
+ `playerLimitLobby`


=== `playerLimitLobby`

This test scenario ensure the lobby system does not allow for more than 4 players to be present inside the lobby and thus the game.

// TODO: More here



== Game

The following test scenarios are currently included in game test files:
- `TwoPlayerTests`
  + `drawCards`
  + `playerLeavesWins`
- `ThreePlayerTests`
  + `playerLeaves`
- `FourPlayerTests`
  + `drawCards`
  + `playerLeaves`


// TODO: More here



// TODO: Make video
// == Video

// Included in the zip folder, is a video detailing the workings of the application, according to the details mentioned in the report.


= Manual <manual>

The following subsection will describe on how to run the game, in the different player configuration and how to execute the accompanying tests.


== Game

The game can be started by creating 2 or more run configurations of the `main.at` file. Using the Jet-brains included `compound` functionality, the select number of applications can be started.



// TODO: Add example config running example script to folder?
== Tests <tests>

Majority of the tests are created in Java using the Junit testing framework.


// === Ambienttalk <tests-at>



=== Java <tests-java>

Running the tests can be done by running any individual test. While running all tests all at once works, tested, they do sometimes do not behave as expected.


// == Bug

// There was one particular AT Network that appeared shortly before the deadline, but that I wasn't able to track down on how/why it occurred.

// It pertains to the AT code, of when a player is discovered, the id of the player is used in HashMap and stored with the reference. At a certain point when running the application, the same reference, was discovered twice with different ID's.

// The same code was used on a Windows computer but did not have the same network 'bug'. The bug has at the moment of writing disappeared when running the application on a Mac. It is evidently possibly this is a AT implementation or Java implementation issue.


// #set page(columns: 1)
// = Appendix <appendix>



// #bibliography("references.bib")
