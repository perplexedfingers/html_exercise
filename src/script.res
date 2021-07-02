let draw = "draw";
let in_game = "in game";

let rows = [[0, 1, 2], [3, 4, 5], [6, 7, 8]];
let columns = [[0, 3, 6], [1, 4, 7], [2, 5, 8]];
let diags = [[0, 4, 8], [2, 4, 6]];
let lines = Belt.Array.concatMany([rows, columns, diags]);

let game = {
  "status": in_game,
  "current": true,
  "board": [
    0, 0, 0,
    0, 0, 0,
    0, 0, 0,
  ]
}

%%raw(`
const isFull = (board) => board.every(cell => cell !== 0);
const marksInLine = (board, index, mark) => lines
  .filter(inds => inds.includes(index))
  .some(inds => inds.every(ind => board[ind] === mark)
);
const computeStatus = (board, index, mark) => {
  if (marksInLine(board, index, mark)) {
    return mark
  } else if (isFull(board)) {
    return draw
  } else {
    return in_game
  }
};

const LINE_WIDTH = 10;

const genCircle = () => {
  const circle = document.createElementNS(
    "http://www.w3.org/2000/svg", "circle"
  );
  circle.setAttribute("stroke", "black");
  circle.setAttribute("fill", "transparent");
  circle.setAttribute("stroke-width", LINE_WIDTH.toString());
  circle.setAttribute("r", (LINE_WIDTH * 3.5).toString());
  circle.setAttribute("cx", "50%");
  circle.setAttribute("cy", "50%");

  const title = document.createElement("title");
  title.text = "O";
  circle.appendChild(title);
  return circle
}

const genCross = () => {
  const cross = document.createElementNS(
    "http://www.w3.org/2000/svg", "path"
  );
  cross.setAttribute("stroke", "black");
  cross.setAttribute("fill", "transparent");
  cross.setAttribute("stroke-width", LINE_WIDTH.toString());
  cross.setAttribute("d", "M 15,15 L 85,85 M 85,15 L 15,85");

  const title = document.createElement("title");
  title.text = "X";
  cross.appendChild(title);
  return cross
}

const drawMark = (node, mark) => {
  Array.from(node.childNodes).forEach(e => node.removeChild(e));
  const shape = mark === true ? genCircle() : genCross();
  return node.appendChild(shape);
};

const markBoard = (board, index, mark) => {
  board[index] = mark;
  return board
};

const celebrate = (result) => alert("Player 'result}' wins");
const callDraw = () => alert("Draw game");
const showResult = (result) => {
  if (result === true || result === false) {
    celebrate(result);
  } else if (result === draw) {
    callDraw();
  }
};

const tickFlow = (e) => {
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
        game.current = !game.current;
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
};

const resetBox = () => {
  document.querySelectorAll("#board > .cell")
    .forEach(cell => {
      Array.from(cell.childNodes).forEach(e => cell.removeChild(e))
      cell.addEventListener("click", tickFlow)
    });
}


resetBox();  // set up boxes


const reset = (e) => {
  e.preventDefault();
  e.stopPropagation();

  game.status = in_game;
  game.current = true;
  game.board = [
    0, 0, 0,
    0, 0, 0,
    0, 0, 0
  ];

  resetBox();
};

document.querySelector("main > button[type='reset']")
  .addEventListener("click", reset);
  `)
