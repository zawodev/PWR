from sqlalchemy import create_engine
import os

engine = create_engine("postgresql://zawodev:Gulasz123@booking-db-instance-1.chukay8wkkmn.us-east-1.rds.amazonaws.com:5432/ticketing")
conn = engine.connect()
print("Connected:", conn.closed == False)
conn.close()
