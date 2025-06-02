if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app="src.app.main:app",
        host="127.0.0.1",
        port=8003,
        log_level="info"
    )
