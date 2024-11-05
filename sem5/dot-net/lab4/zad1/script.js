function generateRandomNumber() {
    return Math.floor(Math.random() * 99) + 1;
}

function generateTable() {
    const sizeInput = document.getElementById("tableSizeInput");
    const tableContainer = document.getElementById("tableContainer");
    const messageElement = document.getElementById("message");

    // ---------------- size input validation ----------------

    let n = parseInt(sizeInput.value);
    if (isNaN(n) || n < 5 || n > 20) {
        n = 10;
        messageElement.textContent = "Nieprawidłowe dane. Przyjęto n = " + n;
    }
    else {
        messageElement.textContent = "";
    }

    // ---------------- generate table ----------------

    tableContainer.innerHTML = "";
    const table = document.createElement("table");
    const numbers = Array.from({ length: n }, generateRandomNumber);

    // ---------------- header row ----------------

    const headerRow = document.createElement("tr");
    headerRow.appendChild(document.createElement("th"));
    numbers.forEach(rowHeader => {
        const th = document.createElement("th");
        th.textContent = rowHeader.toString();
        headerRow.appendChild(th);
    });
    table.appendChild(headerRow);

    // ---------------- table content ----------------

    numbers.forEach((rowHeader) => {
        const row = document.createElement("tr");
        const th = document.createElement("th");
        th.textContent = rowHeader.toString();
        row.appendChild(th);

        numbers.forEach((colHeader) => {
            const td = document.createElement("td");
            const result = rowHeader * colHeader;
            td.textContent = result.toString();
            td.className = result % 2 === 0 ? "even" : "odd";
            row.appendChild(td);
        });

        table.appendChild(row);
    });

    tableContainer.appendChild(table);
}
