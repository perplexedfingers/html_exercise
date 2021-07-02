type document
@val external document: document = "document"

type status =
  | InGame
  | Draw
  | X
  | O

type currentPlayer =
  | X
  | O

type mark =
  | X
  | O

type board = array<option<mark>>

type game = {
  status: status,
  currentPlayer: currentPlayer,
  board: board,
}


let game: game = {
  status: InGame,
  currentPlayer: O,
  board: [
    None, None, None,
    None, None, None,
    None, None, None
  ],
}
