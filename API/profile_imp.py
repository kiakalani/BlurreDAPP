import base64
import io

from PIL import Image
from flask import current_app, request, jsonify
from flask_login import current_user
from sqlalchemy import Column, String, Integer, VARBINARY

import abstracts


class Profile(current_app.config['DB']['base']):
    """
    An ORM that stores the necessary information
    from each user.
    """

    __tablename__ = 'profile'
    email = Column(String, primary_key=True)
    picture1 = Column(VARBINARY)
    picture2 = Column(VARBINARY)
    picture3 = Column(VARBINARY)
    picture4 = Column(VARBINARY)
    gender = Column(String)
    orientation = Column(String)
    looking_for = Column(String)
    height = Column(Integer)
    star_sign = Column(String)
    exercise = Column(String)
    drinking = Column(String)
    smoking = Column(String)
    religion = Column(String)
    bio = Column(String)

    def __init__(self, email) -> None:
        self.email = email

def resize_picture(txt: str) -> bytes:
    """
    A simple method to validate the image text and
    resize it to 640x480 resolution to save storage
    """

    if txt is None:
        return None
    try:
        image = Image.open(io.BytesIO(base64.b64decode(txt)))
        image = image.resize((320, 320))
        img_io = io.BytesIO()
        image.save(img_io, format='PNG')
        return img_io.getvalue()
    except Exception:
        return None

def valid_checks() -> dict:
    """
    A method for getting the name of columns as well as
    the functions that validates them.
    :return: a dictionary containing the name of the column
    and the function validating them as a value.
    """

    a_valid = lambda a: a in [
        'often',
        'sometimes',
        'never'
    ]

    return {
        'gender': lambda g : g in [
            'Male', 'Female', 'Other'
        ],
        'orientation': lambda o: o in [
            'Straight', 'Gay', 'Lesbian',
            'Bisexual', 'Asexual', 'Other'
        ],
        'looking_for': lambda l: l in [
            'A relationship', 'Something casual', 'New friends',
            'Not sure yet', 'Prefer not to say'
        ],
        'height': lambda h: h is not None and h.isdigit()\
            and 110 <= int(h) <= 230,
        'star_sign': lambda s: s in [
            'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo',
            'Virgo', 'Libra', 'Scorpio', 'Sagittarius',
            'Capricorn', 'Aquarius', 'Pisces'
        ],
        'exercise': lambda e: e in [
            'Everyday', 'Often', 'Sometimes', 'Never'
        ],
        'drinking': lambda d: d in [
            'Frequently', 'Socially', 'Rarely', 'Never'
        ],
        'smoking': lambda s: s in [
            'Socially', 'Never', 'Regularly', 'Trying to quit'
        ],
        'religion': lambda r: r in [
            'None', 'Agnostic', 'Atheist', 'Buddhist', 'Catholic',
            'Christian', 'Hindu', 'Jain', 'Jewish', 'Mormon',
            'Latter-day Saint', 'Muslim', 'Zoroastrian', 'Sikh',
            'Spiritual', 'Other', 'Prefer not to say'
        ],
        'picture1': resize_picture,
        'picture2': resize_picture,
        'picture3': resize_picture,
        'picture4': resize_picture,
        'bio': lambda a: a is not None
    }


class ProfileBP(abstracts.BP):
    def __init__(self) -> None:
        super().__init__('profile')

    @staticmethod
    def bp_post():
        """
        A post method to deal with updating elements of the
        user's profile.
        """

        if current_user.is_anonymous:
            return ProfileBP.create_response(
                jsonify({
                'message': 'Invalid login occurred'
                })
            ), 400


        checks = valid_checks()
        jsons = request.get_json()

        # Getting the corresponding profile instance
        profile = Profile.query.filter(Profile.email == current_user.email).first()

        for item, check_function in checks.items():
            # Value from the post request
            value = jsons.get(item)
            # Would provide the result of verification
            check_result = check_function(value)
            if check_result:
                if item == 'height':
                    # height has to be converted to a string
                    profile.height = int(value)
                elif item[:-1] == 'picture':
                    # picture has the value in the check result
                    setattr(profile, item, check_result)
                else:
                    # The value is validated, so we set it for
                    # profile
                    setattr(profile, item, value)

        # Updating the database
        ProfileBP.db()['session'].commit()
        return ProfileBP.create_response(
            jsonify({
                'message': 'Successfully updated the profile'
            })
        ), 200
