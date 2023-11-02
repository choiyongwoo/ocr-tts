import sys
import os
import subprocess
import platform
import importlib.util
from pathlib import Path

module_dir = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, module_dir)
USER_OS = platform.system()

try:
    import torch
    # from pydub import AudioSegment

    # if not work [pip install pdf2image] code, you have to use this code first;
    # [brew install poppler] -> MacOS or [conda install -c conda-forge poppler] -> Use Conda Env.
    from pdf2image import convert_from_path
    from pyssml.PySSML import PySSML
except:
    subprocess.run([sys.executable, '-m', 'pip', 'install',
                    'pydub', 'torch', 'pdf2image', 'pyssml', 'numpy', 'pandas'])
    install_list = ['pydub', 'torch', 'pdf2image', 'pyssml', 'numpy', 'pandas']

    while len(install_list) == 0:
        for lib in install_list:
            spec = importlib.util.find_spec(lib)
            if spec:
                install_list.remove(lib)
    print('install done')
    import torch
    # from pydub import AudioSegment
    from pdf2image import convert_from_path
    from pyssml.PySSML import PySSML

    print('import done')

try:
    from yolov5.models.experimental import attempt_load
    from recognition.model import RecogModel
    from detect.detection import text_detection
    from TTS.tts import run_tts, make_ssml
    from utils.util import sorting_bounding_box
    from utils.general import *
    from data.image_preprocessing import Load_Image
    import glob
except:
    subprocess.run([sys.executable, '-m', 'pip', 'install',
                    'numpy', 'requests', 'torchvision',
                    'opencv-python', 'boto3'
                    ])

    install_list = ['numpy', 'requests', 'torchvision', 'opencv-python', 'boto3']
    while len(install_list) == 0:
        for lib in install_list:
            spec = importlib.util.find_spec(lib)
            if spec:
                install_list.remove(lib)
    print('install done')
    from yolov5.models.experimental import attempt_load
    from recognition.model import RecogModel
    from detect.detection import text_detection
    from TTS.tts import run_tts, make_ssml
    from utils.util import sorting_bounding_box
    from utils.general import *
    from data.image_preprocessing import Load_Image
    import glob

    print('import done')

MP3_PATH = ''


#######################  수정  ###########################
def run(file_name=''):  # file_name으로 pdf file 이름 받아와서 이 파일 한정으로 mp3 파일 생성

    global MP3_PATH
    #########################################################

    # device 설정
    device = torch.device(0 if torch.cuda.is_available() else 'cpu')

    # pdf,img 디렉토리
    model_dir = os.path.dirname(os.path.realpath(__file__)).replace('\\', '/')
    top_dir = Path(model_dir).parent
    if not os.path.exists(str(model_dir)+'/images'):
        os.mkdir(str(model_dir)+'/images')
    pdf_dir = str(top_dir) + '/PDF'
    img_dir = model_dir + '/images'
    #######################  수정  ###########################
    MP3_PATH = os.path.join(str(top_dir), 'MP3', file_name + '.mp3').replace('\\', '/')
    #########################################################

    # pdf->image (all pdf file)


    # for pdf in os.listdir(pdf_dir):
    #     if pdf =='.DS_Store':
    #         continue
    pdf = file_name + '.pdf'

    # Check this page if you want to know more detail.
    # -> [https://github.com/Belval/pdf2image]
    # On Windows
    if USER_OS == 'Windows':
        pages = convert_from_path(os.path.join(pdf_dir, pdf), dpi=600,
                                  poppler_path=model_dir+'/poppler-23.08.0/Library/bin')
    # MacOS, Linux, etc.
    else:
        pages = convert_from_path(os.path.join(pdf_dir,pdf), dpi=600)

    for j, page in enumerate(pages):
        page.save(f'{img_dir}/{os.path.basename(pdf)[:-4]}_page{j + 1:0>2d}.png')


    #######################  수정  ###########################
    # pdf -> image ('file_name' pdf file only)

    # pdf = file_name + '.pdf'
    # # Check this page if you want to know more detail.
    # # -> [https://github.com/Belval/pdf2image]
    # # On Windows
    # if USER_OS == 'Windows':
    #     pages = convert_from_path(os.path.join(pdf_dir, pdf), dpi=600,
    #                               poppler_path=model_dir + '/poppler-23.08.0/Library/bin')
    # # MacOS, Linux, etc.
    # else:
    #     pages = convert_from_path(os.path.join(pdf_dir, pdf), dpi=600)
    #
    # for j, page in enumerate(pages):
    #     page.save(f'{img_dir}/{file_name}_page{j + 1:0>2d}.png')

    #########################################################

    # detection model setting
    detection_weight = Path(model_dir + '/detect/best.pt')
    try:
        detection_model = attempt_load(detection_weight, device)
    except:
        subprocess.run([sys.executable, '-m', 'pip', 'install', 'easydict'])
        detection_model = attempt_load(detection_weight, device)

    # recognition model setting
    recognition_weight = Path(model_dir + '/recognition/iter_150000_aihub_4000_pretrained.pth')
    recognition_model = RecogModel(recognition_weight)

    # Inference
    #######################  수정  ###########################
    # mp3_path_per_page = []
    #########################################################
    all_bbox_list = []
    for img_o in os.listdir(img_dir):
        bbox_list = []
        pred_list = []
        # detection
        box_list, img = text_detection(os.path.join(img_dir, img_o), device, detection_model)

        # recognition
        result = recognition_model.recognize(img, box_list)

        if result is None:
            print('no result for {img_o}')
            continue

        log = open(model_dir + '/log_demo_result.txt', 'a')
        dashed_line = '-' * 80
        head = f'\t{"predicted_labels":25s}\tconfidence score'

        # print(f'{dashed_line}\n{head}\n{dashed_line}')
        log.write(f'{dashed_line}\n{head}\n{dashed_line}\n')

        for item in result:
            bbox, pred, confidence_score = item
            bbox_list.append([pred, bbox])
            pred_list.append(pred)
            # print(f'{pred:25s}\t{confidence_score:0.4f}\n')
            # log.write(f'{pred:25s}\t{confidence_score:0.4f}\n')
        sorted_bbox_list = sorting_bounding_box(bbox_list)
        for bbox in sorted_bbox_list:
            all_bbox_list.append(bbox)

    # tts ssml version
    
    ssml_doc = make_ssml(all_bbox_list)
    mp3_path = os.path.join(str(top_dir), 'MP3', file_name + '.mp3').replace('\\', '/')
    # run_tts(ssml_doc, mp3_path)
        #######################  수정  ###########################
        # mp3_path = os.path.join(str(top_dir), 'MP3', img_o[:-4] + '.mp3').replace('\\', '/')
        # # print(ssml_doc)
        # run_tts(ssml_doc, mp3_path)
        #
        # # save mp3 path in list for merge them
        # mp3_path_per_page.append(mp3_path)

        #########################################################

    #######################  수정  ###########################
    # # merge mp3 file per pdf file page
    # result_file = None
    # for path in mp3_path_per_page:
    #     print(path)
    #     if result_file is None:
    #         result_file = AudioSegment.from_mp3(path)
    #     else:
    #         f_to_merge = AudioSegment.from_mp3(path)
    #         result_file += f_to_merge
    #     # remove mp3 file on path
    #     os.remove(path)
    #
    # # save merged mp3 file
    # result_file.export(MP3_PATH, format='mp3')
    #########################################################

    for file in os.listdir(img_dir):
        os.remove(img_dir + "/{}".format(file))


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    run(file_name='')
# See PyCharm help at https://www.jetbrains.com/help/pycharm/