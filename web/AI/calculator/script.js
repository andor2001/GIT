let currentInput = '0';
const display = document.getElementById('display');

function updateDisplay() {
    display.innerText = currentInput;
}

function appendNumber(number) {
    if (currentInput === '0' && number !== '.') {
        currentInput = number;
    } else {
        if (number === '.' && currentInput.includes('.')) return;
        currentInput += number;
    }
    updateDisplay();
}

function appendOperator(op) {
    const lastChar = currentInput.slice(-1);
    if (['+', '-', '*', '/'].includes(lastChar)) {
        currentInput = currentInput.slice(0, -1) + op;
    } else {
        currentInput += op;
    }
    updateDisplay();
}

function clearDisplay() {
    currentInput = '0';
    updateDisplay();
}

function deleteLast() {
    currentInput = currentInput.length > 1 ? currentInput.slice(0, -1) : '0';
    updateDisplay();
}

// ФУНКЦІЯ РАНДОМУ
function generateRandom() {
    const randomNum = Math.floor(Math.random() * 100) + 1; // 1-100
    if (currentInput === '0') {
        currentInput = randomNum.toString();
    } else {
        const lastChar = currentInput.slice(-1);
        // Якщо останній символ оператор - додаємо число до виразу
        if (['+', '-', '*', '/'].includes(lastChar)) {
            currentInput += randomNum;
        } else {
            // Якщо на екрані вже є число - замінюємо його новим рандомним
            currentInput = randomNum.toString();
        }
    }
    updateDisplay();
}

function calculate() {
    try {
        let result = eval(currentInput);
        currentInput = Number(result.toFixed(8)).toString();
    } catch (e) {
        currentInput = "Помилка";
    }
    updateDisplay();
}
