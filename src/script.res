%%raw(`
const DRAW = "draw";
const IN_GAME = "in game";
let STATUS = IN_GAME;

let CURRENT = true;  // If "true" => O, else X
let BOARD = [
  null, null, null,
  null, null, null,
  null, null, null
];

const rows = [[0, 1, 2], [3, 4, 5], [6, 7, 8]];
const columns = [[0, 3, 6], [1, 4, 7], [2, 5, 8]];
const diags = [[0, 4, 8], [2, 4, 6]];
const LINES = [...rows, ...columns, ...diags];


const isFull = (board) => board.every(cell => cell !== null);
const marksInLine = (board, index, mark) => LINES
  .filter(inds => inds.includes(index))
  .some(inds => inds.every(ind => board[ind] === mark)
);
const computeStatus = (board, index, mark) => {
  if (marksInLine(board, index, mark)) {
    return mark
  } else if (isFull(board)) {
    return DRAW
  } else {
    return IN_GAME
  }
};

const LINE_WIDTH = 10;

const genCircle = () => {
  const circle = document.createElementNS(
    "http://www.w3.org/2000/svg", "circle"
  );
  circle.setAttribute("stroke", "black");
  circle.setAttribute("fill", "transparent");
  circle.setAttribute("stroke-width", "LINE_WIDTH}");
  circle.setAttribute("r", "LINE_WIDTH * 3.5}");
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
  cross.setAttribute("stroke-width", "LINE_WIDTH}");
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
  } else if (result === DRAW) {
    callDraw();
  }
};

const tickFlow = (e) => {
  e.preventDefault();
  e.stopPropagation();

  if (STATUS === IN_GAME) {
    const node = e.currentTarget;
    const index = Array
      .from(document
        .querySelector("#board").children)
      .filter(e => Array.from(e.classList).includes("cell"))
      .findIndex(e => e === node);
    if (index !== -1 && BOARD[index] === null) {
      const board = markBoard(BOARD, index, CURRENT);
      drawMark(node, CURRENT);
      const status = computeStatus(board, index, CURRENT);

      BOARD = board;
      STATUS = status;
      if (STATUS === IN_GAME) {
        CURRENT = !CURRENT;
        node.removeEventListener("click", tickFlow);
      } else {
        document.querySelectorAll("#board > .cell")
          .forEach(cell => cell.removeEventListener("click", tickFlow));
        showResult(STATUS);
      }
    } else {
      // TODO show notification?
    }
  } else {
    showResult(STATUS);
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

  STATUS = IN_GAME;
  CURRENT = true;
  BOARD = [
    null, null, null,
    null, null, null,
    null, null, null
  ];

  resetBox();
};

document.querySelector("main > button[type='reset']")
  .addEventListener("click", reset);
  `)
