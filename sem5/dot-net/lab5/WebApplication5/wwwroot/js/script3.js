function drawLinesToSides(canvas, event) {
    const ctx = canvas.getContext('2d');

    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;

    const x = (event.clientX - rect.left) * scaleX;
    const y = (event.clientY - rect.top) * scaleY;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    ctx.beginPath();

    ctx.moveTo(x, 0);
    ctx.lineTo(x, canvas.height);

    ctx.moveTo(0, y);
    ctx.lineTo(canvas.width, y);

    ctx.strokeStyle = '#0077cc';
    ctx.lineWidth = 3;
    ctx.stroke();
}

function clearCanvas(canvas) {
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);
}

document.querySelectorAll('.drawingY').forEach((canvas) => {
    canvas.addEventListener('mousemove', (event) => drawLinesToSides(canvas, event));
    canvas.addEventListener('mouseleave', () => clearCanvas(canvas));
});
