from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from ...infrastructure.config import settings

from .models import Base

engine = create_engine(settings.DATABASE_URL, echo=False)
SessionLocal = sessionmaker(bind=engine)

Base.metadata.create_all(bind=engine)
