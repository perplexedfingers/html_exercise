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


// TODO just check the new choice and related conditions
const isFull = (board) => board.every(cell => cell !== null);
const marksInLine = (board, mark) => LINES.some(
  inds => (inds.every(ind => board[ind] === mark))
)
const computeStatus = (board, mark) => {
  if (marksInLine(board, mark)) {
    return mark
  } else if (isFull(board)) {
    return DRAW
  } else {
    return IN_GAME
  }
}

const isNotMarked = (element) => element.innerText !== "true"
  && element.innerText !== "false"

const mark = (board, element, play) => {
  element.innerText = `${play}`;
  const index = Array.from(element.parentNode.children)
    .findIndex(e => e === element);
  board[index] = play;
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
    if (isNotMarked(element)) {
      const newBoard = mark(BOARD, element, CURRENT);
      const status = computeStatus(newBoard, CURRENT)

      if (status === IN_GAME) {
        CURRENT = !CURRENT;
        BOARD = newBoard;
      } else {
        STATUS = status;
        showResult(STATUS);
      }
    } else {
      // TODO some notification?
    }
  } else {
    showResult(STATUS);
  }
}

document.querySelectorAll("main > #background > .game > .box")
  .forEach(box => box.addEventListener('click', tickFlow))
