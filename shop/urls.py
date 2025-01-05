from django.urls import path
from .views import HoopEarringsListView, StudEarringsListView, index

urlpatterns = [
    path('', index, name='index'),  # Root path for the shop app
    path('hoops/', HoopEarringsListView.as_view(), name='hoop_earrings'),  # Hoops earrings listing
    path('studs/', StudEarringsListView.as_view(), name='stud_earrings'),  # Stud earrings listing
]
