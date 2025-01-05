from django.shortcuts import render
from django.views.generic import ListView
from .models import Earring

class HoopEarringsListView(ListView):
    model = Earring
    template_name = 'shop/earrings.html'
    context_object_name = 'earrings'

    def get_queryset(self):
        return Earring.objects.filter(category='hoop')


class StudEarringsListView(ListView):
    model = Earring
    template_name = 'shop/earrings.html'
    context_object_name = 'earrings'

    def get_queryset(self):
        return Earring.objects.filter(category='stud')


def index(request):
    return render(request, 'shop/home.html')
