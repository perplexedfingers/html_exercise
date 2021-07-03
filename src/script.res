@val external alert: string => unit = "alert"

type rec htmlElement = {
  childNodes: array<htmlElement>, // nodeList
  children: array<htmlElement>, // HTMLCollection
  mutable text: string,
  currentTarget: htmlElement,
  classList: array<string>,
}
@send external preventDefault: htmlElement => unit = "preventDefault"
@send external stopPropagation: htmlElement => unit = "stopPropagation"
@send external removeChild: (htmlElement, htmlElement) => unit = "removeChild"
@send external appendChild: (htmlElement, htmlElement) => unit = "appendChild"
@send external addEventListener: (htmlElement, string, 'a) => unit = "addEventListener"
@send external removeEventListener: (htmlElement, string, 'a) => unit = "removeEventListener"
@send external setAttribute: (htmlElement, string, string) => unit = "setAttribute"

@val external document: Dom.document = "document"
@send external querySelector: (Dom.document, string) => htmlElement = "querySelector"
@send external querySelectorAll: (Dom.document, string) => array<htmlElement> = "querySelectorAll"
@send external createElementNS: (Dom.document, string, string) => htmlElement = "createElementNS"
@send external createElement: (Dom.document, string) => htmlElement = "createElement"

type status =
  | InGame
  | X
  | O
  | Draw

type mark =
  | X
  | O

type board = array<option<mark>>

type game = {
  mutable status: status,
  mutable current: mark,
  mutable board: board,
}
let game: game = {
  status: InGame,
  current: O,
  board: Belt.Array.make(9, None),
}

let lines = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]

let isFull = (board): bool => Belt.Array.every(board, cell => cell !== None)

let marksInLine = (board: board, mark: mark, index): bool =>
  Belt.Array.keep(lines, inds =>
    Belt.Array.some(inds, ind => ind === index)
  )->Belt.Array.some(inds => Belt.Array.every(inds, ind => board[ind] === Some(mark)))

let computeStatus = (board: board, mark: mark, index: int): status =>
  if marksInLine(board, mark, index) {
    if mark === O {
      O
    } else {
      X
    }
  } else if isFull(board) {
    Draw
  } else {
    InGame
  }

let line_width = 10.0

let genCircle = (): htmlElement => {
  let circle = createElementNS(document, "http://www.w3.org/2000/svg", "circle")
  setAttribute(circle, "stroke", "black")
  setAttribute(circle, "fill", "transparent")
  setAttribute(circle, "stroke-width", Js.Float.toString(line_width))
  setAttribute(circle, "r", Js.Float.toString(line_width *. 3.5))
  setAttribute(circle, "cx", "50%")
  setAttribute(circle, "cy", "50%")

  let title = createElement(document, "title")
  title.text = "O"
  appendChild(circle, title)
  circle
}

let genCross = (): htmlElement => {
  let cross = createElementNS(document, "http://www.w3.org/2000/svg", "path")
  setAttribute(cross, "stroke", "black")
  setAttribute(cross, "fill", "transparent")
  setAttribute(cross, "stroke-width", Js.Float.toString(line_width))
  setAttribute(cross, "d", "M 15,15 L 85,85 M 85,15 L 15,85")

  let title = createElement(document, "title")
  title.text = "X"
  appendChild(cross, title)
  cross
}

let drawMark = (node, mark): unit => {
  Belt.Array.forEach(node.childNodes, e => removeChild(node, e))
  let shape = switch mark {
  | O => genCircle()
  | X => genCross()
  }
  appendChild(node, shape)
}

let showResult = (result: status): unit => {
  switch result {
  | O => alert("O wins!")
  | X => alert("X wins!")
  | Draw => alert("Draw game")
  | InGame => ()
  }
}

let rec tickFlow = (e): unit => {
  preventDefault(e)
  stopPropagation(e)

  switch game.status {
  | InGame =>
    let node = e.currentTarget
    let index =
      Belt.Array.keep(querySelector(document, "#board").children, e =>
        Belt.Array.getBy(e.classList, c => c === "cell") !== None
      )->Belt.Array.getIndexBy(e => e === node)

    switch index {
    | Some(index) =>
      game.board[index] = Some(game.current)
      let current = game.current
      drawMark(node, current)
      let status = computeStatus(game.board, current, index)

      game.status = status
      game.current = current
      switch game.status {
      | InGame =>
        switch game.current {
        | O => game.current = X
        | X => game.current = O
        }
        removeEventListener(node, "click", tickFlow)
      | O
      | X
      | Draw =>
        querySelectorAll(document, "#board > .cell")->Belt.Array.forEach(cell => {
          addEventListener(cell, "click", tickFlow)
        })
        showResult(game.status)
      }
    | None => () // TODO show notification?
    }
  | X | O | Draw => showResult(game.status)
  }
}

let resetBox = (): unit => {
  querySelectorAll(document, "#board > .cell")->Belt.Array.forEach(cell => {
    Belt.Array.forEach(cell.childNodes, e => removeChild(cell, e))
    addEventListener(cell, "click", tickFlow)
  })
}

resetBox() // set up boxes

let reset = (e): unit => {
  preventDefault(e)
  stopPropagation(e)

  game.status = InGame
  game.current = O
  game.board = Belt.Array.make(9, None)
  resetBox()
}

querySelector(document, "main > button[type='reset']")->addEventListener("click", reset)
