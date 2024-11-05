function drawLinesToCorners(canvas, event) {
    const ctx = canvas.getContext('2d');

    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;

    const x = (event.clientX - rect.left) * scaleX;
    const y = (event.clientY - rect.top) * scaleY;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    ctx.beginPath();

    ctx.moveTo(0, 0);
    ctx.lineTo(x, y);

    ctx.moveTo(canvas.width, 0);
    ctx.lineTo(x, y);

    ctx.moveTo(0, canvas.height);
    ctx.lineTo(x, y);

    ctx.moveTo(canvas.width, canvas.height);
    ctx.lineTo(x, y);

    ctx.strokeStyle = '#0077cc';
    ctx.lineWidth = 3;
    ctx.stroke();
}

function clearCanvas(canvas) {
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);
}

document.querySelectorAll('.drawingX').forEach((canvas) => {
    canvas.addEventListener('mousemove', (event) => drawLinesToCorners(canvas, event));
    canvas.addEventListener('mouseleave', () => clearCanvas(canvas));
});
