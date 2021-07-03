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

let draw = 10
let in_game = 9

let rows = [[0, 1, 2], [3, 4, 5], [6, 7, 8]]
let columns = [[0, 3, 6], [1, 4, 7], [2, 5, 8]]
let diags = [[0, 4, 8], [2, 4, 6]]
let lines = Belt.Array.concatMany([rows, columns, diags])

type game = {
  mutable status: int,
  mutable current: int,
  mutable board: array<int>,
}
let game = {
  status: in_game,
  current: 1, // 1 for Circle; 2 for Cross
  board: Belt.Array.make(9, 0),
}

let line_width = 10.0

let isFull = board => Belt.Array.every(board, cell => cell !== 0)
let marksInLine = (board, index, mark) =>
  Belt.Array.keep(lines, inds =>
    Belt.Array.some(inds, ind => ind === index)
  )->Belt.Array.some(inds => Belt.Array.every(inds, ind => board[ind] === mark))
let computeStatus = (board, index, mark) =>
  if marksInLine(board, index, mark) {
    mark
  } else if isFull(board) {
    draw
  } else {
    in_game
  }

let genCircle = () => {
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

let genCross = () => {
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

let drawMark = (node, mark) => {
  Belt.Array.forEach(node.childNodes, e => removeChild(node, e))
  let shape = mark === 1 ? genCircle() : genCross()
  appendChild(node, shape)
  ()
}

let markBoard = (board, index, mark) => {
  board[index] = mark
  board
}

let celebrate = result => alert(`Player ${result} wins`)
let callDraw = () => alert("Draw game")
let showResult = result => {
  if result === 1 || result === 2 {
    celebrate(Belt.Int.toString(result))
  } else if result === draw {
    callDraw()
  }
  ()
}

let rec tickFlow = e => {
  preventDefault(e)
  stopPropagation(e)

  if game.status === in_game {
    let node = e.currentTarget
    let index =
      Belt.Array.keep(querySelector(document, "#board").children, e =>
        Belt.Array.getBy(e.classList, c => c === "cell") !== None
      )->Belt.Array.getIndexBy(e => e === node)

    switch index {
    | Some(index) =>
      let board = markBoard(game.board, index, game.current)
      drawMark(node, game.current)
      let status = computeStatus(board, index, game.current)

      game.board = board
      game.status = status
      if game.status === in_game {
        game.current = game.current === 1 ? 2 : 1
        removeEventListener(node, "click", tickFlow)
      } else {
        querySelectorAll(document, "#board > .cell")->Belt.Array.forEach(cell => {
          addEventListener(cell, "click", tickFlow)
        })
        showResult(game.status)
      }
    | None => () // TODO show notification?
    }
  } else {
    showResult(game.status)
  }
}

let resetBox = () => {
  querySelectorAll(document, "#board > .cell")->Belt.Array.forEach(cell => {
    Belt.Array.forEach(cell.childNodes, e => removeChild(cell, e))
    addEventListener(cell, "click", tickFlow)
  })
}

resetBox() // set up boxes

let reset = e => {
  preventDefault(e)
  stopPropagation(e)

  game.status = in_game
  game.current = 1
  game.board = Belt.Array.make(9, 0)
  resetBox()
}

querySelector(document, "main > button[type='reset']")->addEventListener("click", reset)
