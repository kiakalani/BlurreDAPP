import json
import io
import base64
import sys
import os


from PIL import Image
import sqlalchemy
from werkzeug.security import generate_password_hash

def generate_images(image_path: str, num_rows: int, num_cols: int) -> list[str]:
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
        print('W:', img_width, 'H:', img_height)
        print('R:', num_rows, 'C:', num_cols)
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
                images[i][j].save(img_bytes, format='PNG')
                image_strs.append(img_bytes.getvalue())
        return image_strs
    except Exception as e:
        print(f'Error? {e}')
        return []

def load_data(json_path: str, image_path: str, num_rows: int, num_cols: int) -> dict:
    """
    Loads the json data and appends the images to the data.
    :param: json_path: The path of the json file
    :param: image_path: The path of the grid image
    :param: num_rows: The number of rows in the grid
    :param: num_cols: The number of columns in the grid
    :return: The json data with the image.
    """
    data = json.load(open(json_path, 'r'))
    if len(data) > num_rows * num_cols:
        return {}
    images = generate_images(image_path, num_rows, num_cols)
    for i in range(len(data)):
        data[i]['picture1'] = images[i]
    return data

def write_to_db(sql_path: str, json_path: str, image_path: str, num_rows: int, num_cols: int) -> None:
    """
    Writes the appropriate data to the database.
    :param: sql_path: The path to the sql database.
    :param: json_path: The path to the json data for supplying.
    """
    data = load_data(json_path, image_path, num_rows, num_cols)
    if len(data) == 0:
        print('Invalid Arguments provided')
        exit(-1)
    engine = sqlalchemy.create_engine(sql_path)
    with engine.connect() as connection:
        for d in data:
            connection.execute(
                sqlalchemy.text('INSERT INTO user (email, name, birthday, password) VALUES (:email, :name, :birthday, :password);'),
                {'email': d['email'], 'name': d['name'], 'birthday': d['birthday'], 'password': generate_password_hash(d['password'])}
            )
            print(d['star_sign'])
            connection.execute(
                sqlalchemy.text('INSERT INTO profile (email, picture1, gender, orientation, looking_for, height, star_sign, exercise, drinking, smoking, religion, bio) VALUES (:email, :picture1, :gender, :orientation, :looking_for, :height, :star_sign, :exercise, :drinking, :smoking, :religion, :bio);'),
                {
                    'email': d['email'],
                    'picture1': d['picture1'],
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
        connection.commit()

if __name__ == '__main__':
    args = sys.argv
    if len(args) != 6:
        print(f'Usage: {args[0]} <SQLPATH> <JSONPATH> <IMGPATH> <ROWS> <COLS>')
        exit(-1)
    if not args[4].isdigit() or not args[5].isdigit():
        print('Invalid Arguments provided')
        exit(-1)
    if not os.path.exists(args[2]) or not os.path.exists(args[3]):
        print('Invalid paths provided')
        exit(-1)

    write_to_db(args[1], args[2], args[3], int(args[4]), int(args[5]))
    print('Success')


    

# import pprint; pprint.pprint(generate_images('./test.webp', 6, 10))