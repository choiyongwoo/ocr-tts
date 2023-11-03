from django.db import models

# Create your models here.
class Convert(models.Model):
    fileName = models.CharField(max_length=100, default='')
    pdfFilePath = models.CharField(max_length=200, default='')
    mp3FilePath = models.CharField(max_length=200, default='')

    def __str__(self) -> str:
        return self.fileName