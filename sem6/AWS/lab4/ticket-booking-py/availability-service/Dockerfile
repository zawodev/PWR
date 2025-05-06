# 1. minimalny obraz pythona
FROM python:3.9-slim              

# 2. ustaw katalog roboczy w kontenerze
WORKDIR /app                      

# 3. skopiuj plik z zależnościami i zainstaluj je
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt  

# 4. skopiuj kod aplikacji
COPY . .                       

# 5. odsłoń port (FastAPI domyślnie niby działa na 8000)
EXPOSE 8001                     

# 6. komenda startowa: uruchom uvicorn (adres 0.0.0.0 bo inaczej nie odbiera z zewnątrz komend czy coś)
CMD ["uvicorn", "src.app.main:app", "--host", "0.0.0.0", "--port", "8001"]
