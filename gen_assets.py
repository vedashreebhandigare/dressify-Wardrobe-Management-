import os
from PIL import Image, ImageDraw

def ensure_dir(d):
    os.makedirs(d, exist_ok=True)

# Directories
ensure_dir('assets/mannequin')
ensure_dir('assets/hair')
ensure_dir('assets/clothes/tops')
ensure_dir('assets/clothes/bottoms')
ensure_dir('assets/clothes/shoes')

def create_transparent_img():
    return Image.new('RGBA', (1024, 1024), (255, 255, 255, 0))

# 1. Base Mannequin
base = create_transparent_img()
draw = ImageDraw.Draw(base)
# Head
draw.ellipse((462, 100, 562, 200), fill='#F1C27D')
# Neck
draw.rectangle((492, 190, 532, 230), fill='#F1C27D')
# Torso
draw.polygon([(462, 230), (562, 230), (582, 450), (442, 450)], fill='#E0AC69')
# Arms
draw.polygon([(462, 230), (432, 250), (400, 400), (420, 410)], fill='#F1C27D') # Left 
draw.polygon([(562, 230), (592, 250), (624, 400), (604, 410)], fill='#F1C27D') # Right
# Legs
draw.rectangle((452, 450, 492, 850), fill='#F1C27D') # Left 
draw.rectangle((532, 450, 572, 850), fill='#F1C27D') # Right
base.save('assets/mannequin/base.png')

# 2. Hairstyles
# Open Hair
img = create_transparent_img()
draw = ImageDraw.Draw(img)
draw.ellipse((440, 80, 584, 190), fill='#4A3728') # top
draw.rectangle((440, 140, 480, 300), fill='#4A3728') # flow left
draw.rectangle((544, 140, 584, 300), fill='#4A3728') # flow right
img.save('assets/hair/open_hair.png')

# Ponytail
img = create_transparent_img()
draw = ImageDraw.Draw(img)
draw.ellipse((450, 90, 574, 190), fill='#4A3728') # top
draw.ellipse((560, 110, 650, 160), fill='#4A3728') # tail
img.save('assets/hair/ponytail.png')

# Bun
img = create_transparent_img()
draw = ImageDraw.Draw(img)
draw.ellipse((450, 90, 574, 190), fill='#4A3728') # top
draw.ellipse((480, 50, 544, 110), fill='#4A3728') # bun 
img.save('assets/hair/bun.png')

# 3. Tops
# White Tee
img = create_transparent_img()
draw = ImageDraw.Draw(img)
draw.polygon([(462, 220), (562, 220), (582, 450), (442, 450)], fill='#FFFFFF')
draw.polygon([(462, 220), (420, 260), (440, 290)], fill='#FFFFFF')
draw.polygon([(562, 220), (604, 260), (584, 290)], fill='#FFFFFF')
img.save('assets/clothes/tops/white_tee.png')

# Blue Shirt
img = create_transparent_img()
draw = ImageDraw.Draw(img)
draw.polygon([(462, 220), (562, 220), (582, 450), (442, 450)], fill='#4A90E2')
draw.polygon([(462, 220), (410, 350), (440, 360)], fill='#4A90E2')
draw.polygon([(562, 220), (614, 350), (584, 360)], fill='#4A90E2')
img.save('assets/clothes/tops/blue_shirt.png')

# Sweater
img = create_transparent_img()
draw = ImageDraw.Draw(img)
draw.polygon([(452, 210), (572, 210), (592, 450), (432, 450)], fill='#D32F2F') # Thicker fit
draw.polygon([(462, 220), (400, 420), (430, 430)], fill='#D32F2F')
draw.polygon([(562, 220), (624, 420), (594, 430)], fill='#D32F2F')
img.save('assets/clothes/tops/sweater.png')

# 4. Bottoms
# Blue Jeans
img = create_transparent_img()
draw = ImageDraw.Draw(img)
draw.rectangle((442, 450, 582, 500), fill='#1565C0') # Waist/Pelvis
draw.rectangle((448, 500, 498, 860), fill='#1565C0') # Left Leg
draw.rectangle((526, 500, 576, 860), fill='#1565C0') # Right Leg
img.save('assets/clothes/bottoms/blue_jeans.png')

# Skirt
img = create_transparent_img()
draw = ImageDraw.Draw(img)
draw.polygon([(442, 450), (582, 450), (620, 650), (404, 650)], fill='#8E24AA')
img.save('assets/clothes/bottoms/skirt.png')

# Trousers
img = create_transparent_img()
draw = ImageDraw.Draw(img)
# slightly different cut
draw.rectangle((442, 450, 582, 500), fill='#424242') # Waist
draw.rectangle((446, 500, 500, 850), fill='#424242') # Left Leg wide
draw.rectangle((524, 500, 578, 850), fill='#424242') # Right Leg wide
img.save('assets/clothes/bottoms/trousers.png')

# 5. Shoes
# Sneakers
img = create_transparent_img()
draw = ImageDraw.Draw(img)
draw.ellipse((430, 840, 500, 880), fill='#EEEEEE')
draw.ellipse((524, 840, 594, 880), fill='#EEEEEE')
img.save('assets/clothes/shoes/sneakers.png')

# Heels
img = create_transparent_img()
draw = ImageDraw.Draw(img)
draw.polygon([(460, 840), (490, 870), (470, 880)], fill='#C2185B')
draw.polygon([(540, 840), (570, 870), (550, 880)], fill='#C2185B')
draw.rectangle((465, 870, 470, 900), fill='#000000') # heel spike L
draw.rectangle((545, 870, 550, 900), fill='#000000') # heel spike R
img.save('assets/clothes/shoes/heels.png')

print("Assets successfully generated!")
