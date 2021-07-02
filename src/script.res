type document
type htmlElement
@val external document: document = "document"
@send external querySelector: (document, string) => htmlElement = "querySelector"
@send external addEventListener: (htmlElement, string, 'a) => unit = "addEventListener"

let draw = 10
let in_game = 9

let rows = [[0, 1, 2], [3, 4, 5], [6, 7, 8]]
let columns = [[0, 3, 6], [1, 4, 7], [2, 5, 8]]
let diags = [[0, 4, 8], [2, 4, 6]]
let lines = Belt.Array.concatMany([rows, columns, diags])

let game = {
  "status": in_game,
  "current": 1,
  "board": Belt.Array.make(9, 0),
}

let line_width = 10

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

let genCircle = %raw(`
() => {
  const circle = document.createElementNS(
    "http://www.w3.org/2000/svg", "circle"
  );
  circle.setAttribute("stroke", "black");
  circle.setAttribute("fill", "transparent");
  circle.setAttribute("stroke-width", line_width.toString());
  circle.setAttribute("r", (line_width * 3.5).toString());
  circle.setAttribute("cx", "50%");
  circle.setAttribute("cy", "50%");

  const title = document.createElement("title");
  title.text = "O";
  circle.appendChild(title);
  return circle
}
`)

let genCross = %raw(`
() => {
  const cross = document.createElementNS(
    "http://www.w3.org/2000/svg", "path"
  );
  cross.setAttribute("stroke", "black");
  cross.setAttribute("fill", "transparent");
  cross.setAttribute("stroke-width", line_width.toString());
  cross.setAttribute("d", "M 15,15 L 85,85 M 85,15 L 15,85");

  const title = document.createElement("title");
  title.text = "X";
  cross.appendChild(title);
  return cross
}
`)

let drawMark = %raw(`(node, mark) => {
  Array.from(node.childNodes).forEach(e => node.removeChild(e));
  const shape = mark === 1 ? genCircle() : genCross();
  return node.appendChild(shape);
}
`)

let markBoard = (board, index, mark) => {
  board[index] = mark
  board
}

let celebrate = %raw(`(result) => alert("Player " + result.toString() + " wins")`)
let callDraw = %raw(`() => alert("Draw game")`)
let showResult = (result) => {
  if result === 1 || result === 2 {
    celebrate(result);
  } else if result === draw {
    callDraw();
  }
  ()
};

let tickFlow = %raw(`(e) => {
  e.preventDefault();
  e.stopPropagation();

  if (game.status === in_game) {
    const node = e.currentTarget;
    const index = Array
      .from(document
        .querySelector("#board").children)
      .filter(e => Array.from(e.classList).includes("cell"))
      .findIndex(e => e === node);
    if (index !== -1 && game.board[index] === 0) {
      const board = markBoard(game.board, index, game.current);
      drawMark(node, game.current);
      const status = computeStatus(board, index, game.current);

      game.board = board;
      game.status = status;
      if (game.status === in_game) {
        game.current = game.current === 1? 2 : 1;
        node.removeEventListener("click", tickFlow);
      } else {
        document.querySelectorAll("#board > .cell")
          .forEach(cell => cell.removeEventListener("click", tickFlow));
        showResult(game.status);
      }
    } else {
      // TODO show notification?
    }
  } else {
    showResult(game.status);
  }
}
  `)

let resetBox = %raw(`() => {
  document.querySelectorAll("#board > .cell")
    .forEach(cell => {
      Array.from(cell.childNodes).forEach(e => cell.removeChild(e))
      cell.addEventListener("click", tickFlow)
    });
}
`)


resetBox()  // set up boxes


let reset = %raw(`(e) => {
  e.preventDefault();
  e.stopPropagation();

  game.status = in_game;
  game.current = 1;  // 1 for Circle; 2 for Cross
  game.board = [
    0, 0, 0,
    0, 0, 0,
    0, 0, 0
  ];

  resetBox();
}
`)

addEventListener(querySelector(document, "main > button[type='reset']"), "click", reset)
