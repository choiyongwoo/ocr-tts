"""Getting Started Example for Python 2.7+/3.3+"""
from boto3 import Session
from botocore.exceptions import BotoCoreError, ClientError
from contextlib import closing
import os
import sys
import subprocess
from tempfile import gettempdir
from pyssml.PySSML import PySSML
import re

def make_ssml(bbox_list = None):
    '''

    :param bbox_list: bbox_list(ocr model output) that you want to transfer bbox_list -> ssml form
    :return: ssml
    '''
    # year, month, day 형식의 text 정규표현식
    ymd = re.compile('([0-9]{4}|[0-9]{2})[\s]?([-/.])[\s]?([0-9]|1[0-2]|0[0-9])[\s]?([-/.])[\s]?([1-9]|0[1-9]|[1-2][0-9]|3[01])')
    # month, day 형식의 text 정규표현식
    md = re.compile('([0-9]|1[0-2]|0[0-9])[\s]?([-/.])[\s]?([1-9]|0[1-9]|[1-2][0-9]|3[01])')
    s = PySSML()
    # ssml 파일에서 아래 기호 있으면 pause 적용이 잘 안돼서 제거
    for text_list in bbox_list:
        if '○' in text_list:
            text_list.remove('○')
        if '□' in text_list:
            text_list.remove('□')
        join_text = ' '.join(text_list)

        # text내에 날짜 형식의 text가 있다면 연, 월, 일을 날짜 사이에 삽입
        while (ymd.search(join_text) or md.search(join_text)):
            # year, month, day 형식의 text가 있다면 text 변형
            if ymd.search(join_text):
                match_span = ymd.search(join_text).span()
                date_text = join_text[match_span[0]:match_span[1]+1]
                if ' ' in date_text:
                    date_text = date_text.replace(' ', '')
                if '.' in date_text:
                    replace_text = date_text.replace('.', '년', 1)
                    replace_text = replace_text.replace('.', '월', 1)
                    replace_text += '일'
                    join_text = join_text[:match_span[0]] + replace_text + join_text[match_span[1] + 1:]

                elif '/' in date_text:
                    replace_text = date_text.replace('/', '년', 1)
                    replace_text = replace_text.replace('/', '월', 1)
                    replace_text += '일'
                    join_text = join_text[:match_span[0]] + replace_text + join_text[match_span[1] + 1:]

                elif '-' in date_text:
                    replace_text = date_text.replace('-', '년', 1)
                    replace_text = replace_text.replace('-', '월', 1)
                    replace_text += '일'
                    join_text = join_text[:match_span[0]] + replace_text + join_text[match_span[1] + 1:]

                else:
                    pass
            # month, day 형식의 text가 있다면 text 변형
            elif md.search(join_text):
                match_span = md.search(join_text).span()
                date_text = join_text[match_span[0]:match_span[1] + 1]
                if ' ' in date_text:
                    date_text = date_text.replace(' ', '')
                if '.' in date_text:
                    replace_text = date_text.replace('.', '월', 1)
                    replace_text += '일'
                    join_text = join_text[:match_span[0]] + replace_text + join_text[match_span[1] + 1:]

                elif '/' in date_text:
                    replace_text = date_text.replace('/', '월', 1)
                    replace_text += '일'
                    join_text = join_text[:match_span[0]] + replace_text + join_text[match_span[1] + 1:]

                elif '-' in date_text:
                    replace_text = date_text.replace('-', '월', 1)
                    replace_text += '일'
                    join_text = join_text[:match_span[0]] + replace_text + join_text[match_span[1] + 1:]

                else:
                    pass
        s.say(join_text)
        # 문장 사이마다 pause 적용
        s.pause('250ms')

    return s.ssml()

def run_tts(text = None, mp3_file_name = None):
    '''

    :param text: input text that you want to transfer text to speech
    :param mp3_file_name: speech file name(example.mp3)
    :return: None
    '''

    session = Session(profile_name='chocopytorch')
    polly = session.client("polly")
    voice_id = 'Seoyeon'
    input_msg = text

    try:
        response = polly.synthesize_speech(Text= input_msg, OutputFormat="mp3",
                                            VoiceId= voice_id, TextType = 'ssml'

)
    except (BotoCoreError, ClientError) as error:
        print(error)
        sys.exit(-1)

    if "AudioStream" in response:
            with closing(response["AudioStream"]) as stream:
               output = os.path.join(mp3_file_name)

               try:
                    with open(output, "wb") as file:
                       file.write(stream.read())
               except IOError as error:
                  print(error)
                  sys.exit(-1)

    else:
        print("Could not stream audio")
        sys.exit(-1)

