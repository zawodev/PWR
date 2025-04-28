from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from infrastructure.config import settings

# silnik dla PostgreSQL lub SQLite (po lokalnej migracji do AWS RDS będzie PostgreSQL)
engine = create_engine(settings.DATABASE_URL, echo=False)
SessionLocal = sessionmaker(bind=engine)

# Utworzenie tabel
from .models import Base
Base.metadata.create_all(bind=engine)
