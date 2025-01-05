import datetime
from django.db import models
from django.utils import timezone

class Earring(models.Model):
    CATEGORY_CHOICES = [
        ('stud', 'Stud'),
        ('hoop', 'Hoop'),
    ]

    MATERIAL_CHOICES = [
        ('silver_925', 'Silver 925'),
    ]

    name = models.CharField(max_length=100)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.PositiveIntegerField()
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES)
    material = models.CharField(max_length=20, choices=MATERIAL_CHOICES, default='silver_925')
    image = models.ImageField(upload_to='shop/media', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name