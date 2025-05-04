# 1. Baza: minimalny obraz Pythona
FROM python:3.9-slim              

# 2. Ustaw katalog roboczy w kontenerze
WORKDIR /app                      

# 3. Skopiuj plik z zależnościami i zainstaluj je
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt  

# 4. Skopiuj kod aplikacji
COPY . .                       

# 5. Odsłoń port (FastAPI domyślnie na 8000)
EXPOSE 8001                     

# 6. Komenda startowa: uruchom Uvicorn
CMD ["uvicorn", "src.app.main:app", "--host", "0.0.0.0", "--port", "8001"]
