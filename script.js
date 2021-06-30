const boxes = document.querySelectorAll("main > #background > .game > .box")

let current = true;  // If `true` => O, else X

function isNotMarked(innerText) {
  return innerText !== "true" && innerText !== "false"
}

function mark(e) {
  e.preventDefault();
  e.stopPropagation();
  const currentElement = e.target;
  if (isNotMarked(currentElement.innerText)) {
    currentElement.innerText = `${current}`;
    current = !current;
  }
}

boxes.forEach(box => box.addEventListener('click', mark))
