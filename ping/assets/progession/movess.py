import pygame
import qrcode
import random
import time
from PIL import Image

# Configuration
WIDTH, HEIGHT = 1280, 1200
FPS = 900
MOVE_DISTANCE = 100
QR_DATA = "DYNAMIC-SECRET-" + str(int(time.time()))

# Initialisation Pygame
pygame.init()
screen = pygame.display.set_mode((WIDTH, HEIGHT))
clock = pygame.time.Clock()
font = pygame.font.SysFont('Arial', 20)

# Génération du QR Code avec PIL
def generate_qr_surface(data):
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)
    
    img = qr.make_image(fill_color="black", back_color="white")
    img = img.convert("RGB")  # Convertir en RGB pour Pygame
    
    # Conversion PIL vers Pygame
    mode = img.mode
    size = img.size
    data = img.tobytes()
    
    return pygame.image.fromstring(data, size, mode)

# Création de la surface Pygame
try:
    qr_surface = generate_qr_surface(QR_DATA)
except Exception as e:
    print(f"Erreur lors de la génération du QR: {e}")
    pygame.quit()
    exit()

# Position initiale
x, y = WIDTH // 2 - qr_surface.get_width() // 2, HEIGHT // 2 - qr_surface.get_height() // 2

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
    
    # Mouvement aléatoire
    x += random.randint(-MOVE_DISTANCE, MOVE_DISTANCE)
    y += random.randint(-MOVE_DISTANCE, MOVE_DISTANCE)
    
    # Limites de l'écran
    x = max(0, min(WIDTH - qr_surface.get_width(), x))
    y = max(0, min(HEIGHT - qr_surface.get_height(), y))
    
    # Affichage
    screen.fill((240, 240, 240))  # Fond gris clair
    screen.blit(qr_surface, (x, y))
    
    # Infos
    info_text = f"FPS: {FPS} | Pos: {x},{y} | Data: {QR_DATA}"
    text_surface = font.render(info_text, True, (0, 0, 0))
    screen.blit(text_surface, (10, 10))
    
    pygame.display.flip()
    clock.tick(FPS)

pygame.quit()
