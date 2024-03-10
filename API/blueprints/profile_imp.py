import base64
import io

from PIL import Image, ImageFilter
from flask import current_app, request, jsonify
from flask_login import current_user
from sqlalchemy import Column, String, Integer, VARBINARY,\
    and_, or_

import blueprints.abstracts as abstracts
import blueprints.auth as auth
import blueprints.message as message

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
        image.save(img_io, format='JPEG')
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
    @staticmethod
    def bp_post_details():
        # Error checking to make sure the request is valid
        if current_user.is_anonymous:
            return jsonify({'message': 'Not authorized'}), 400
        json = request.get_json()
        uid = json.get('user_id')
        if not uid or not uid.isdigit():
            return jsonify({'message': 'Invalid request'}), 400
        uid = int(uid)
        user = auth.User.query.filter(auth.User.id == uid).first()
        if not user:
            return jsonify({'message': 'Invalid User'}), 400

        # Getting the profile instance
        ret_prof: Profile = Profile.query.filter(Profile.email == user.email).first()

        # Getting the details in a dictionary format and replacing
        # images with base64 encoded versions of them
        images = get_recepient_images(uid, ret_prof)
        ret_dict = {
            c.name: getattr(ret_prof, c.name) \
                for c in Profile.__table__.columns
        }
        for i in range(1, 5):
            ret_dict[f'picture{i}'] = None
        for k in images:
            ret_dict[k] = images[k]
        return ProfileBP.create_response(jsonify({
            'message': 'Success',
            'profile': ret_dict
        })), 200


def get_blur_level(user: int) -> int:
    """
    A simple function to return the blur level of the
    user's image.
    :param: user: The user that is shown to the current_user.
    :return: A value for blur level according to the number
    of messages.
    """

    if current_user.is_anonymous:
        return 20
    user2 = current_user.id
    num_messages = len(
        message.MessageTable.query.filter(
            or_(
                and_(
                    message.MessageTable.sender == user,
                    message.MessageTable.receiver == user2
                ),
                and_(
                    message.MessageTable.sender == user2,
                    message.MessageTable.receiver == user
                )
            )
        ).all()
    )
    return max(0, 20 - num_messages)

def get_recepient_images(user: int, profile: Profile = None) -> dict:
    """
    A method to provide the base64 encoded images with the appropriate
    blur applied to it.
    :param: user: is the id of the user
    :return: A list containing the images corresponding to the user
    that have the blur effect applied to them.
    """
    imgs = {f'picture{i}': None for i in range(1, 5)}
    if current_user.is_anonymous:
        return imgs
    user: auth.User = auth.User.query.filter(auth.User.id == user).first()
    if not user:
        return imgs
    if profile is None:
        profile: Profile = Profile.query.filter(
            Profile.email == user.email
        ).first()
    imgs: dict[str, Image.Image] = {
        f'picture{i}' : getattr(profile, f'picture{i}')\
            for i in range(1,5)
    }

    imgs = {
        k: Image.open(io.BytesIO(v)).filter(
            ImageFilter.GaussianBlur(
                get_blur_level(user.id)
            )
        ) if v is not None else None for k,v in imgs.items()
    }
    for key in imgs:
        if imgs[key] is None:
            continue
        b_io = io.BytesIO()
        imgs[key].save(b_io, format='JPEG')
        imgs[key].close()
        imgs[key] = base64.b64encode(
            b_io.getvalue()
        ).decode(encoding='utf-8')

    return imgs