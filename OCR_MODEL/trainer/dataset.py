import os
import re
import math
import torch
import json

from PIL import Image
import numpy as np
from torch.utils.data import Dataset
import torchvision.transforms as transforms
from pathlib import Path

def contrast_grey(img):
    high = np.percentile(img, 90)
    low  = np.percentile(img, 10)
    return (high-low)/(high+low), high, low

def adjust_contrast_grey(img, target = 0.4):
    contrast, high, low = contrast_grey(img)
    if contrast < target:
        img = img.astype(int)
        ratio = 200./(high-low)
        img = (img - low + 25)*ratio
        img = np.maximum(np.full(img.shape, 0) ,np.minimum(np.full(img.shape, 255), img)).astype(np.uint8)
    return img


class Batch_Balanced_Dataset(object):

    def __init__(self, opt):
        self.log = open(f'./saved_models/{opt.experiment_name}/log_dataset.txt', 'a')
        self.opt = opt
        _AlignCollate = AlignCollate(imgH=opt.imgH, imgW=opt.imgW, keep_ratio_with_pad=opt.PAD)
        self.dataset, _ = hierarchical_dataset(root=opt.train_data, opt=opt)
        self.data_loader = torch.utils.data.DataLoader(
            self.dataset, batch_size=opt.batch_size,
            shuffle=True,
            num_workers=int(opt.workers),
            collate_fn=_AlignCollate, pin_memory=True)
        self.dataloader_iter = iter(self.data_loader)

    def get_batch(self):
        try:
            image, text = next(self.dataloader_iter)
        except StopIteration:
            # DataLoader를 재설정하는 대신, 더 이상 데이터가 없음을 알리고 루프를 종료합니다.
            raise RuntimeError("DataLoader has been exhausted and there is no more data to fetch.")
        return image, text


def hierarchical_dataset(root, opt):
    """ select_data='/' contains all sub-directory of root directory """
    dataset_log = f'dataset_root:    {root}'
    print('data loading,,,\t',dataset_log)
    dataset_log += '\n'



    for dirpath, dirnames, filenames in os.walk(root+'/'):

        if dirnames==['labels', 'images'] or dirnames==['images', 'labels']:
            select_flag= True
            break
            '''select_flag = False
            for selected_d in select_data:
                if selected_d in dirpath:
                    select_flag = True
                    break'''
    if select_flag:
        dirpath= Path(root)

        dataset = OCRDataset(dirpath, opt)
        sub_dataset_log = f'num samples: {len(dataset)}'
        print(sub_dataset_log)
        dataset_log += f'{sub_dataset_log}\n'



    return dataset, dataset_log

class OCRDataset(Dataset):

    def __init__(self, root, opt):

        self.root = root
        self.opt = opt

        # 이미지와 라벨 폴더의 경로
        image_folder = Path(root/'images')
        label_folder = Path(root/"labels")



        self.paired_data = []

        for label_file_name in os.listdir(label_folder):
            if label_file_name.endswith('.json'):
                with open(os.path.join(label_folder, label_file_name), 'r', encoding='utf-8') as f:
                    label_data = json.load(f)

                image_file_name = label_data["image"]["file_name"]
                image_path = os.path.join(image_folder, image_file_name)

                if self.opt.rgb:
                    if os.path.exists(image_path):
                        with Image.open(image_path).convert('RGB') as img:
                            for word in label_data["text"]["word"]:
                                bbox = word["wordbox"]
                                text = word["value"]

                                # Bounding box를 이용하여 이미지를 crop합니다.
                                cropped_img = img.crop((bbox[0], bbox[1], bbox[2], bbox[3]))
                                self.paired_data.append((cropped_img, text))
                else:
                    if os.path.exists(image_path):
                        with Image.open(image_path).convert('L') as img:
                            for word in label_data["text"]["word"]:
                                bbox = word["wordbox"]
                                text = word["value"]

                                # Bounding box를 이용하여 이미지를 crop합니다.
                                cropped_img = img.crop((bbox[0], bbox[1], bbox[2], bbox[3]))

                                if not self.opt.sensitive:
                                    text = text.lower()

                                self.paired_data.append((cropped_img, text))



        #self.df = pd.read_csv(os.path.join(root,'labels.csv'), sep='^([^,]+),', engine='python', usecols=['filename', 'words'], keep_default_na=False)
        self.nSamples = len(self.paired_data)

        if self.opt.data_filtering_off:
            self.filtered_index_list = [index for index in range(self.nSamples)]
        else:
            self.filtered_index_list = []
            for index in range(self.nSamples):
                label = self.paired_data[index][1]
                try:
                    if len(label) > self.opt.batch_max_length:
                        continue
                except:
                    print(label)
                out_of_char = f'[^{self.opt.character}]'
                if re.search(out_of_char, label.lower()):
                    continue
                self.filtered_index_list.append(index)
            self.nSamples = len(self.filtered_index_list)

    def __len__(self):
        return self.nSamples

    def __getitem__(self, index):
        index = self.filtered_index_list[index]
        #img_fname = self.df.at[index,'filename']
        #img_fpath = os.path.join(self.root, img_fname)
        #label = self.df.at[index,'words']

        '''if self.opt.rgb:
            img = Image.open(img_fpath).convert('RGB')  # for color image
        else:
            img = Image.open(img_fpath).convert('L')'''

        '''if not self.opt.sensitive:
            label = label.lower()'''

        # We only train and evaluate on alphanumerics (or pre-defined character set in train.py)
        #out_of_char = f'[^{self.opt.character}]'
        #label = re.sub(out_of_char, '', label)
        return self.paired_data[index]

class ResizeNormalize(object):

    def __init__(self, size, interpolation=Image.BICUBIC):
        self.size = size
        self.interpolation = interpolation
        self.toTensor = transforms.ToTensor()

    def __call__(self, img):
        img = img.resize(self.size, self.interpolation)
        img = self.toTensor(img)
        img.sub_(0.5).div_(0.5)
        return img


class NormalizePAD(object):

    def __init__(self, max_size, PAD_type='right'):
        self.toTensor = transforms.ToTensor()
        self.max_size = max_size
        self.max_width_half = math.floor(max_size[2] / 2)
        self.PAD_type = PAD_type

    def __call__(self, img):
        img = self.toTensor(img)
        img.sub_(0.5).div_(0.5)
        c, h, w = img.size()
        Pad_img = torch.FloatTensor(*self.max_size).fill_(0)
        Pad_img[:, :, :w] = img  # right pad
        if self.max_size[2] != w:  # add border Pad
            Pad_img[:, :, w:] = img[:, :, w - 1].unsqueeze(2).expand(c, h, self.max_size[2] - w)

        return Pad_img


class AlignCollate(object):

    def __init__(self, imgH=32, imgW=100, keep_ratio_with_pad=False, contrast_adjust = 0.):
        self.imgH = imgH
        self.imgW = imgW
        self.keep_ratio_with_pad = keep_ratio_with_pad
        self.contrast_adjust = contrast_adjust

    def __call__(self, batch):
        batch = filter(lambda x: x is not None, batch)
        images, labels = zip(*batch)

        if self.keep_ratio_with_pad:  # same concept with 'Rosetta' paper
            resized_max_w = self.imgW
            input_channel = 3 if images[0].mode == 'RGB' else 1
            transform = NormalizePAD((input_channel, self.imgH, resized_max_w))

            resized_images = []
            for image in images:
                w, h = image.size

                #### augmentation here - change contrast
                if self.contrast_adjust > 0:
                    image = np.array(image.convert("L"))
                    image = adjust_contrast_grey(image, target = self.contrast_adjust)
                    image = Image.fromarray(image, 'L')

                ratio = w / float(h)
                if math.ceil(self.imgH * ratio) > self.imgW:
                    resized_w = self.imgW
                else:
                    resized_w = math.ceil(self.imgH * ratio)

                resized_image = image.resize((resized_w, self.imgH), Image.BICUBIC)
                resized_images.append(transform(resized_image))
                # resized_image.save('./image_test/%d_test.jpg' % w)

            image_tensors = torch.cat([t.unsqueeze(0) for t in resized_images], 0)

        else:
            transform = ResizeNormalize((self.imgW, self.imgH))
            image_tensors = [transform(image) for image in images]
            image_tensors = torch.cat([t.unsqueeze(0) for t in image_tensors], 0)

        return image_tensors, labels


def tensor2im(image_tensor, imtype=np.uint8):
    image_numpy = image_tensor.cpu().float().numpy()
    if image_numpy.shape[0] == 1:
        image_numpy = np.tile(image_numpy, (3, 1, 1))
    image_numpy = (np.transpose(image_numpy, (1, 2, 0)) + 1) / 2.0 * 255.0
    return image_numpy.astype(imtype)


def save_image(image_numpy, image_path):
    image_pil = Image.fromarray(image_numpy)
    image_pil.save(image_path)
