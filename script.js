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
    'http://www.w3.org/2000/svg', 'circle'
  );
  circle.setAttribute('stroke', 'black');
  circle.setAttribute('fill', 'white');
  circle.setAttribute('stroke-width', `${LINE_WIDTH}`);
  circle.setAttribute('r', `${LINE_WIDTH * 3.5}`);
  circle.setAttribute('cx', '50%');
  circle.setAttribute('cy', '50%');

  const title = document.createElement('title');
  title.text = "Circle";
  circle.appendChild(title);
  return circle
}

const genCross = () => {
  const cross = document.createElementNS(
    'http://www.w3.org/2000/svg', 'path'
  );
  cross.setAttribute('stroke', 'black');
  cross.setAttribute('fill', 'white');
  cross.setAttribute('stroke-width', `${LINE_WIDTH}`);
  cross.setAttribute('d', 'M 15,15 L 85,85 M 85,15 L 15,85');

  const title = document.createElement('title');
  title.text = "Cross";
  cross.appendChild(title);
  return cross
}

const genSVGContainer = () => {
  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('width', '100%');
  svg.setAttribute('height', '100%');
  svg.setAttribute('viewBox', '0 0 100 100');
  return svg
}

const drawMark = (node, mark) => {
  Array.from(node.childNodes).forEach(e => node.removeChild(e));
  const svg = genSVGContainer();
  const shape = mark === true ? genCircle() : genCross();
  svg.appendChild(shape)
  return node.appendChild(svg);
};

const markBoard = (board, index, mark) => {
  board[index] = mark;
  return board
};

const celebrate = (result) => alert(`Player "${result}" wins`);
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
    const element = e.target;
    const index = Array.from(element.parentNode.children)
      .findIndex(e => e === element);
    if (BOARD[index] === null) {
      const board = markBoard(BOARD, index, CURRENT);
      drawElement(element, CURRENT);
      const status = computeStatus(board, index, CURRENT);

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
};

document.querySelectorAll("main > #background > .game > .box")
  .forEach(box => box.addEventListener('click', tickFlow));


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

  document.querySelectorAll("main > #background > .game > .box")
    .forEach((box, index) => {
      Array.from(box.childNodes).forEach(e => box.removeChild(e));
      box.innerText = `${index + 1}`
    });
};

document.querySelector("main > button[type='reset']")
  .addEventListener('click', reset);
