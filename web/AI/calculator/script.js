let displayValue = '0';

function updateDisplay() {
  document.getElementById('display').innerText = displayValue;
}

function appendNumber(number) {
  if (displayValue === '0') displayValue = number;
  else displayValue += number;
  updateDisplay();
}

function appendOperator(op) {
  const lastChar = displayValue.slice(-1);
  if (['+', '-', '*', '/'].includes(lastChar)) {
    displayValue = displayValue.slice(0, -1) + op;
  } else {
    displayValue += op;
  }
  updateDisplay();
}

function clearDisplay() {
  displayValue = '0';
  updateDisplay();
}

function deleteLast() {
  displayValue = displayValue.length > 1 ? displayValue.slice(0, -1) : '0';
  updateDisplay();
}

function calculate() {
  try {
    // eval() виконує рядок як математичний вираз
    displayValue = eval(displayValue).toString();
  } catch {
    displayValue = "Помилка";
  }
  updateDisplay();
}