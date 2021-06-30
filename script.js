const DRAW = 'draw';
const IN_GAME = 'in game';
let STATUS = IN_GAME;

let CURRENT = true;  // If `true` => O, else X
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
)
const computeStatus = (board, index, mark) => {
  if (marksInLine(board, index, mark)) {
    return mark
  } else if (isFull(board)) {
    return DRAW
  } else {
    return IN_GAME
  }
}

const drawElement = (element, mark) => element.innerText = `${mark}`;

const markBoard = (board, index, mark) => {
  board[index] = mark;
  return board
}

const celebrate = (result) => alert(`Player "${result}" wins`)
const callDraw = () => alert("Draw game")
const showResult = (result) => {
  if (result === true || result === false) {
    celebrate(result);
  } else if (result === DRAW) {
    callDraw()
  }
}

const tickFlow = (e) => {
  e.preventDefault();
  e.stopPropagation();

  if (STATUS === IN_GAME) {
    const element = e.target;
    const index = Array.from(element.parentNode.children)
      .findIndex(e => e === element);
    if (BOARD[index] === null) {
      const board = markBoard(BOARD, index, CURRENT);
      drawElement(element, CURRENT);
      const status = computeStatus(board, index, CURRENT)

      BOARD = board;
      STATUS = status;
      if (STATUS === IN_GAME) {
        CURRENT = !CURRENT;
      } else {
        showResult(STATUS);
      }
    } else {
      // TODO show notification?
    }
  } else {
    showResult(STATUS);
  }
}

document.querySelectorAll("main > #background > .game > .box")
  .forEach(box => box.addEventListener('click', tickFlow))
