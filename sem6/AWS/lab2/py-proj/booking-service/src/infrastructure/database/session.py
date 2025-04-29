from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from infrastructure.config import settings

engine = create_engine(settings.DATABASE_URL, echo=False)
SessionLocal = sessionmaker(bind=engine)

from .models import Base
Base.metadata.create_all(bind=engine)
