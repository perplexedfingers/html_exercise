let current = true;  // If `true` => O, else X
let board = [
  null, null, null,
  null, null, null,
  null, null, null
];

const rows = [[0, 1, 2], [3, 4, 5], [6, 7, 8]];
const columns = [[0, 3, 6], [1, 4, 7], [2, 5, 8]];
const diags = [[0, 4, 8], [2, 4, 6]];
const lines = [...rows, ...columns, ...diags];


function isEndGame() {
  // TODO just check the new choice and related conditions
  return lines.some(inds => inds.every(ind => board[ind] !== null)
    && (board[inds[0]] === board[inds[1]] === board[inds[2]])
  )
}

function isNotMarked(element) {
  return element.innerText !== "true"
    && element.innerText !== "false"
}

function mark(currentElement) {
  currentElement.innerText = `${current}`;
  const index = Array.from(currentElement.parentNode.children)
    .findIndex(e => e === currentElement);
  board[index] = current;
}

function nextRound() {
  if (isEndGame()) {
    alert(`Player "${current}" wins`)
  } else {
    current = !current;
  }
}

function tickFlow(e) {
  e.preventDefault();
  e.stopPropagation();

  if (!isEndGame()) {
    const currentElement = e.target;
    if (isNotMarked(currentElement)) {
      mark(currentElement);
      nextRound()
    }
  }
}

document.querySelectorAll("main > #background > .game > .box")
  .forEach(box => box.addEventListener('click', tickFlow))
