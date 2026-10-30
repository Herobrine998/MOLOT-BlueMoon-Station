from math import hypot
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, PngImagePlugin


OUTPUT = Path(__file__).resolve().parent
SOURCE = OUTPUT.parents[1] / 'icons/obj/naga_tail_item.dmi'
SIZE = 32
ANCHORS = [
    (12, 6, 3.6), (9, 11, 3.8), (6.8, 17, 3.9),
    (7.5, 22, 4.1), (11.5, 25.5, 4.0), (17.5, 26.5, 3.8),
    (23.5, 24.7, 3.5), (27, 20.5, 3.3), (27, 16.3, 3.0),
    (23.7, 13.1, 2.8), (19.1, 12.2, 3.0), (15.2, 13.3, 3.0),
    (13.5, 16.5, 3.0), (14.7, 19.3, 2.7), (18.4, 20.7, 2.5),
    (21, 19.8, 2.1), (20.5, 17.9, 1.8), (18.8, 16.4, 1.1),
]


def curve():
    result = []
    distance = 0.0
    for segment in range(len(ANCHORS) - 1):
        p0 = ANCHORS[max(0, segment - 1)]
        p1, p2 = ANCHORS[segment:segment + 2]
        p3 = ANCHORS[min(len(ANCHORS) - 1, segment + 2)]
        for step in range(40):
            t = step / 40
            point = tuple(0.5 * (2 * p1[k] + (-p0[k] + p2[k]) * t + (2*p0[k] - 5*p1[k] + 4*p2[k] - p3[k]) * t*t + (-p0[k] + 3*p1[k] - 3*p2[k] + p3[k]) * t*t*t) for k in range(3))
            if result:
                distance += hypot(point[0] - result[-1][0], point[1] - result[-1][1])
            result.append((*point, distance))
    return result


def outside_mask(image):
    mask = image.getchannel('A')
    for coordinate in range(SIZE):
        for point in [(coordinate, 0), (coordinate, SIZE-1), (0, coordinate), (SIZE-1, coordinate)]:
            if mask.getpixel(point) == 0:
                ImageDraw.floodfill(mask, point, 128)
    return mask


def draw_tail():
    points = curve()
    image = Image.new('RGBA', (SIZE, SIZE))
    for y in range(SIZE):
        for x in range(SIZE):
            sample_x = 2.8 + (x + .5) * 27.5 / SIZE
            sample_y = 2.3 + (y + .5) * 28.0 / SIZE
            index = min(range(len(points)), key=lambda i: hypot(sample_x - points[i][0], sample_y - points[i][1]))
            px, py, width, distance = points[index]
            dx, dy = sample_x - px, sample_y - py
            offset = hypot(dx, dy)
            if offset > width:
                continue
            previous, following = points[max(0, index-1)], points[min(len(points)-1, index+1)]
            tx, ty = following[0] - previous[0], following[1] - previous[1]
            across = (ty * dx - tx * dy) / hypot(tx, ty)
            edge = offset > width - .65
            light = (-dx - dy) / (max(offset, .5) * 1.414)
            if not edge and -.18 * width <= across <= .80 * width:
                value = 210 + (20 if light > .35 else 0)
                if int(distance / 3.2) % 4 == 1:
                    value -= 30
                image.putpixel((x, y), (0, value, 0, 255))
            else:
                value = (160 if edge else 210) + round(light * 3) * 10
                if across < -.55 * width:
                    value -= 20
                image.putpixel((x, y), (max(130, min(240, value)), 0, 0, 255))
    outside = outside_mask(image)
    for y in range(SIZE):
        for x in range(SIZE):
            if outside.getpixel((x, y)) == 0:
                value = 180 if y >= 20 else 200
                image.putpixel((x, y), (value, 0, 0, 255))
    return image


def main():
    base = draw_tail()
    original = Image.open(SOURCE).convert('RGBA')
    original_cut = original.crop((32, 0, 64, 32))
    cut = original_cut.crop(original_cut.getbbox())
    overlay = Image.new('RGBA', (32, 32))
    overlay.alpha_composite(cut, (7, 0))
    combined = Image.alpha_composite(base, overlay)
    sheet = Image.new('RGBA', (64, 32))
    sheet.paste(base, (0, 0))
    sheet.paste(overlay, (32, 0))
    description = '\n'.join([
        '# BEGIN DMI', 'version = 4.0', '\twidth = 32', '\theight = 32',
        'state = "naga_tail"', '\tdirs = 1', '\tframes = 1',
        'state = "naga_tail_cut"', '\tdirs = 1', '\tframes = 1', '# END DMI', '',
    ])
    metadata = PngImagePlugin.PngInfo()
    metadata.add_text('Description', description, zip=True)
    dmi = OUTPUT / 'naga_tail_spiral_v4.dmi'
    sheet.save(dmi, format='PNG', pnginfo=metadata)
    for name, image in [('base', base), ('overlay', overlay), ('combined', combined)]:
        image.save(OUTPUT / f'{name}.png')
    font = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 20)
    panel = Image.new('RGB', (1216, 460), (32, 35, 40))
    draw = ImageDraw.Draw(panel)
    for column, (title, image) in enumerate([('Основа · 32×32', base), ('Оверлей среза · 32×32', overlay), ('Вместе · увеличение ×12', combined)]):
        left = 16 + column * 400
        draw.text((left, 15), title, font=font, fill=(224, 227, 232))
        background = Image.new('RGBA', (32, 32), (48, 51, 56, 255))
        checker = ImageDraw.Draw(background)
        for y in range(0, 32, 4):
            for x in range(0, 32, 4):
                if (x // 4 + y // 4) % 2:
                    checker.rectangle((x, y, x+3, y+3), fill=(62, 65, 70, 255))
        background.alpha_composite(image)
        panel.paste(background.resize((384, 384), Image.Resampling.NEAREST), (left, 52))
    panel.save(OUTPUT / 'preview.png')
    with Image.open(dmi) as saved:
        assert saved.size == (64, 32)
        assert saved.info['Description'] == description
        assert set(saved.getchannel('A').get_flattened_data()) == {0, 255}
    assert base.getbbox() and overlay.getbbox()
    assert combined.getbbox() == (0, 0, 32, 32)
    outside = outside_mask(base)
    assert 0 not in outside.get_flattened_data()
    print(dmi)
    print(OUTPUT / 'preview.png')


if __name__ == '__main__':
    main()
