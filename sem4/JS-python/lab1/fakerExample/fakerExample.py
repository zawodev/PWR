from faker import Faker
import random

fake = Faker('pl_PL')

def generate_student_data(num_students):
    classes = ['Ia', 'Ib', 'Ic', 'Id',
               'IIa', 'IIb', 'IIc', 'IId',
                'IIIa', 'IIIb', 'IIIc', 'IIId',
                'IVa', 'IVb', 'IVc', 'IVd']
    cities = ['Białystok', 'Wrocław', 'Warszawa', 'Kraków', 'Gdańsk', 'Poznań', 'Łódź', 'Szczecin']
    genders = ['M', 'K']

    for student_id in range(1, num_students + 1):
        last_name = fake.last_name()
        first_name = fake.first_name()
        birth_date = fake.date_of_birth(minimum_age=7, maximum_age=19).strftime('%Y-%m-%d')
        gender = random.choice(genders)
        # Dla uproszczenia, zakładamy że płeć może wpływać na wybór imienia, ale Faker tego nie obsługuje domyślnie
        class_assignment = random.choice(classes)
        city = random.choice(cities)
        print(f"{student_id}\t{last_name}\t{first_name}\t{birth_date}\t{gender}\t{class_assignment}\t{city}")

# Generujemy dane dla przykładowej liczby uczniów, np. 10
generate_student_data(100)
