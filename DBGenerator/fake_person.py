import datetime
import random
import io
import sys
import json

from PIL import Image
from faker import Faker
import sqlalchemy
from werkzeug.security import generate_password_hash



def generate_images(image_path: str, num_rows: int, num_cols: int):
    """
    A method to generate the base64 encoded images from a single image
    provided that contains certain number of portfolio pictures.
    :param: image_path: The path to the image.
    :param: num_rows: The number of rows of portfolios.
    :param: num_cols: The number of cols of portfolios.
    :return: An array of base64 encoded images from the file.
    """
    try:
        img_inst = Image.open(image_path)
        img_inst = img_inst.resize([num_cols * 150, num_rows * 150])
        img_width = int(img_inst.width / num_cols)
        img_height = int(img_inst.height / num_rows)
        images = [[Image.new(mode='RGB', size=[img_width, img_height]) for c in range(num_cols)] for r in range(num_rows)]
        for r in range(num_rows):
            for c in range(num_cols):
                for x in range(img_width):
                    for y in range(img_height):
                        images[r][c].putpixel([x, y], img_inst.getpixel([c * img_width + x, r * img_height + y]))
        image_strs = []
        for i in range(len(images)):
            for j in range(len(images[i])):
                img_bytes = io.BytesIO()
                images[i][j].save(img_bytes, format='JPEG')
                image_strs.append(img_bytes.getvalue())
        return image_strs
    except Exception as e:
        print(f'Error? {e}')
        return []
    
def load_imgs():
    return {
        'men': generate_images('imgs/men.webp', 5, 7),
        'women': generate_images('imgs/women.webp', 7, 7)
    }



def get_options():
    return {
        'gender': [
            'Male', 'Female', 'Other'
        ],
        'orientation': [
            'Straight', 'Gay', 'Lesbian',
            'Bisexual', 'Asexual', 'Other'
        ],
        'looking_for': [
            'A relationship', 'Something casual', 'New friends',
            'Not sure yet', 'Prefer not to say'
        ],
        'height': list(range(110, 231)),
        'star_sign': [
            'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo',
            'Virgo', 'Libra', 'Scorpio', 'Sagittarius',
            'Capricorn', 'Aquarius', 'Pisces'
        ],
        'exercise': [
            'Everyday', 'Often', 'Sometimes', 'Never'
        ],
        'drinking': [
            'Frequently', 'Socially', 'Rarely', 'Never'
        ],
        'smoking': [
            'Socially', 'Never', 'Regularly', 'Trying to quit'
        ],
        'religion': [
            'None', 'Agnostic', 'Atheist', 'Buddhist', 'Catholic',
            'Christian', 'Hindu', 'Jain', 'Jewish', 'Mormon',
            'Latter-day Saint', 'Muslim', 'Zoroastrian', 'Sikh',
            'Spiritual', 'Other', 'Prefer not to say'
        ],
    }

def get_random_limited_items():
    """
    Provides random options from the given list
    """
    options = get_options()
    return {
        o: random.choice(options[o]) for o in options
    }



def get_fake_person(fk) -> dict:
    """
    Requirements: name, email, birthday, password, bio, gender, orientation, looking_for, height, star_sign, exercise, drinking, smoking, religion
    """
    ret_dict = {
        'name': fk.name(),
        'email': fk.email(),
        'birthday': fk.date(end_datetime=datetime.datetime(2001, 1, 1)),
        'password': fk.password(),
        'bio': fk.text()
    }
    for key, val in get_random_limited_items().items():
        ret_dict[key] = val
    return ret_dict

def generate_random_ppl(fk):
    args = sys.argv
    if len(args) != 3 or not args[1].isdigit():
        print(f'Usage: {args[0]} <num-profiles> <sql-path>')
        exit(-1)
    used_emails = set()
    ret_arr = []
    for i in range(int(args[1])):
        person = get_fake_person(fk)
        while person['email'] in used_emails:
            person = get_fake_person(fk)
        ret_arr.append(person)

    return ret_arr

def upload_data():
    fk = Faker()
    pics = load_imgs()
    ppl = generate_random_ppl(fk)
    sql_path = sys.argv[2]
    pic_options = {
        'Male': lambda : 'men',
        'Female': lambda : 'women',
        'Other': lambda : random.choice(['men', 'women'])
    }
    with open('fake_ppl.json', 'w') as file:
        file.write(json.dumps(ppl))
        file.close()

    engine = sqlalchemy.create_engine(sql_path)
    
    with engine.connect() as connection:
        for d in ppl:
            # inserting the account
            connection.execute(
                sqlalchemy.text('INSERT INTO user (email, name, birthday, password) VALUES (:email, :name, :birthday, :password);'),
                {'email': d['email'], 'name': d['name'], 'birthday': d['birthday'], 'password': generate_password_hash(d['password'])}
            )
            # Inserting profile
            connection.execute(
                sqlalchemy.text('INSERT INTO profile (email, picture1, gender, orientation, looking_for, height, star_sign, exercise, drinking, smoking, religion, bio) VALUES (:email, :picture1, :gender, :orientation, :looking_for, :height, :star_sign, :exercise, :drinking, :smoking, :religion, :bio);'),
                {
                    'email': d['email'],
                    'picture1': random.choice(pics[pic_options[d['gender']]()]),
                    'gender': d['gender'],
                    'orientation': d['orientation'],
                    'looking_for': d['looking_for'],
                    'height': int(d['height']),
                    'star_sign': d['star_sign'],
                    'exercise': d['exercise'],
                    'drinking': d['drinking'],
                    'smoking': d['smoking'],
                    'religion': d['religion'],
                    'bio': d['bio']
                }
            )
            # Inserting preferences
            connection.execute(
                sqlalchemy.text(
                    'INSERT INTO profile_preference (email, gender, orientation, age, distance) VALUES ' +
                    '(:email, :gender, :orientation, :age, :distance);'
                ),
                {
                    'email': d['email'],
                    'gender': 'Everyone',
                    'orientation': 'Everyone',
                    'age': 25,
                    'distance': 60
                }
            )

            # Inserting a random location in canada
            loc = fk.local_latlng('CA', coords_only=True)
            connection.execute(
                sqlalchemy.text(
                    'INSERT INTO user_location (email, latitude, longitude) VALUES (:email, :latitude, :longitude);'
                ),
                {
                    'email': d['email'],
                    'latitude': loc[0],
                    'longitude': loc[1]
                }
            )
        connection.commit()



if __name__ == '__main__':
    upload_data()
